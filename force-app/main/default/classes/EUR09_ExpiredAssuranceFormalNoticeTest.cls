/* 
	* Copyright (C) EuraNov -- All Rights Reserved
	* Unauthorized copying of this file, via any medium is strictly prohibited
	* Proprietary and confidential
	* Written by Nathan Martin <nathan@euranov.com>, July 2019
    * Edited by Khaoula MOUMEN <khaoula.moumen@talan.com>, March 2020
    * Edited by Khaoula MOUMEN <khaoula.moumen@talan.com>, June 2020
*/
@isTest
private class EUR09_ExpiredAssuranceFormalNoticeTest {
    static testMethod void EUR09_ExpiredAssuranceFormalNoticeTest() {
        // --- Test data setup ---
        Date dateAfter15Days = Date.today().addDays(-15);
        Date dateBefore15Days = Date.today().addDays(15);
        Date dateAfter7Days = Date.today().addDays(-7);
        Date beginDate = Date.today().addMonths(-6);
        
        // CREATE USER WITH PROFIL SYSTEM ADMINISTRATOR = OWNER With bypass on pb to bypass process builder creation tache mise en demeure (probleme recurrent de post chatter dans le pb sur les sbx)
        List<User> usersTest = DataFactory.createUsers(1, Label.Profile_Systeme_Administrateur_Name, false, true, false, true);
       
       // CREATE ACCOUNTS
       List<Account> accountsTest = DataFactory.createAccounts(4, 'Adhérent', 'Accepté', true);

       // CREATE 2 AUTHORIZED ASSURANCES 
       List<Assurance__c> assurancesAut = DataFactory.createAssurances(2, 'Autorisée', true);

       // CREATE ASSURANCE TOLEREE
       List<Assurance__c> assurancesTol = DataFactory.createAssurances(2, 'Tolérée', true);

       // CREATE ASSURANCES INTERDITE
       List<Assurance__c> assuranceInterdite = DataFactory.createAssurances(1, 'Interdite', true);

      // CREATE ASSURANCES PROSPECT ADHERENT RELATED TO ACCOUNT EXPIRED IN 15 DAYS - AUTORISEE
      List<Assurances__c> expiredAutAssuranceSince15Days = DataFactory.createAssurancesPH(1, assurancesAut[0].Id, accountsTest[0].Id, NULL, beginDate, dateAfter15Days, 'Responsabilité civile', true);
      List<Assurances__c> expiredAutAssuranceSince15Days2 = DataFactory.createAssurancesPH(1, assurancesAut[1].Id, accountsTest[2].Id, NULL, beginDate, dateAfter15Days, 'Responsabilité civile', true);
   
      // CREATE ASSURANCES PROSPECT ADHERENT RELATED TO ACCOUNT EXPIRED IN LAST/NEXT 15 DAYS - TOLEREE
      List<Assurances__c> expiredTolAssuranceSince15Days = DataFactory.createAssurancesPH(1, assurancesTol[0].Id, accountsTest[1].Id, NULL, beginDate, dateBefore15Days, 'Responsabilité civile', true);
      List<Assurances__c> expiredTolAssuranceSince15Days2 = DataFactory.createAssurancesPH(1, assurancesTol[1].Id, accountsTest[2].Id, NULL, beginDate, dateAfter15Days, 'Responsabilité civile', true);
   
      // CREATE ASSURANCES PROSPECT ADHERENT RELATED TO ACCOUNT EXPIRED IN 15 DAYS - INTERDITE
      List<Assurances__c> expiredFordiddenAssuranceSince7Days = DataFactory.createAssurancesPH(1, assuranceInterdite[0].Id, accountsTest[3].Id, NULL, beginDate, dateAfter15Days, 'Responsabilité civile', true);
      
      expiredFordiddenAssuranceSince7Days[0].Date_de_derniere_relance__c = dateAfter7Days;
      update expiredFordiddenAssuranceSince7Days[0];

        // --- Testing ---
        Test.startTest();

        System.runAs(usersTest[0]){

        // CREATE TASK Mise en demeure – Motif : assurance échue
        List<Task> taskTest1 = DataFactory.createTaches(1, 'Mise en demeure – Motif : assurance échue', accountsTest[0].Id, usersTest[0].Id, Date.today(), true);
        List<Task> taskTest2 = DataFactory.createTaches(1, 'Mise en demeure – Motif : assurance échue', accountsTest[1].Id, usersTest[0].Id, Date.today(), true);
        List<Task> taskTest3 = DataFactory.createTaches(1, 'Mise en demeure – Motif : assurance échue', accountsTest[1].Id, usersTest[0].Id, Date.today(), true);

        
        String CRON_EXP = '0 0 0 3 9 ? 2022';
        // Schedule the test job
        String jobId = System.schedule('SchedulerTE', CRON_EXP, new SchBT03_ExpiredAssuranceFormalNotice());
        // Get the information from the CronTrigger API object 
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId]; 
        // Verify the expressions are the same System.assertEquals(CRON_EXP, ct.CronExpression); 
        // Verify the job has not run 
        System.assertEquals(0, ct.TimesTriggered); 
        // Verify the next time the job will run 
        System.assertEquals('2022-09-03 00:00:00', String.valueOf(ct.NextFireTime)); 
    }
        Test.stopTest();
        
