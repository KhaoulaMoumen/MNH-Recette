/* 

 * Copyright (C) EuraNov -- All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 * Written by Nathan Martin <nathan@euranov.com>, June 2019

 */
global class UnpaidFormalNotice implements Schedulable {
    
    // TODO changer le Batch Schedule dans l'exec du batch car c'est le nom que l'on voit apparaitre dans sales force
    // GET RESPONSABLE MISE EN DEMEURE RESILIATION - METADATA
    public Responsable_Mise_en_demeure_r_siliation__mdt responsable = [SELECT MasterLabel FROM Responsable_Mise_en_demeure_r_siliation__mdt WHERE DeveloperName = 'Responsable1' LIMIT 1];

    global void execute(System.SchedulableContext sc) {
        String adherent = 'Adhérent';
        // GET ALL UNPAID FACTURES RELATED TO ACCOUNTS
        List<Facture__c> factures = [SELECT Id, Etat_de_la_facture__c, Date_d_ch_ance__c, Nom_du_compte__c, N_de_Facture_NAV__c, Nom_du_compte__r.relanceDate__c, Nom_du_compte__r.administrativeStatus__c, Name
                                     FROM Facture__c 
                                     WHERE Etat_de_la_facture__c IN ('Unpaid','Partly_paid','Impayée') AND Montant_TTC_Proratise__c > 0 AND Nom_du_compte__c != null AND Nom_du_compte__r.type=:adherent 
                                     ORDER BY Nom_du_compte__c];
        
        List<Id> accountIds = new List<Id>();
        // FILL LIST WITH IDS OF ACCOUNTS RELATED TO FACTURES
        for (Facture__c facture:factures) {
            accountIds.add(facture.Nom_du_compte__c);
        }

        // GET TASKS MISE EN DEMEURE MOTIF IMPAYES RELATED TO ACCOUNTS
        List<Task> tasks = [SELECT Id,CompletedDateTime,whatid FROM Task WHERE whatid IN :accountIds AND Subject = 'Mise en demeure – Motif : impayés'];
        System.debug('Requête des tasks :' +  tasks);
        Map<String,Task> myMap = new Map<String, Task>();
        for (Task task:tasks) {
            System.debug('Alimentation de la Map :' +  tasks);
            myMap.put(task.whatId, task);
        }

        // We have to make a Set with all accounts to update in data bases without duplicate
        Set<Account> accountsToUpdate = new Set<Account>();

        for (Facture__c facture:factures) {
            Task myTask = myMap.get(facture.Nom_du_compte__c);
            if (myTask != null && myTask.CompletedDateTime != null) {
                System.debug('My Task :' +  myTask);
                System.debug('My Task.CompletedDateTime :' + myTask.CompletedDateTime);
                // J+45 after formal notice task closed
                // TASK COMPLETED IN THE LAST 45 DAYS
                if (myTask.CompletedDateTime.addDays(45) < Date.today()) {
                    // CREATE TASK - Résiliation - Motif : impayés
                    getInformation(facture, 1);
                    System.debug('Relance dont la tâche a été cloturée depuis plus de 45 jours');
                }
            }
            if (facture.Date_d_ch_ance__c.addDays(30) == Date.today()) {
                // facture expired more than 30 days ago
                // FACTURE EXPIRED IN 30 DAYS 
                Account myAccount = new Account(Id = facture.Nom_du_compte__r.Id, administrativeStatus__c = 'En attente comité risque', relanceDate__c = Date.today(), situation_financiere__c = 'En impayé');
                // We add the account to update on
                accountsToUpdate.add(myAccount);
                // CREATE TASK - Mise en demeure – Motif : impayés
                getInformation(facture, 0);
                System.debug('Relance impayé depuis plus de 30 jours');
            }
        }

        List<Account> accountsListToUpdate = new List<Account>(accountsToUpdate);
        try {
            // UPDATE ACCOUNTS
            upsert accountsListToUpdate;
        } catch(Exception e) {
            System.debug(e);
        }
    }

    private void getInformation(Facture__c facture, Integer indexRelance) {
        
        System.debug('COMPTE :' + facture.Nom_du_compte__c);
        Task task = new Task();

        String ownerId = responsable.MasterLabel;

        if (indexRelance == 0) {
            task = new Task(Subject='Mise en demeure – Motif : impayés', WhatId=facture.Nom_du_compte__c, OwnerId=ownerId, ActivityDate=Date.today(),descriptionShort__c='Référence facture'+facture.Name);
        }
        else if (indexRelance == 1) {
            task = new Task(Subject='Résiliation - Motif : impayés', WhatId=facture.Nom_du_compte__c, OwnerId=ownerId, ActivityDate=Date.today(),descriptionShort__c='Référence facture'+facture.Name);
        }

        try {
            insert task;
        } catch(Exception e) {
            System.debug(e);
        }
    }
}