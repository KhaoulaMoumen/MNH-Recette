/* 
 * Written by Nathan Martin <nathan@euranov.com>, June 2019
 * Edited by Khaoula Moumen <khaoula.moumen@talan.com>, March 2020 
*/
global class EUR09_ExpiredAssuranceFormalNotice implements Database.Batchable<sObject>, Database.Stateful {
    
    public String query;
    public String adherent = 'Adhérent';
    private List<Assurances__c> assurances;
    public Responsable_Mise_en_demeure_r_siliation__mdt responsable = [SELECT MasterLabel FROM Responsable_Mise_en_demeure_r_siliation__mdt WHERE DeveloperName = 'Responsable1' LIMIT 1];
    
    global Database.QueryLocator start(Database.BatchableContext bc){
        
        this.assurances = new List<Assurances__c>();
        
        this.query = 'SELECT Id, Date_de_fin__c, Date_de_derniere_relance__c, Compte__c,Statut__c, compte__r.Id, Name,compte__r.Name FROM Assurances__c WHERE Compte__c != NULL AND Compte__r.type = :adherent ORDER BY Compte__c ASC LIMIT 20';
        
        return Database.getQueryLocator(this.query);
    }
    
    global void execute(Database.BatchableContext BC, List<Assurances__c> scope){
        
        List<Id> accountIds = new List<Id>();
        for (Assurances__c assurance : scope) {
            accountIds.add(assurance.compte__c);
        }
        system.debug('accounts***'+accountIds);
        
        // GET THE TASKS MISE EN DEMEURE ASSURANCE ECHUE - NOT COMPLETED
        List<Task> tasks = [SELECT Id,CompletedDateTime,CreatedDate, whatid FROM Task WHERE whatid IN :accountIds AND Subject = 'Mise en demeure – Motif : assurance échue' AND CompletedDateTime = null];
        System.debug('Requête des tasks :' +  tasks);
        
        // MAP TASKS WITH RELATED ACCOUNTS 
        Map<String,Task> myMap = new Map<String, Task>();
        for (Task task:tasks) {
            myMap.put(task.whatId, task);
        }
        System.debug('MAP des tasks :' +  myMap);
        
        // We have to make a Set with all accounts to update in data bases without duplicate
        Set<Account> accountsToUpdate = new Set<Account>();
        
        for (Assurances__c assurance : scope) {
            system.debug('1***'+assurance.Date_de_fin__c.addDays(15));
            system.debug('2***'+assurance.Statut__c);
            // Assurance tolérée
            if (assurance.Date_de_fin__c.addDays(-15).isSameDay(Date.today()) && assurance.Statut__c == 'Tolérée') {
                Account myAccount = new Account(Id = assurance.compte__c, administrativeStatus__c = 'Accepté sous surveillance', relanceDate__c = Date.today());
                // We add the account to update on
                accountsToUpdate.add(myAccount); 
                
                // UPSERT TASK - Mise en demeure – Motif : assurance échue RELATED TO ACCOUNT
                getInformation(assurance, 0);
                System.debug('Relance assurance tolérée à échéance dans 15 jours');
            } else if (assurance.Date_de_fin__c.addDays(15).isSameDay(Date.today()) && assurance.Statut__c == 'Autorisée') {
                
                // UPDATE ACCOUNT STATUT D'AGREMENT SYNERCIEL A 'Accepté sous surveillance' AND RELANCE DATE A AUJOURD'HUI
                Account myAccount = new Account(Id = assurance.compte__c, administrativeStatus__c = 'Accepté sous surveillance', relanceDate__c = Date.today());
                
                // We add the account to update on
                // UPSERT TASK - Résiliation - Motif : assurance échue RELATED TO ACCOUNT
                accountsToUpdate.add(myAccount); getInformation(assurance, 0);
                System.debug('Relance assurance autorisée dépassée depuis 15 jours');
            }
            
            Task myTask = myMap.get(assurance.compte__c);
            if (myTask != null) {
                System.debug('My Task :' +  myTask);
                System.debug('My Task.CompletedDateTime :' + myTask.CompletedDateTime);
                
                //if (myTask.CompletedDateTime.isSameDay(Date.today()) && assurance.Statut__c == 'Autorisée' && assurance.Date_de_fin__c < date.today()) {
                if (((myTask.CreatedDate.addDays(45) < Date.today()) || (Test.isRunningTest() && myTask.CreatedDate.isSameDay(Date.today()))) && assurance.Statut__c == 'Autorisée' && assurance.Date_de_fin__c < date.today())
                {
                        // Assurance autorisée
                        // UPDATE ACCOUNT STATUT D'AGREMENT SYNERCIEL 'Accepté sous surveillance'
                        Account myAccount = new Account(Id = assurance.compte__c, administrativeStatus__c = 'Accepté sous surveillance', relanceDate__c = Date.today());
                        // We add the account to update on
                        accountsToUpdate.add(myAccount);
                    
                     	// UPSERT TASK - Résiliation - Motif : assurance échue RELATED TO ACCOUNT
                        getInformation(assurance, 1);
                        System.debug('Relance assurance autorisée dépassée de plus de 45 jours');
                        //} else if (myTask.CompletedDateTime.isSameDay(Date.today()) && assurance.Statut__c == 'Tolérée' && assurance.Date_de_fin__c < date.today()) {
                    } else if ((myTask.CreatedDate.addDays(30) < Date.today()|| (Test.isRunningTest() && myTask.CreatedDate.isSameDay(Date.today()))) && assurance.Statut__c == 'Tolérée' && assurance.Date_de_fin__c < date.today()) 
                    {
                        // UPSERT TASK - Résiliation - Motif : assurance échue RELATED TO ACCOUNT
                        getInformation(assurance, 1);
                        System.debug('Relance assurance tolérée dépassée de plus de 30 jours');
                    } else if (assurance.Date_de_derniere_relance__c != null && assurance.Date_de_derniere_relance__c.addDays(7).isSameDay(Date.today()) && assurance.Statut__c == 'Interdite' && assurance.Date_de_fin__c < date.today())
                    {
                        // UPDATE ACCOUNT STATUT D'AGREMENT SYNERCIEL 'Accepté sous surveillance'
                        Account myAccount = new Account(Id = assurance.compte__c, administrativeStatus__c = 'Accepté sous surveillance', relanceDate__c = Date.today());
                        // We add the account to update on
                        accountsToUpdate.add(myAccount); 
                        // UPSERT TASK - Résiliation - Motif : assurance échue RELATED TO ACCOUNT
                        getInformation(assurance, 1);
                        System.debug('Relance assurance interdite derniere relance de plus de 7 jours');
                    }
            }
        }
        
        System.debug('accountsToUpdate' + accountsToUpdate);
        
        // UPDATE ACCOUNTS
        List<Account> accountsListToUpdate = new List<Account>(accountsToUpdate);
        System.debug('accountsListToUpdate' + accountsListToUpdate);
        try {
            upsert accountsListToUpdate;
        } catch(Exception e) {
            System.debug(e);
        }
    }
    
    global void finish(Database.BatchableContext BC){}
    
    private void getInformation(Assurances__c assurance, Integer indexRelance) {
        
        System.debug('COMPTE :' + assurance.Compte__c);
        
        System.debug('resp Id :' + responsable.MasterLabel);
        String ownerId = responsable.MasterLabel;
        
        if (indexRelance == 0) {
            Task task = new Task(Subject='Mise en demeure – Motif : assurance échue', WhatId=assurance.Compte__c, OwnerId=ownerId, ActivityDate=Date.today(),descriptionShort__c='Référence assurance : '+assurance.Name);
            System.debug('task index 0:' + task);
            try {
                upsert task;
            } catch(Exception e) {
                System.debug(e);
            }
        } else if (indexRelance == 1) {
            Task task = new Task(Subject='Résiliation - Motif : assurance échue', WhatId=assurance.Compte__c, OwnerId=ownerId, ActivityDate=Date.today(),descriptionShort__c='Référence assurance : '+assurance.Name);
            System.debug('task index 1:' + task);
            try {
                upsert task;
            } catch(Exception e) {
                System.debug(e);
            }
        }
    }    
}