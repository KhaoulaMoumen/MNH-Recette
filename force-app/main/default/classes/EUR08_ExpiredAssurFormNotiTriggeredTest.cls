/* 

 * Copyright (C) EuraNov -- All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 * Written by Nathan Martin <nathan@euranov.com>, July 2019
 * Edited by Khaoula MOUMEN <khaoula.moumen@talan.com>, June 2020

 */
@isTest
private class EUR08_ExpiredAssurFormNotiTriggeredTest {
    static testMethod void EUR08_ExpiredAssurFormNotiTriggeredTest() {
        // --- Test data setup ---
        Date dateBefore20Days = Date.today().addDays(-20);
        Date beginDate = Date.today().addMonths(-6);

        // CREATE USER WITH PROFIL SYSTEM ADMINISTRATOR = OWNER With bypass on pb to bypass process builder creation tache mise en demeure (probleme recurrent de post chatter dans le pb sur les sbx)
        List<User> usersTest = DataFactory.createUsers(1, Label.Profile_Systeme_Administrateur_Name, false, true, false, true);
       
        // CREATE ACCOUNTS
         List<Account> accountsTest = DataFactory.createAccounts(4, 'Adhérent', 'Accepté', true);

         // CREATE ASSURANCES AUTHORIZED
         List<Assurance__c> assuranceTest = DataFactory.createAssurances(2, 'Autorisée', true);

        // CREATE ASSURANCES PROSPECT ADHERENT RELATED TO ACCOUNT EXPIRED IN 20 DAYS
        List<Assurances__c> expiredAssuranceSince20Days = DataFactory.createAssurancesPH(1, assuranceTest[0].Id, accountsTest[0].Id, NULL, beginDate, dateBefore20Days, 'Responsabilité civile', true);
   
        System.runAs(usersTest[0]){

        // CREATE TASK Mise en demeure – Motif : assurance échue
        List<Task> taskTest = DataFactory.createTaches(1, 'Mise en demeure – Motif : assurance échue', accountsTest[0].Id, usersTest[0].Id, Date.today(), true);
        
        // --- Testing ---
        Test.startTest();
        
        // UPDATE TASK STATUS
        taskTest[0].Status = 'Confirmer';            
        update taskTest[0];
        
        Test.stopTest();
     }

        // --- Verify ---
        // TODO Nothing to test currently
    }
}