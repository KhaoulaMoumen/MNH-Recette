/* 

 * Copyright (C) EuraNov -- All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 * Written by Nathan Martin <nathan@euranov.com>, July 2019
 * Edited by Khaoula MOUMEN <khaoula.moumen@talan.com>, June 2020

 */
@isTest
private class ExpiredQualificationWarnerTest {
    static testMethod void ExpiredQualificationWarnerTest() {

        // --- Test data setup ---
        Date dateBeforeSevenDays = Date.today().addDays(-7);
        Date dateBeforeOneDay = Date.today().addDays(-1);
        Date dateAfterOneMonth = Date.today().addMonths(1);
        Date beginDate = Date.today().addMonths(-6);

        // CREATE ACCOUNTS
         List<Account> accountsTest = DataFactory.createAccounts(3, 'Adhérent', 'Accepté', true);

        // CREATE QUALIFICATION
        List<Qualifications__c> qualificationsTest = DataFactory.createQualifications(1, true);

        // CREATE QUALIFICATION PROSPECT ADHERENT RELATED TO ACCOUNT EXPIRED IN 7 DAYS
        List<Qualification_prospect_adherent__c> expiredQualifSinceSevenDays = DataFactory.createQualificationsPH(1, accountsTest[0].Id,  NULL, beginDate, dateBeforeSevenDays, true);
        
        // CREATE QUALIFICATION PROSPECT ADHERENT RELATED TO ACCOUNT EXPIRED IN 1 DAYS
        List<Qualification_prospect_adherent__c> expiredQualifSinceOneDay = DataFactory.createQualificationsPH(1, accountsTest[1].Id,  NULL, beginDate, dateBeforeOneDay, true);
        
        // CREATE QUALIFICATION PROSPECT ADHERENT RELATED TO ACCOUNT EXPIRED IN 1 MONTH
        List<Qualification_prospect_adherent__c> expiredQualifInOneMonth = DataFactory.createQualificationsPH(1, accountsTest[2].Id,  NULL, beginDate, dateAfterOneMonth, true);

        // CREATE QUALIFICATION PROSPECT ADHERENT RELATED TO ACCOUNT EXPIRED IN 1 MONTH DUPLICATED
        List<Qualification_prospect_adherent__c> expiredQualifInOneMonthDup = DataFactory.createQualificationsPH(1, accountsTest[2].Id,  NULL, beginDate, dateAfterOneMonth, true);


        // --- Testing ---
        Test.startTest();

        String CRON_EXP = '0 0 0 3 9 ? 2022';
        // Schedule the test job
        String jobId = System.schedule('SchedulerTE', CRON_EXP, new ExpiredQualificationWarner());
        // Get the information from the CronTrigger API object 
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId]; 
        // Verify the expressions are the same System.assertEquals(CRON_EXP, ct.CronExpression); 
        // Verify the job has not run 
        System.assertEquals(0, ct.TimesTriggered); 
        // Verify the next time the job will run 
        System.assertEquals('2022-09-03 00:00:00', String.valueOf(ct.NextFireTime));  
        Test.stopTest();

        // --- Verify ---
        // Now that the scheduled job has executed after Test.stopTest(),
        Qualification_prospect_adherent__c expiredQualifSinceSevenDaysResult = [SELECT Dernier_niveau_de_relance__c, Date_de_derniere_relance__c  FROM Qualification_prospect_adherent__c WHERE Id = :expiredQualifSinceSevenDays[0].id];
        Qualification_prospect_adherent__c expiredQualifSinceOneDayResult = [SELECT Dernier_niveau_de_relance__c, Date_de_derniere_relance__c  FROM Qualification_prospect_adherent__c WHERE Id = :expiredQualifSinceOneDay[0].id];
        Qualification_prospect_adherent__c expiredQualifInOneMonthResult = [SELECT Dernier_niveau_de_relance__c, Date_de_derniere_relance__c  FROM Qualification_prospect_adherent__c WHERE Id = :expiredQualifInOneMonth[0].id];
        String expectedDernieriveauDeRelance2 = 'Relance niveau 2';
        String expectedDernieriveauDeRelance1 = 'Relance niveau 1';
        String expectedDernieriveauDeRelance0 = 'Relance préventive';
        Date expectedDateDeDerniereRelance = Date.today();
        System.assertEquals(expectedDernieriveauDeRelance2, expiredQualifSinceSevenDaysResult.Dernier_niveau_de_relance__c);
        System.assertEquals(expectedDateDeDerniereRelance, expiredQualifSinceSevenDaysResult.Date_de_derniere_relance__c);
        System.assertEquals(expectedDernieriveauDeRelance1, expiredQualifSinceOneDayResult.Dernier_niveau_de_relance__c);
        System.assertEquals(expectedDateDeDerniereRelance, expiredQualifSinceOneDayResult.Date_de_derniere_relance__c);
    }
}