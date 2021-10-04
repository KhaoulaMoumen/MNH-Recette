/*
EditedBy : MOUMEN Khaoula
@Email : khaoula.moumen@talan.com
Date : 08/06/2020
 */
@isTest(seeAllData=false)
public class BatchUpdateCompteQualite_TEST {

    /**
     * Ici on teste que le compte a été mis à jour car le statut d'assurance est passé à Autorisée
     * et la date de fin > à la date du jour
     */
    @isTest
    static void testUpdateQualiteAssurancesOk() {

        Test.startTest();

        // CREATE USER WITH PROFIL SYSTEM ADMINISTRATOR
       List<User> usersTest = DataFactory.createUsers(1, Label.Profile_Systeme_Administrateur_Name, false, false, false, true);
        
       System.runAs(usersTest[0])
       { 

        // CREATE ACCOUNTS
        List<Account> accountsTest = DataFactory.createAccounts(1, 'Adhérent', 'Accepté', true);

        // CREATE ASSURANCES
        List<Assurance__c> assurancesTest = DataFactory.createAssurances(1, 'Tolérée', true);
        
        // CREATE ASSURANCES PROSPECT ADHERENT
        List<Assurances__c> assuranceRespCivile = DataFactory.createAssurancesPH(1, assurancesTest[0].Id, accountsTest[0].Id, NULL, Date.today().addDays(-60), Date.today().addDays(3), 'Responsabilité civile', true);

        List<Assurances__c> assuranceDecennale = DataFactory.createAssurancesPH(1, assurancesTest[0].Id, accountsTest[0].Id, NULL, Date.today().addDays(-60), Date.today().addDays(3), 'Décennale', true);

        Assurance__c testAss = [SELECT Id, Statut_Assurance__c FROM Assurance__c WHERE Id = :assurancesTest[0].Id];
        
        system.debug('*********'+testAss);

        BatchUpdateCompteQualite batch = new BatchUpdateCompteQualite();
        Database.executeBatch(batch);

        Account compte = [SELECT Id, Name, Qualite_assurances__c FROM Account WHERE Id = :accountsTest[0].Id];

        //System.assertEquals('OK', compte.Qualite_assurances__c);
       }
        Test.stopTest();
    }

    /**
     * ici on teste qu'on n'a pas mis à jour le compte car le statut d'assurance n'est pas le bon
     * malgré que la date de fin soit > à la date du jour 
     */
    @isTest
    static void testUpdateQualiteAssurancesKo() {

        Test.startTest();

        // CREATE USER WITH PROFIL SYSTEM ADMINISTRATOR
       List<User> usersTest = DataFactory.createUsers(1, Label.Profile_Systeme_Administrateur_Name, false, false, false, true);
        
       System.runAs(usersTest[0])
       { 

        // CREATE ACCOUNTS
        List<Account> accountsTest = DataFactory.createAccounts(1, 'Adhérent', 'Accepté', true);

        // CREATE ASSURANCES
        List<Assurance__c> assurancesTest = DataFactory.createAssurances(1, 'Interdite', true);

        // CREATE ASSURANCES PROSPECT ADHERENT
        List<Assurances__c> assuranceRespCivile1 = DataFactory.createAssurancesPH(1, assurancesTest[0].Id, accountsTest[0].Id, NULL, Date.today().addDays(-60), Date.today().addDays(-3), 'Responsabilité civile', true);
         
        List<Assurances__c> assuranceRespCivile2 = DataFactory.createAssurancesPH(1, assurancesTest[0].Id, accountsTest[0].Id, NULL, Date.today().addDays(-60), Date.today().addDays(3), 'Décennale', true);

        BatchUpdateCompteQualite batch = new BatchUpdateCompteQualite();
        
        Database.executeBatch(batch);

        Account compte = [SELECT Id, Name, Qualite_assurances__c FROM Account WHERE Id = :accountsTest[0].Id];

        System.assertEquals('PAS OK', compte.Qualite_assurances__c);
       }

        Test.stopTest();
    }

