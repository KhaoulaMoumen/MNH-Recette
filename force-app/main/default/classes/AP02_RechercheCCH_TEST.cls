/*
TEST CLASS
EditedBy : MOUMEN Khaoula
@Email : khaoula.moumen@talan.com
Date : 05/06/2020
*/
@isTest(seeAllData=false)
private class  AP02_RechercheCCH_TEST {
   
    static void initData() {

        // CREATE USERS WITH PROFIL SYSTEM ADMINISTRATOR
        List<User> usersTest = DataFactory.createUsers(2, Label.Profile_Systeme_Administrateur_Name, false, false, false, true);
 
        // CREATE CERCLE CONFORT HABITAT PARIS
        List<Cercle_Confort_Habitat__c> cchTest1 = DataFactory.createCCHs(1, usersTest[0].Id, 'CCH-PARIS', true);

        // CREATE CERCLE CONFORT HABITAT AGEN
        List<Cercle_Confort_Habitat__c> cchTest2 = DataFactory.createCCHs(1, usersTest[0].Id, 'CCH-AGEN', true);

        // CREATE ACCOUNTS
        List<Account> accountsTest = DataFactory.createAccounts(3, 'Adhérent', 'Accepté', true);
        
        // CREATE CONTACTS
        List<Contact> contactsTest1 = DataFactory.createContacts(1, accountsTest[0].Id, 'Interlocuteur administratif', true);
        List<Contact> contactsTest2 = DataFactory.createContacts(1, accountsTest[1].Id, 'Interlocuteur administratif', true);
        List<Contact> contactsTest3 = DataFactory.createContacts(1, accountsTest[2].Id, 'Interlocuteur administratif', true);

        // CREATE ZONES DE CHALANDISE RELATED TO FIRST ACCOUNT
        List<Zone_de_chalandise__c> zonesTest1 = DataFactory.createZonesChalandise(1, accountsTest[0].Id, '75 Paris', true);
        List<Zone_de_chalandise__c> zonesTest2 = DataFactory.createZonesChalandise(1, accountsTest[1].Id, '92 Hauts-de-Seine', true);
        List<Zone_de_chalandise__c> zonesTest3 = DataFactory.createZonesChalandise(1, accountsTest[2].Id, '47 Lot-et-Garonne', true);

        // CREATE METIERS DE REFERENCE 
        List<Metier_de_reference__c> metiersTest1 = DataFactory.createMetiersRef(1, accountsTest[0].Id, NULL, 'Electricien', true, true);
        List<Metier_de_reference__c> metiersTest2 = DataFactory.createMetiersRef(1, accountsTest[0].Id, NULL, 'Climaticien', false, true);
        List<Metier_de_reference__c> metiersTest3 = DataFactory.createMetiersRef(1, accountsTest[1].Id, NULL, 'Carreleur', true, true);
        List<Metier_de_reference__c> metiersTest4 = DataFactory.createMetiersRef(1, accountsTest[2].Id, NULL, 'Electricien', true, true);

        // CREATE CERCLE CONFORT HABITAT ADHERENT
        List<Cercle_confort_habitat_adh_rent__c> cchATest1 = DataFactory.createCCHAdhrents(1, accountsTest[0].Id, cchTest1[0].Id, usersTest[0].Id, true);
        List<Cercle_confort_habitat_adh_rent__c> cchATest2 = DataFactory.createCCHAdhrents(1, accountsTest[1].Id, cchTest1[0].Id, usersTest[0].Id, true);
        List<Cercle_confort_habitat_adh_rent__c> cchATest3 = DataFactory.createCCHAdhrents(1, accountsTest[2].Id, cchTest2[0].Id, usersTest[0].Id, true);

        // on fait sortir l'artisan
        cchATest2[0].Date_sortie_CCH__c = Date.today().addMonths(-1);
        update cchATest2[0];
    }
    
    /**
     * Ici on teste que le WS retourne bien un seul CCH (celui de paris) car on a envoyé le code postal 75007
     * Et que d'après notre jeu d'essai on a bien 2 artisans qui ont une zone de chalandise à Paris
     * mais un seul est encore adhérent
     */
    @isTest 
    static void testOK() {
        initData();

        RestRequest request = new RestRequest();
        request.requestUri = '/services/apexrest/api/CCH/75007';
        request.httpMethod = 'GET';

        Test.startTest();
        RestResponse res = new RestResponse();
        RestContext.request = request;
        RestContext.response = res;

        String json = AP02_RechercheCCH.doGet();
        Test.stopTest();

        AP02_RechercheCCH.RootObject root = (AP02_RechercheCCH.RootObject) System.JSON.deserialize(json, AP02_RechercheCCH.RootObject.class);

        System.assertEquals(200, RestContext.response.statusCode);
        System.assertEquals(1, root.CCH.size());
        System.assertEquals(1, root.CCH[0].Artisans.size());
    }

    /**
     * Ici on teste que le WS retourne une erreur car le code postal n'est pas correct
     */
    @isTest 
    static void testMauvaisCodePostal() {
        initData();

        RestRequest request = new RestRequest();
        request.requestUri = '/services/apexrest/api/CCH/ABCDE';
        request.httpMethod = 'GET';

        Test.startTest();
        RestResponse res = new RestResponse();
        RestContext.request = request;
        RestContext.response = res;

        String json = AP02_RechercheCCH.doGet();
        Test.stopTest();

        AP02_RechercheCCH.RootObject root = (AP02_RechercheCCH.RootObject) System.JSON.deserialize(json, AP02_RechercheCCH.RootObject.class);

        System.assertEquals(400, RestContext.response.statusCode);
    }


}