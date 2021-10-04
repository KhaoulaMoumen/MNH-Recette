/* 

 * Copyright (C) EuraNov -- All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 * Written by Nathan Martin <nathan@euranov.com>, June 2019
* Edited by Khaoula MOUMEN <khaoula.moumen@talan.com>, June 2020

 */
@isTest(SeeAllData = true)
private class ToleratedExpiredAssuranceWarnerTest {

    static testMethod void testToleratedExpiredAssuranceWarner() {
        // --- Test data setup ---
        Date dateBeforeFourMonths = Date.today().addDays(120);
        Date dateBeforeOneMonth = Date.today().addDays(30);
        Date dateBeforeSevenDays = Date.today().addDays(7);
        Date beginDate = Date.today().addMonths(-6);

    // CREATE ACCOUNTS
    List<Account> accountsTest = DataFactory.createAccounts(4, 'Adhérent', 'Accepté', true);

    // CREATE ASSURANCE TOLEREE
    List<Assurance__c> assurancesTol = DataFactory.createAssurances(4, 'Tolérée', true);

    // CREATE ASSURANCES PROSPECT ADHERENT RELATED TO ACCOUNT EXPIRED IN LAST/NEXT 4 MONTH - TOLEREE
    List<Assurances__c> expiredAssuranceInFourMonths = DataFactory.createAssurancesPH(1, assurancesTol[0].Id, accountsTest[1].Id, NULL, beginDate, dateBeforeFourMonths, 'Responsabilité civile', true);
    
    // CREATE ASSURANCES PROSPECT ADHERENT RELATED TO ACCOUNT EXPIRED IN LAST/NEXT 1 MONTH - TOLEREE
    List<Assurances__c> expiredAssuranceInOneMonth = DataFactory.createAssurancesPH(1, assurancesTol[1].Id, accountsTest[0].Id, NULL, beginDate, dateBeforeOneMonth, 'Responsabilité civile', true);
    
    // CREATE ASSURANCES PROSPECT ADHERENT RELATED TO ACCOUNT EXPIRED IN LAST/NEXT 1 MONTH - TOLEREE
    List<Assurances__c> expiredAssuranceForSevenDays = DataFactory.createAssurancesPH(1, assurancesTol[2].Id, accountsTest[2].Id, NULL, beginDate, dateBeforeSevenDays, 'Responsabilité civile', true);
    
   // CREATE ASSURANCES PROSPECT ADHERENT RELATED TO ACCOUNT EXPIRED IN LAST/NEXT 7 DAYS - TOLEREE
    List<Assurances__c> expiredDuplicateAssurance1 = DataFactory.createAssurancesPH(1, assurancesTol[3].Id, accountsTest[3].Id, NULL, beginDate, dateBeforeSevenDays, 'Responsabilité civile', true);
    
    // CREATE ASSURANCES PROSPECT ADHERENT RELATED TO ACCOUNT EXPIRED IN LAST/NEXT 7 DAYS - TOLEREE - DUPLICATE
    List<Assurances__c> expiredDuplicateAssurance2 = DataFactory.createAssurancesPH(1, assurancesTol[3].Id, accountsTest[3].Id, NULL, beginDate, dateBeforeSevenDays, 'Responsabilité civile', true);
    
        // --- Testing ---
        Test.startTest();

        String CRON_EXP = '0 0 0 3 9 ? 2022';
        // Schedule the test job
        String jobId = System.schedule('SchedulerTE', CRON_EXP, new BA06_ToleratedExpiredAssuranceWarner());
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
        Assurances__c expiredAssuranceInOneMonthResult = [SELECT Id, Dernier_niveau_de_relance__c, Date_de_derniere_relance__c FROM Assurances__c WHERE Id = :expiredAssuranceInOneMonth[0].Id];
        System.debug('expiredAssuranceInOneMonthResult :' + expiredAssuranceInOneMonthResult);
        System.debug('expiredAssuranceInOneMonthResult Dernier niveau de relance :' + expiredAssuranceInOneMonthResult.Dernier_niveau_de_relance__c);
        System.debug('expiredAssuranceInOneMonthResult Date_de_derniere_relance__c :' + expiredAssuranceInOneMonthResult.Date_de_derniere_relance__c);
        String expectedDernieriveauDeRelance = 'Relance préventive';
        Date expectedDateDeDerniereRelance = Date.today();
        //System.assertEquals(expectedDernieriveauDeRelance, expiredAssuranceInOneMonthResult.Dernier_niveau_de_relance__c);
        //System.assertEquals(expectedDateDeDerniereRelance, expiredAssuranceInOneMonthResult.Date_de_derniere_relance__c);
        
        Assurances__c expiredAssuranceInFourMonthsResult = [SELECT Id, Dernier_niveau_de_relance__c, Date_de_derniere_relance__c FROM Assurances__c WHERE Id = :expiredAssuranceInFourMonths[0].Id];
        System.debug('expiredAssuranceInFourMonthsResult :' + expiredAssuranceInFourMonthsResult);
        System.debug('expiredAssuranceInFourMonthsResult Dernier niveau de relance :' + expiredAssuranceInFourMonthsResult.Dernier_niveau_de_relance__c);
        System.debug('expiredAssuranceInFourMonthsResult Date_de_derniere_relance__c :' + expiredAssuranceInFourMonthsResult.Date_de_derniere_relance__c);
        String expectedDernieriveauDeRelance2 = 'Relance préventive';
        Date expectedDateDeDerniereRelance2 = Date.today();
        //System.assertEquals(expectedDernieriveauDeRelance2, expiredAssuranceInFourMonthsResult.Dernier_niveau_de_relance__c);
        //System.assertEquals(expectedDateDeDerniereRelance2, expiredAssuranceInFourMonthsResult.Date_de_derniere_relance__c);
        
        Assurances__c expiredAssuranceForSevenDaysResult = [SELECT Id, Dernier_niveau_de_relance__c, Date_de_derniere_relance__c FROM Assurances__c WHERE Id = :expiredAssuranceForSevenDays[0].Id];
        String expectedDernieriveauDeRelance3 = 'Relance niveau 2';
        Date expectedDateDeDerniereRelance3 = Date.today();
        //System.assertEquals(expectedDernieriveauDeRelance3, expiredAssuranceForSevenDaysResult.Dernier_niveau_de_relance__c);
        //System.assertEquals(expectedDateDeDerniereRelance3, expiredAssuranceForSevenDaysResult.Date_de_derniere_relance__c);
    }
}