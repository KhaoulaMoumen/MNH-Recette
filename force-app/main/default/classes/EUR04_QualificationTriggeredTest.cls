/* 

 * Copyright (C) EuraNov -- All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 * Written by Nathan Martin <nathan@euranov.com>, July 2019

 */
@isTest
private class EUR04_QualificationTriggeredTest {
    static testMethod void EUR04_QualificationTriggeredTest() {

        // --- Test data setup ---
        Date endDate = Date.today().addMonths(6);
        Date beginDate = Date.today().addMonths(-6);

        // CREATE ACCOUNTS
        List<Account> accountsTest = DataFactory.createAccounts(1, 'Adhérent', 'Accepté', true);

        // CREATE LEADS
        List<Lead> leadsTest = DataFactory.createLeads(1, true);

        // CREATE QUALIFICATION
        List<Qualifications__c> qualificationsTest = DataFactory.createQualifications(1, true);

        // CREATE VALID QUALIFICATION PROSPECT ADHERENT RELATED TO ACCOUNT
        List<Qualification_prospect_adherent__c> validQualifTest1 = DataFactory.createQualificationsPH(1, accountsTest[0].Id,  NULL, beginDate, endDate, true);

        // CREATE VALID QUALIFICATION PROSPECT ADHERENT RELATED TO LEAD
        List<Qualification_prospect_adherent__c> validQualifTest4 = DataFactory.createQualificationsPH(1, NULL, leadsTest[0].Id, beginDate, endDate, true);

        // CREATE USER WITH PROFIL SYSTEM ADMINISTRATOR
         List<User> usersTest = DataFactory.createUsers(1, Label.Profile_Systeme_Administrateur_Name, true, true, false, true);
        
        // RUN AS ADMINISTRATOR
         System.runAs(usersTest[0]){

        // --- Testing ---
        Test.startTest();

        // INSERT & DELETE VALID QUALIFICATION PA RELATED TO ACCOUNT
        List<Qualification_prospect_adherent__c> validQualifTest2 = DataFactory.createQualificationsPH(1, accountsTest[0].Id,  NULL, beginDate, endDate, true);
        delete validQualifTest1[0];

        // INSERT & DELETE VALID QUALIFICATION PA RELATED TO LEAD
        List<Qualification_prospect_adherent__c> validQualifTest3 = DataFactory.createQualificationsPH(1, NULL,  leadsTest[0].Id, beginDate, endDate, true);
        delete validQualifTest4[0];

        Test.stopTest();

         }
    }
}