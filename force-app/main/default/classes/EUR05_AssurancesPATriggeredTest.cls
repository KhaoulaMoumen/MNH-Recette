/* 

* Copyright (C) EuraNov -- All Rights Reserved
* Unauthorized copying of this file, via any medium is strictly prohibited
* Proprietary and confidential
* Written by Catherine DELEGLISE <catherine@euranov.com>, september 2019
* Edited by Khaoula MOUMEN <khaoula.moumen@talan.com>, June 2020

*/
@isTest(SeeAllData=false)
private class EUR05_AssurancesPATriggeredTest {
    static testMethod void EUR05_AssurancesPATriggeredTest() {
        
        // --- Test data setup ---
        Date endDate = Date.today().addMonths(6);
        Date beginDate = Date.today().addMonths(-6);
        
        
        // CREATE ACCOUNTS
        List<Account> accountsTest = DataFactory.createAccounts(1, 'Adhérent', 'Accepté sous surveillance', true);
        
        // CREATE LEADS
        List<Lead> leadsTest = DataFactory.createLeads(1, true);
        
        // CREATE ASSURANCE AUTHORIZED
        List<Assurance__c> assuranceTest = DataFactory.createAssurances(1, 'Autorisée', true);
        
        // CREATE USER WITH PROFIL SYSTEM ADMINISTRATOR = OWNER
        List<User> usersTest = DataFactory.createUsers(1, Label.Profile_Systeme_Administrateur_Name, false, false, false, true);
        
        // RUN AS ADMINISTRATOR
        System.runAs(usersTest[0]){
            
            // --- Testing ---
            Test.startTest();
            
            // CREATE ASSURANCES PROSPECT ADHERENT RELATED TO ACCOUNT
            List<Assurances__c> assurancesPA1 = DataFactory.createAssurancesPH(1, assuranceTest[0].Id, accountsTest[0].Id, NULL, beginDate, endDate, 'Responsabilité civile', true);
            List<Assurances__c> assurancesPA2 = DataFactory.createAssurancesPH(1, assuranceTest[0].Id, accountsTest[0].Id, NULL, beginDate, endDate, 'Responsabilité civile', true);
            
            //UPDATE ASSURANCE PA
            assurancesPA1[0].Date_de_fin__c = Date.today().addMonths(-2);
            update assurancesPA1[0];
            
            // DELETE ASSURANCE PA RELATED TO ACCOUNT
            delete assurancesPA2[0];
            
            // CREATE ASSURANCES PROSPECT ADHERENT RELATED TO LEAD
            List<Assurances__c> assurancesPA3 = DataFactory.createAssurancesPH(1, assuranceTest[0].Id, NULL, leadsTest[0].Id, beginDate, endDate, 'Responsabilité civile', true);
            List<Assurances__c> assurancesPA4 = DataFactory.createAssurancesPH(1, assuranceTest[0].Id, NULL, leadsTest[0].Id, beginDate, endDate, 'Responsabilité civile', true);
            
            // DELETE ASSURANCE PA RELATED TO LEAD
            delete assurancesPA4[0];
            
            // COVER BATCH 
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
        
    }
}