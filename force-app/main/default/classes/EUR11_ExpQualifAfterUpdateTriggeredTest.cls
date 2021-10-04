/* 

 * Copyright (C) EuraNov -- All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 * Written by Nathan Martin <nathan@euranov.com>, July 2019
 * Edited by Khaoula MOUMEN <khaoula.moumen@talan.com>, June 2020
 
*/
@isTest(SeeAllData=false)
private class EUR11_ExpQualifAfterUpdateTriggeredTest {
    static testMethod void EUR11_ExpQualifAfterUpdateTriggeredTest() {

        // --- Test data setup ---
        Date dateBeforeTenDays = Date.today().addDays(-10);
        Date dateBeforeFourDays = Date.today().addDays(-4);
        Date dateAfterFifeteenDays = Date.today().addDays(15);
        Date beginDate = Date.today().addMonths(-6);

        // CREATE USER WITH PROFIL SYSTEM ADMINISTRATOR = OWNER With bypass on pb to bypass process builder creation tache mise en demeure (probleme recurrent de post chatter dans le pb sur les sbx)
        List<User> usersTest = DataFactory.createUsers(1, Label.Profile_Systeme_Administrateur_Name, false, true, false, true);
       
       // CREATE ACCOUNTS
       List<Account> accountsTest = DataFactory.createAccounts(3, 'Adhérent', 'Accepté', true);

        // CREATE QUALIFICATION
        List<Qualifications__c> qualificationsTest = DataFactory.createQualifications(1, true);

        // CREATE QUALIFICATION PROSPECT ADHERENT RELATED TO ACCOUNT EXPIRED IN 10 DAYS
        List<Qualification_prospect_adherent__c> expiredQualifSinceTenDays = DataFactory.createQualificationsPH(1, accountsTest[0].Id,  NULL, beginDate, dateBeforeTenDays, true);
        
        // CREATE QUALIFICATION PROSPECT ADHERENT RELATED TO ACCOUNT EXPIRED IN 4 DAYS
        List<Qualification_prospect_adherent__c> expiredQualifSinceFourDays = DataFactory.createQualificationsPH(1, accountsTest[1].Id,  NULL, beginDate, dateBeforeFourDays, true);
        
        // CREATE VALID QUALIFICATION PROSPECT ADHERENT RELATED TO ACCOUNT THE WILL EXPIRE IN THE NEXT 15 DAYS
        List<Qualification_prospect_adherent__c> validQualifInFifeteenDays = DataFactory.createQualificationsPH(1, accountsTest[2].Id,  NULL, beginDate, dateAfterFifeteenDays, true);

        // Qualification_prospect_adherent__c expiredQualifInFifeteenDaysDuplicate1 = new Qualification_prospect_adherent__c(Compte__c=duplicate_compte.Id, Date_de_debut__c = beginDate, Date_de_fin__c = dateBeforeFifeteenDays, Metier_de_reference__c = metierDeReference.id);  
        // insert expiredQualifInFifeteenDaysDuplicate1;
        // Qualification_prospect_adherent__c expiredQualifSinceFifeteenDaysDuplicate2 = new Qualification_prospect_adherent__c(Compte__c=duplicate_compte.Id, Date_de_debut__c = beginDate, Date_de_fin__c = dateBeforeFifeteenDays, Metier_de_reference__c = metierDeReference.id);  
        // insert expiredQualifSinceFifeteenDaysDuplicate2;

        System.runAs(usersTest[0]){

        // CREATE TASK Mise en demeure – Motif : qualification échue FOR THE THREE ACCOUNTS 
        List<Task> taskTest1 = DataFactory.createTaches(1, 'Mise en demeure – Motif : qualification échue', accountsTest[0].Id, usersTest[0].Id, Date.today(), true);
        List<Task> taskTest2 = DataFactory.createTaches(1, 'Mise en demeure – Motif : qualification échue', accountsTest[1].Id, usersTest[0].Id, Date.today(), true);
        List<Task> taskTest3 = DataFactory.createTaches(1, 'Mise en demeure – Motif : qualification échue', accountsTest[2].Id, usersTest[0].Id, Date.today(), true);

        
        // --- Testing ---
        Test.startTest();

        Qualification_prospect_adherent__c expiredQualifAfter7daysToUpdate = [SELECT Id, compte__r.id FROM Qualification_prospect_adherent__c WHERE Id = :expiredQualifSinceTenDays[0].id];
        Qualification_prospect_adherent__c expiredQualifBefore7DaysToUpdate = [SELECT Id, compte__r.id  FROM Qualification_prospect_adherent__c WHERE Id = :expiredQualifSinceFourDays[0].id];
        Qualification_prospect_adherent__c validQualifInFifeteenDaysToUpdate = [SELECT Id, compte__r.id  FROM Qualification_prospect_adherent__c WHERE Id = :validQualifInFifeteenDays[0].id];
        
        // todo modifier task pour la compléter
        Task taskOfExpiredQualifAfter7days = [SELECT Id, Status FROM Task WHERE whatid = :expiredQualifAfter7daysToUpdate.compte__r.id];
        taskOfExpiredQualifAfter7days.Status = 'Confirmer';
        Task taskOfExpiredQualifBefore7Days = [SELECT Id, Status FROM Task WHERE whatid = :expiredQualifBefore7DaysToUpdate.compte__r.id];
        taskOfExpiredQualifBefore7Days.Status = 'Confirmer';
        Task taskOfValidQualifInFifeteenDays = [SELECT Id, Status FROM Task WHERE whatid = :validQualifInFifeteenDaysToUpdate.compte__r.id];
        taskOfValidQualifInFifeteenDays.Status = 'Confirmer';
        // taskOfExpiredQualifAfter7days.completed_date_time == Date.today();

        update taskOfExpiredQualifAfter7days;
        update taskOfExpiredQualifBefore7Days;
        update taskOfValidQualifInFifeteenDays;

        Test.stopTest();

        // --- Verify ---
        // Now that the scheduled job has executed after Test.stopTest(),
        Account accountOfQualifSinceFifeteenDaysResult = [SELECT administrativeStatus__c, relanceDate__c FROM Account WHERE Id = :accountsTest[0].id];
        // Account accountOfQualifSinceFifeteenDaysResult = [SELECT administrativeStatus__c, relanceDate__c FROM Account WHERE Id = :compte2.id];
        // Account accountOfQualifSinceFifeteenDaysResult = [SELECT administrativeStatus__c, relanceDate__c FROM Account WHERE Id = :compte1.id];
        // Task 
        String expectedAdministrativeStatus = 'En attente comité risque';
        Date expectedDateDeDerniereRelance = Date.today();
        // System.assertEquals(expectedAdministrativeStatus, accountOfQualifSinceFifeteenDaysResult.administrativeStatus__c);
        // System.assertEquals(expectedDateDeDerniereRelance, accountOfQualifSinceFifeteenDaysResult.relanceDate__c);
        // System.assertEquals(expectedDateDeDerniereRelance, expiredQualifSinceSevenDaysResult.Date_de_derniere_relance__c);
        // System.assertEquals(expectedDernieriveauDeRelance1, expiredQualifSinceOneDayResult.Dernier_niveau_de_relance__c);
        // System.assertEquals(expectedDateDeDerniereRelance, expiredQualifSinceOneDayResult.Date_de_derniere_relance__c);
        // System.assertEquals(expectedDernieriveauDeRelance0, expiredQualifInOneMonthResult.Dernier_niveau_de_relance__c);
        // System.assertEquals(expectedDateDeDerniereRelance, expiredQualifInOneMonthResult.Date_de_derniere_relance__c);
    }
}
}