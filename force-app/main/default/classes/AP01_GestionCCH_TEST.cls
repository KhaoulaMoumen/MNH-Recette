/*
TEST CLASS
EditedBy : MOUMEN Khaoula
@Email : khaoula.moumen@talan.com
Date : 05/06/2020
*/
@isTest(SeeAllData=false)
public class AP01_GestionCCH_TEST {

    static testmethod void changeOwner() {
        
        Test.startTest();

        // CREATE USER WITH PROFIL SYSTEM ADMINISTRATOR
        List<User> usersTest = DataFactory.createUsers(1, Label.Profile_Systeme_Administrateur_Name, false, false, false, true);

        // CREATE AN ACCOUNT
        List<Account> accountsTest = DataFactory.createAccounts(1, 'Adhérent', 'Accepté', true);

        // CREATE CERCLE CONFORT HABITAT
        List<Cercle_Confort_Habitat__c> cchTest = DataFactory.createCCHs(1, usersTest[0].Id, 'CCH-LYON', true);

        // CREATE CERCLE CONFORT HABITAT ADHERENT
        List<Cercle_confort_habitat_adh_rent__c> cchATest = DataFactory.createCCHAdhrents(1, accountsTest[0].Id, cchTest[0].Id, usersTest[0].Id, true);

        // DELETE CERCLE CONFORT HABITAT ADHERENT
        delete cchATest[0];
        
        Test.stopTest();
    }
    
    static testmethod void changeOwnerFromCCH() {
        
        Test.startTest();

        // CREATE 2 USERS WITH PROFIL SYSTEM ADMINISTRATOR
        List<User> usersTest = DataFactory.createUsers(2, Label.Profile_Systeme_Administrateur_Name, false, false, false, true);

        // CREATE CERCLE CONFORT HABITAT
        List<Cercle_Confort_Habitat__c> cchTest1 = DataFactory.createCCHs(1, usersTest[0].Id, 'CCH-PARIS', true);
        List<Cercle_Confort_Habitat__c> cchTest2 = DataFactory.createCCHs(1, usersTest[0].Id, 'CCH-AGEN', true);

        Cercle_Confort_Habitat__c aCCH1 = cchTest1[0];
        Cercle_Confort_Habitat__c aCCH2 = cchTest2[0];

        // UPDATE CERCLE CONFORT HABITAT OWNER TO USER2
        aCCH1.OwnerId = usersTest[1].Id;
        update aCCH1;

        // UPDATE CERCLE CONFORT HABITAT OWNER TO USER2
        aCCH2.OwnerId = usersTest[1].Id;
        update aCCH2;
        Test.stopTest();
    }
}