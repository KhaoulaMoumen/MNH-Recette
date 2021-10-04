/* 

* Copyright (C) EuraNov -- All Rights Reserved
* Unauthorized copying of this file, via any medium is strictly prohibited
* Proprietary and confidential
* Written by Nathan Martin <nathan@euranov.com>, July 2019
* Edited by Khaoula MOUMEN <khaoula.moumen@talan.com>, June 2020


*/
@isTest
private class EUR04_UnpaidQualifFormNotTriggeredTest {
    static testMethod void EUR04_UnpaidQualifFormNotTriggeredTest() {
        
        // --- Test data setup ---
        Date dateBefore20Days = Date.today().addDays(-15);
        Date dateAfter20Days = Date.today().addDays(20);
        Date beginDate = Date.today().addMonths(-6);
        
        
        // CREATE USER WITH PROFIL SYSTEM ADMINISTRATOR
        List<User> ownersTest = DataFactory.createUsers(1, Label.Profile_Systeme_Administrateur_Name, true, true, true, true);
        
        // RUN AS ADMINISTRATOR
        System.runAs(ownersTest[0]){
            
            // CREATE ACCOUNTS
            List<Account> accountsTest = DataFactory.createAccounts(2, 'Adhérent', 'Accepté', true);
            
            // CREATE LEADS
            List<Lead> leadsTest = DataFactory.createLeads(1, true);
            
            leadsTest[0].nb_assur_valides__c = 0;
            update leadsTest[0];
            
            accountsTest[0].nb_assur_valides__c = 0;
            update accountsTest[0];
            
            // CREATE QUALIFICATION
            List<Qualifications__c> qualificationsTest = DataFactory.createQualifications(1, true);
            
            // CREATE QUALIFICATION PROSPECT ADHERENT RELATED TO ACCOUNT THAT EXPIRED IN 20 DAYS
            List<Qualification_prospect_adherent__c> expiredQualifSince20Days = DataFactory.createQualificationsPH(1, accountsTest[0].Id,  NULL, beginDate, dateBefore20Days, true);
            
            // CREATE QUALIFICATION PROSPECT ADHERENT RELATED TO ACCOUNT
            List<Qualification_prospect_adherent__c> qualifTest1 = DataFactory.createQualificationsPH(1, accountsTest[0].Id,  NULL, beginDate, dateAfter20Days, true);
            
            List<Qualification_prospect_adherent__c> qualifTest2 = DataFactory.createQualificationsPH(2, accountsTest[1].Id,  NULL, beginDate, dateAfter20Days, true);
            List<Qualification_prospect_adherent__c> expiredQualifSince20Days1 = DataFactory.createQualificationsPH(1, accountsTest[1].Id,  NULL, beginDate, dateBefore20Days, true);
            
            List<Qualification_prospect_adherent__c> qualifTest3 = DataFactory.createQualificationsPH(2, NULL, leadsTest[0].Id, beginDate, dateAfter20Days, true);
            
            
            // CREATE TASK Mise en demeure – Motif : qualification échue
            List<Task> taskTest = DataFactory.createTaches(1, 'Mise en demeure – Motif : qualification échue', accountsTest[0].Id, ownersTest[0].Id, Date.today(), true);
            
            
            // --- Testing ---
            Test.startTest();
            
            qualifTest1[0].Date_de_fin__c = dateBefore20Days;
            update qualifTest1[0];
            
            qualifTest2[1].Date_de_fin__c = dateBefore20Days;
            update qualifTest2[1];
            
            qualifTest3[0].Date_de_fin__c = dateBefore20Days;
            update qualifTest3[0];
            
            delete expiredQualifSince20Days[0];
            delete qualifTest2[0];
            delete qualifTest3[1];
            
            // UPDATE TASK STATUS
            taskTest[0].Status = 'Confirmer';            
            update taskTest[0];
            
            
            String CRON_EXP = '0 0 0 3 9 ? 2022';
            // Schedule the test job
            String jobId = System.schedule('SchBT07_AccountValidAssurQualif', CRON_EXP, new SchBT07_AccountValidAssurQualif());
            // Get the information from the CronTrigger API object 
            CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId]; 
            // Verify the expressions are the same System.assertEquals(CRON_EXP, ct.CronExpression); 
            // Verify the job has not run 
            System.assertEquals(0, ct.TimesTriggered); 
            // Verify the next time the job will run 
            System.assertEquals('2022-09-03 00:00:00', String.valueOf(ct.NextFireTime));  
            
            Test.stopTest();
        }
        // --- Verify ---
        // TODO Nothing to test currently
    }
}