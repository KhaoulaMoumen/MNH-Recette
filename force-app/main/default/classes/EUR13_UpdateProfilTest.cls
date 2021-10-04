/* 

 * Copyright (C) EuraNov -- All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 * Written by Nathan Martin <nathan@euranov.com>, July 2019
 * Edited by Khaoula MOUMEN <khaoula.moumen@talan.com>, June 2020

 */
@isTest
private class EUR13_UpdateProfilTest {
    static testMethod void EUR13_UpdateProfilTest() {
        // --- Test data setup ---
        Date endDate=Date.today().addDays(-7);
        Date endDate4years = Date.today().addYears(-4);
        Date beginDate = Date.today().addYears(-6);
        Date begindate4years = Date.today().addYears(-5);
        Integer thisYear = Date.today().year();

        // CREATE ACCOUNTS
        List<Account> accountsTest = DataFactory.createAccounts(3, 'Adhérent', 'Accepté', true);

        // CREATE EXPIRED CONVENTIONS ANNUELLES 
        List<Convention_annuelle__c> convAnnuel1 = DataFactory.createConventionsAnnuelles(1, accountsTest[0].Id, endDate.year(), beginDate, endDate, Label.Contract_Pack_RecordTypeId, true);
        
        // CREATE Convention plus valable depuis  plus de 3 ans
        List<Convention_annuelle__c> convAnnuel2 = DataFactory.createConventionsAnnuelles(1, accountsTest[1].Id, endDate4years.year(), begindate4years, endDate4years, Label.Contract_Pack_RecordTypeId, true);
        
        // CREATE Convention encore valable 
        List<Convention_annuelle__c> convAnnRunning = DataFactory.createConventionsAnnuelles(1, accountsTest[1].Id, thisYear, Date.today().addDays(-300), Date.today().addDays(7), Label.Contract_Option_RecordTypeId, true);
        
        // Convention  plus valable depuis  plus de 3 ans 
        List<Convention_annuelle__c> convAnn4 = DataFactory.createConventionsAnnuelles(1, accountsTest[2].Id, endDate4years.year(), begindate4years, endDate4years, Label.Contract_Pack_RecordTypeId, true);

        // --- Testing ---
        Test.startTest();

        String CRON_EXP = '0 0 0 3 9 ? 2022';
        // Schedule the test job
        String jobId = System.schedule('SchedulerTE', CRON_EXP, new EUR13_UpdateProfil());
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