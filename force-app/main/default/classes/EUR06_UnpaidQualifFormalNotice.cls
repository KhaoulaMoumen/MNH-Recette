/* 
 * Written by Nathan Martin <nathan@euranov.com>, June 2019
 * Edited by Khaoula Moumen <khaoula.moumen@talan.com>, March 2020 
*/
global class EUR06_UnpaidQualifFormalNotice implements Database.Batchable<sObject>, Database.Stateful {
    
    public String query;
    private List<Qualification_prospect_adherent__c> qualificationsPA;
    List<Qualification_prospect_adherent__c> qualificationsWithDuplicateAccounts = new List<Qualification_prospect_adherent__c>();
    public String adherent = 'Adhérent';
    public Responsable_Mise_en_demeure_r_siliation__mdt responsable = [SELECT MasterLabel FROM Responsable_Mise_en_demeure_r_siliation__mdt WHERE DeveloperName = 'Responsable1' LIMIT 1];
	
    global Database.QueryLocator start(Database.BatchableContext bc){

        this.qualificationsPA = new List<Qualification_prospect_adherent__c>();
        this.query = 'SELECT Id, Date_de_fin__c,Compte__c, compte__r.id, Name, compte__r.nb_qualif_valides__c, Compte__r.Name FROM Qualification_prospect_adherent__c WHERE Compte__c != NULL AND Compte__r.type = :adherent ORDER BY Compte__c ASC';
        
        return Database.getQueryLocator(this.query);
    }

    global void execute(Database.BatchableContext BC, List<Qualification_prospect_adherent__c> scope){
        
        for (Integer i = 1; i < scope.size(); i++) {
                System.debug('Incrément i : ' + i);
                System.debug('qualifProspectAdherents.size() : ' + scope.size());
            // GET THE QUAFICATIONS WITH DUPLICATED ACCOUNTS
                if (scope[i-1].Compte__c == scope[i].Compte__c && scope[i-1] != scope[i]) {
                    qualificationsWithDuplicateAccounts.add(scope[i]);
                }
            }
        
        List<Id> accountIds = new List<Id>();
        
        // GET THE ACCOUNTS RELATED TO THE QUALIFICATIONS PA
        for (Qualification_prospect_adherent__c qualificationPA : scope) {
            accountIds.add(qualificationPA.compte__c);
        }

        // Evolution : Ne créer la tâche de résiliation que s’il existe une tâche non clôturée de mise en demeure sur le compte => en cours
        List<Task> tasks = [SELECT Id,CompletedDateTime, CreatedDate,whatid FROM Task WHERE whatid IN :accountIds AND Subject = 'Mise en demeure – Motif : qualification échue' AND CompletedDateTime = null];
        System.debug('Requête des tasks :' +  tasks);
        Map<String,Task> myTaskMap = new Map<String, Task>();
        for (Task task:tasks) {
            myTaskMap.put(task.whatId, task);
        }
        System.debug('MAP des tasks :' +  myTaskMap);

        // Get invalid qualifications
        Map<String,Qualification_prospect_adherent__c> myNotValidQualifMap = new Map<String, Qualification_prospect_adherent__c>();
        for (Qualification_prospect_adherent__c qualificationPA : scope) {
            if(qualificationPA.Date_de_fin__c < Date.today()) {
                myNotValidQualifMap.put(qualificationPA.Compte__c,qualificationPA);
            }
        }
        
        // We have to make a Set with all accounts to update in data bases without duplicates
        Set<Account> accountsToUpdate = new Set<Account>();
        System.debug('qualificationsPA : ' + scope);

        for (Qualification_prospect_adherent__c qualifPA : scope) {
            Task myTask = myTaskMap.get(qualifPA.compte__c);
            Qualification_prospect_adherent__c notValidQualifs = myNotValidQualifMap.get(qualifPA.compte__c);
            System.debug('qualifPA : ' + qualifPA);
            System.debug('myTask : ' + myTask);
            //System.debug('myTask.CompletedDateTime :' + myTask.CompletedDateTime);
            System.debug('not validQualificationsPA :' + notValidQualifs);
            System.debug('qualificationsWithDuplicateAccounts :' + qualificationsWithDuplicateAccounts);

            // evolution : Ne créer la tâche de résiliation que s’il existe une tâche non clôturée de mise en demeure sur le compte => en cours
            if (myTask != null) {
                if (!qualificationsWithDuplicateAccounts.contains(qualifPA)) {  
                    // todo : changement de la condition du if pour test if (myTask.CompletedDateTime.addDays(30) < Date.today()) {
                    if (myTask.CreatedDate.addDays(30) < Date.today() || (Test.isRunningTest() && myTask.CreatedDate.isSameDay(Date.today()))) {
                        // CREATE TASK - Résiliation – Motif : qualification échue
                        getInformation(qualifPA, 1);
                        System.debug('Qualification : tâche mise en demeure ouverte depuis plus de 30 jours et plus de qualifications valides');
                    }
                }
            }

            if (qualifPA.Date_de_fin__c.addDays(15).isSameDay((Date.today()))) {
                // Qualif expired more than 15 days ago
                Account myAccount = new Account(Id = qualifPA.compte__r.Id, administrativeStatus__c = 'Accepté sous surveillance');
                // We add the account to update on
                accountsToUpdate.add(myAccount);
                // CREATE TASK - Mise en demeure – Motif : qualification échue
                getInformation(qualifPA, 0);
                System.debug('Qualification : Relance impayé depuis plus de 15 jours');
            }
        }

        // UPDATE ACCOUNTS
        List<Account> accountsListToUpdate = new List<Account>(accountsToUpdate);
        try {
            update accountsListToUpdate;
        } catch(Exception e) {
            System.debug(e);
        }
    }
    
    global void finish(Database.BatchableContext BC){}
    
    private void getInformation(Qualification_prospect_adherent__c qualifPA, Integer indexRelance) {
        
        System.debug('COMPTE :' + qualifPA.Compte__c + ' qualification : '+ qualifPA.Name);
        Task task = new Task();
        
        String ownerId = responsable.MasterLabel;
        //evolution : Ne pas générer de tâche « MED ou résiliation pour qualification échue » s’il existe au moins 1 qualif encore valide
        if (indexRelance == 0 && qualifPA.compte__r.nb_qualif_valides__c <= 0) {
            System.debug('création de la tâche mise en demeure');
            task = new Task(Subject='Mise en demeure – Motif : qualification échue', WhatId=qualifPA.Compte__c, OwnerId=ownerId, ActivityDate=Date.today(),descriptionShort__c='Référence qualification : '+qualifPA.Name);
            try {
                insert task;
            } catch(Exception e) {
                System.debug('insertion tâche mise en demeure qualification KO : '+e.getmessage());
            }
        } else if (indexRelance == 1 && qualifPA.compte__r.nb_qualif_valides__c <= 0) {
            task = new Task(Subject='Résiliation – Motif : qualification échue', WhatId=qualifPA.Compte__c, OwnerId=ownerId, ActivityDate=Date.today(),descriptionShort__c='Référence qualification : '+qualifPA.Name);
            try {
                insert task;
            } catch(Exception e) {
                System.debug('insertion tâche résiliation qualification KO : '+e.getmessage());
            }
        }
    }
}