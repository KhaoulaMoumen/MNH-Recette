/* 
	* Copyright (C) EuraNov -- All Rights Reserved
	* Unauthorized copying of this file, via any medium is strictly prohibited
	* Proprietary and confidential
	* Written by Catherine DELEGLISE <catherine@euranov.com>, July 2019
    * Edited by Khaoula MOUMEN <khaoula.moumen@talan.com>, March 2020
    * Edited by Khaoula MOUMEN <khaoula.moumen@talan.com>, June 2020

*/
@isTest(SeeAllData=false)
private class EUR15_RelanceFinOffreDecouverteTest {
    static testmethod void testRelanceFinOffreDecouverte(){

        // CREATE ACCOUNTS
        List<Account> accountsTest = DataFactory.createAccounts(1, 'Adhérent', 'Accepté', true);

        // CREATE CONTACTS
        List<Contact> contactsTest = DataFactory.createContacts(1, accountsTest[0].Id, 'Interlocuteur administratif', true);

        // CREATE EXPIRED CONVENTIONS ANNUELLES 
        List<Convention_annuelle__c> convention = DataFactory.createConventionsAnnuelles(1, accountsTest[0].Id, Date.today().year(), Date.today().addMonths(-5), Date.today().addMonths(6), Label.Contract_Pack_RecordTypeId, true);
       
        Test.startTest();
        String CRON_EXP = '0 0 0 3 9 ? 2022';
            // Schedule the test job
            String jobId = System.schedule('SchedulerTE', CRON_EXP, new SchBT04_RelanceFinOffreDecouverte());
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