    /**
     * Ici on teste que le compte a été mis à jour car la date de fin d'une assurance est > à la date du jour
     */
    @isTest
    static void testUpdateQualiteQualificationOk() {

        Test.startTest();

        // CREATE USER WITH PROFIL SYSTEM ADMINISTRATOR
       List<User> usersTest = DataFactory.createUsers(1, Label.Profile_Systeme_Administrateur_Name, false, false, false, true);
        
       System.runAs(usersTest[0])
       { 

        // CREATE ACCOUNTS
        List<Account> accountsTest = DataFactory.createAccounts(1, 'Adhérent', 'Accepté', true);

        // CREATE LEAD
        List<Lead> leadsTest = DataFactory.createLeads(1, true);

        // CREATE QUALIFICATION
        List<Qualifications__c> qualificationsTest = DataFactory.createQualifications(1, true);

        // CREATE QUALIFICATION PROSPECT ADHERENT
        List<Qualification_prospect_adherent__c> qualificationsRespCivile = DataFactory.createQualificationsPH(1, accountsTest[0].Id, leadsTest[0].Id, Date.today().addDays(-60), Date.today().addDays(3), true);

        List<Qualification_prospect_adherent__c> qualificationsDecennale = DataFactory.createQualificationsPH(1, accountsTest[0].Id, leadsTest[0].Id, Date.today().addDays(-60), Date.today().addDays(3), true);

        BatchUpdateCompteQualite batch = new BatchUpdateCompteQualite();
        Database.executeBatch(batch);

        Account compte = [SELECT Id, Name, Qualite_qualifications__c FROM Account WHERE Id = :accountsTest[0].Id];

        //System.assertEquals('OK', compte.Qualite_qualifications__c);
       }
        Test.stopTest();
    }

    /**
     * ici on teste qu'on n'a pas mis à jour le compte car les dates de fin des assurances sont < à la date du jour 
     */
    @isTest
    static void testUpdateQualiteQualificationKo() {

        Test.startTest();

        // CREATE USER WITH PROFIL SYSTEM ADMINISTRATOR
       List<User> usersTest = DataFactory.createUsers(1, Label.Profile_Systeme_Administrateur_Name, false, false, false, true);
        
       System.runAs(usersTest[0])
       { 

        // CREATE ACCOUNTS
        List<Account> accountsTest = DataFactory.createAccounts(1, 'Adhérent', 'Accepté', true);

        // CREATE LEAD
        List<Lead> leadsTest = DataFactory.createLeads(1, true);

        // CREATE QUALIFICATION
        List<Qualifications__c> qualificationsTest = DataFactory.createQualifications(1, true);

        // CREATE QUALIFICATION PROSPECT ADHERENT
        List<Qualification_prospect_adherent__c> qualificationsRespCivile = DataFactory.createQualificationsPH(1, NULL, leadsTest[0].Id, Date.today().addDays(-60), Date.today().addDays(-3), true);

        List<Qualification_prospect_adherent__c> qualificationsDecennale = DataFactory.createQualificationsPH(1, NULL, leadsTest[0].Id, Date.today().addDays(-60), Date.today().addDays(-3), true);

        BatchUpdateCompteQualite batch = new BatchUpdateCompteQualite();
        Database.executeBatch(batch);

        Account compte = [SELECT Id, Name, Qualite_qualifications__c FROM Account WHERE Id = :accountsTest[0].Id];

        System.assertEquals('PAS OK', compte.Qualite_qualifications__c);
       }

        Test.stopTest();
    }

     /**
     * Ici on teste que le compte a été mis à jour car le champ situation financière est passé à En règele
     */
    @isTest
    static void testUpdateQualiteSituationFinanciereOk() {

        Test.startTest();

        // CREATE USER WITH PROFIL SYSTEM ADMINISTRATOR
        List<User> usersTest = DataFactory.createUsers(1, Label.Profile_Systeme_Administrateur_Name, false, false, false, true);
        
        System.runAs(usersTest[0])
        { 
        // CREATE ACCOUNTS
        List<Account> accountsTest = DataFactory.createAccounts(1, 'Adhérent', 'Accepté', true);

        accountsTest[0].Situation_financiere__c = 'En règle';
        update accountsTest[0];
        
        BatchUpdateCompteQualite batch = new BatchUpdateCompteQualite();
        Database.executeBatch(batch);

        Account compte = [SELECT Id, Name, Qualite_situation_financiere__c FROM Account WHERE Id = :accountsTest[0].Id];

        //System.assertEquals('OK', compte.Qualite_situation_financiere__c);            
        }    
        
        Test.stopTest();

    }

    /**
     * ici on teste qu'on n'a pas mis à jour le compte 
     */
    @isTest
    static void testUpdateQualiteSituationFinanciereKo() {

        Test.startTest();
        
       // CREATE USER WITH PROFIL SYSTEM ADMINISTRATOR
       List<User> usersTest = DataFactory.createUsers(1, Label.Profile_DAF, false, false, false, true);
        
       System.runAs(usersTest[0])
       { 
        // CREATE ACCOUNTS
        List<Account> accountsTest = DataFactory.createAccounts(1, 'Adhérent', 'Accepté', true);

        accountsTest[0].Situation_financiere__c = 'A recouvrer';
        update accountsTest[0];
        
        BatchUpdateCompteQualite batch = new BatchUpdateCompteQualite();
        Database.executeBatch(batch);

        Account compte = [SELECT Id, Name, Qualite_situation_financiere__c FROM Account WHERE Id = :accountsTest[0].Id];

        System.assertEquals('PAS OK', compte.Qualite_situation_financiere__c);
    } 
            
        Test.stopTest();
    }
}