        // --- Verify ---
        // Now that the scheduled job has executed after Test.stopTest(),
        Assurances__c expiredAutAssuranceSince15DaysResult = [SELECT Id, Name, Date_de_fin__c, Dernier_niveau_de_relance__c, Date_de_derniere_relance__c, Statut__c FROM Assurances__c WHERE Id = :expiredAutAssuranceSince15Days[0].Id];
        System.debug('expiredAutAssuranceSince15Days :' + expiredAutAssuranceSince15DaysResult);
        System.debug('expiredAutAssuranceSince15Days Dernier niveau de relance :' + expiredAutAssuranceSince15DaysResult.Dernier_niveau_de_relance__c);
        System.debug('expiredAutAssuranceSince15Days Date_de_derniere_relance__c :' + expiredAutAssuranceSince15DaysResult.Date_de_derniere_relance__c);
        System.debug('expiredAutAssuranceSince15Days Statut__c :' + expiredAutAssuranceSince15DaysResult.Statut__c);
        System.debug('expiredAutAssuranceSince15Days Name :' + expiredAutAssuranceSince15DaysResult.Name);
        System.debug('Date_de_fin__c de l\'assurance :' + expiredAutAssuranceSince15DaysResult.Date_de_fin__c);
        
        Account accountOfAutAssurSinceFifeteenDaysResult = [SELECT administrativeStatus__c, relanceDate__c, Name FROM Account WHERE Id = :accountsTest[0].id];
        System.debug('accountOfAutAssurSinceFifeteenDaysResult :' + accountOfAutAssurSinceFifeteenDaysResult.Name);
        System.debug('accountOfAutAssurSinceFifeteenDaysResult administrativeStatus__c :' + accountOfAutAssurSinceFifeteenDaysResult.administrativeStatus__c);
        System.debug('accountOfAutAssurSinceFifeteenDaysResult relanceDate__c :' + accountOfAutAssurSinceFifeteenDaysResult.relanceDate__c);
        String expectedAdministrativeStatus = 'Accepté sous surveillance';
        Date expectedDateDeDerniereRelance = Date.today();
        System.assertEquals(expectedAdministrativeStatus, accountOfAutAssurSinceFifeteenDaysResult.administrativeStatus__c);
        //System.assertEquals(expectedDateDeDerniereRelance, accountOfAutAssurSinceFifeteenDaysResult.relanceDate__c);
        
        Account accountOfTolAssurSinceFifeteenDaysResult = [SELECT administrativeStatus__c, relanceDate__c FROM Account WHERE Id = :accountsTest[1].id];        
        System.debug('accountOfTolAssurSinceFifeteenDaysResult administrativeStatus__c :' + accountOfTolAssurSinceFifeteenDaysResult.administrativeStatus__c);
        System.debug('accountOfTolAssurSinceFifeteenDaysResult relanceDate__c :' + accountOfTolAssurSinceFifeteenDaysResult.relanceDate__c); 
        System.assertEquals(expectedAdministrativeStatus, accountOfTolAssurSinceFifeteenDaysResult.administrativeStatus__c);
        //System.assertEquals(expectedDateDeDerniereRelance, accountOfTolAssurSinceFifeteenDaysResult.relanceDate__c);
        
        Account accountOfForbiddenAssurSinceFifeteenDaysResult = [SELECT administrativeStatus__c, relanceDate__c FROM Account WHERE Id = :accountsTest[2].id];
        String expectedAdministrativeStatus3 = 'Accepté sous surveillance';
        Date expectedDateDeDerniereRelance3 = Date.today();
        System.assertEquals(expectedAdministrativeStatus3, accountOfTolAssurSinceFifeteenDaysResult.administrativeStatus__c);
        //System.assertEquals(expectedDateDeDerniereRelance3, accountOfTolAssurSinceFifeteenDaysResult.relanceDate__c);
    }
}