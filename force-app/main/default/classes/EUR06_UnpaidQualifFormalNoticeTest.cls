/* 
	* Copyright (C) EuraNov -- All Rights Reserved
	* Unauthorized copying of this file, via any medium is strictly prohibited
	* Proprietary and confidential
	* Written by Nathan Martin <nathan@euranov.com>, July 2019
	* Edited by Khaoula MOUMEN <khaoula.moumen@talan.com>, March 2020
	* Edited by Khaoula MOUMEN <khaoula.moumen@talan.com>, June 2020

*/
@isTest
private class EUR06_UnpaidQualifFormalNoticeTest {
    static testMethod void EUR06_UnpaidQualifFormalNoticeTest() {
        
        // --- Test data setup ---
        Date dateBeforeFifeteenDays = Date.today().addDays(-15);
        Date beginDate = Date.today().addMonths(-6);
        
        // CREATE USER WITH PROFIL SYSTEM ADMINISTRATOR = OWNER With bypass on pb to bypass process builder creation tache mise en demeure (probleme recurrent de post chatter dans le pb sur les sbx)
        List<User> usersTest = DataFactory.createUsers(1, Label.Profile_Systeme_Administrateur_Name, false, true, false, true);
       
        // CREATE ACCOUNTS
         List<Account> accountsTest = DataFactory.createAccounts(2, 'Adhérent', 'Accepté', true);

        // CREATE QUALIFICATION
        List<Qualifications__c> qualificationsTest = DataFactory.createQualifications(1, true);

        // CREATE QUALIFICATION PROSPECT ADHERENT RELATED TO ACCOUNT EXPIRED IN 50 DAYS
        List<Qualification_prospect_adherent__c> expiredQualifSinceFifeteenDays = DataFactory.createQualificationsPH(1, accountsTest[0].Id,  NULL, beginDate, dateBeforeFifeteenDays, true);
        List<Qualification_prospect_adherent__c> expiredQualifSinceFifeteenDays2 = DataFactory.createQualificationsPH(1, accountsTest[1].Id,  NULL, beginDate, dateBeforeFifeteenDays, true);
        List<Qualification_prospect_adherent__c> expiredQualifSinceFifeteenDays3 = DataFactory.createQualificationsPH(1, accountsTest[1].Id,  NULL, beginDate, dateBeforeFifeteenDays, true);

        
        // --- Testing ---
        Test.startTest();

        System.runAs(usersTest[0]){

            // CREATE TASK Mise en demeure – Motif : qualification échue
        List<Task> taskTest = DataFactory.createTaches(1, 'Mise en demeure – Motif : qualification échue', accountsTest[0].Id, usersTest[0].Id, Date.today().addMonths(-1), true);
      
            String CRON_EXP = '0 0 0 3 9 ? 2022';
            // Schedule the test job
        	String jobId = System.schedule('SchedulerTE', CRON_EXP, new SchBT02_UnpaidQualifFormalNotice());
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
        Account accountOfQualifSinceFifeteenDaysResult = [SELECT administrativeStatus__c, relanceDate__c FROM Account WHERE Id = :accountsTest[0].id]; 
        String expectedAdministrativeStatus = 'Accepté sous surveillance';
        System.debug('final statut administratif'+ accountOfQualifSinceFifeteenDaysResult.administrativeStatus__c);
        System.assertEquals(expectedAdministrativeStatus, accountOfQualifSinceFifeteenDaysResult.administrativeStatus__c);
    }
}