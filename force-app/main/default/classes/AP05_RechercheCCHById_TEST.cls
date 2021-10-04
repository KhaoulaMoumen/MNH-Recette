/**
     * @description       : API appelée par les mini-sites CCH >> TEST CLASS
     * @author            : Alexis Ly
     * @group             : 
     * @last modified on  : 07-15-2021
     * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
     * Modifications Log 
     * Ver   Date         Author                               Modification
     * 1.0   06-25-2021   AL                                   Initial Version
**/
/* ================== MESSAGE POUR TALAN ===================*/
    // bonjour, j'aimerais pouvoir passer la Test class en seeAllData = false, mais je ne parviens pas rexploiter la class Datafactory, ni la method initData
    // l'idée de la classe est de permettre à un site web de récupérer 1 record Cercle_Confort_Habitat__c avec N related records Cercle_Confort_Habitat_Adherent__c (lookup to Account)
    // le site passe une valeur en parametre correspondant a une valeur d'un champ auto-number sur l'objet Cercle_Confort_Habitat__c
    // les methodes ci-dessous couvrent les cas de test souhaités
/* ===================MESSAGE POUR TALAN ===================*/

@istest(seeAllData = true) 
private class AP05_RechercheCCHById_TEST {

/*
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
*/
    //Ici on teste que le WS retourne bien le CCH-000127 CCH-TEMOIN
    @isTest 
    static void testOK() {
        //initData();

        List<Cercle_Confort_Habitat__c> cchList = [SELECT Id, Name, Tech_UUID__c FROM Cercle_Confort_Habitat__c WHERE code__c ='CCH-TEMOIN'];
        String cchId;
        for (Cercle_Confort_Habitat__c c: cchList) 
        {
            cchId = c.Tech_UUID__c;
        }

        RestRequest request = new RestRequest();
        request.requestUri = '/services/apexrest/api/CCHBYID/'+cchId;
        request.httpMethod = 'GET';

        Test.startTest();
        RestResponse res = new RestResponse();
        RestContext.request = request;
        RestContext.response = res;

        String json = AP05_RechercheCCHById.doGet();
        Test.stopTest();

        AP05_RechercheCCHById.RootObject root = (AP05_RechercheCCHById.RootObject) System.JSON.deserialize(json, AP05_RechercheCCHById.RootObject.class);

        System.assertEquals(200, RestContext.response.statusCode);
        System.assertEquals(1, root.CCHBYID.size());
    }

    // Ici on teste que le WS retourne une erreur car le code CCH ne repond pas au format
    @isTest 
    static void mauvaisFormatID() {
        //initData();

        RestRequest request = new RestRequest();
        request.requestUri = '/services/apexrest/api/CCHBYID/CCH-0009';
        request.httpMethod = 'GET';

        Test.startTest();
        RestResponse res = new RestResponse();
        RestContext.request = request;
        RestContext.response = res;

        String json = AP05_RechercheCCHById.doGet();
        Test.stopTest();

        AP05_RechercheCCHById.RootObject root = (AP05_RechercheCCHById.RootObject) System.JSON.deserialize(json, AP05_RechercheCCHById.RootObject.class);

        System.assertEquals(400, RestContext.response.statusCode);
        String message = ' n\'est pas correct';
        Boolean containsMessage;
        if (json.contains(message))
        {
            containsMessage = true;
        } else containsMessage = false;

        System.assertEquals(true, containsMessage);
    }

    // Ici on test un CCH qui n'existe pas
    @isTest
    static void cchInexistant() {
        //initData();

        RestRequest request = new RestRequest();
        request.requestUri = '/services/apexrest/api/CCHBYID/CCH-000300';
        request.httpMethod = 'GET';

        Test.startTest();
        RestResponse res = new RestResponse();
        RestContext.request = request;
        RestContext.response = res;

        String json = AP05_RechercheCCHById.doGet();
        Test.stopTest();

        AP05_RechercheCCHById.RootObject root = (AP05_RechercheCCHById.RootObject) System.JSON.deserialize(json, AP05_RechercheCCHById.RootObject.class);

        System.assertEquals(400, RestContext.response.statusCode);
        String message = ' n\'existe pas';
        Boolean containsMessage;
        if (json.contains(message))
        {
            containsMessage = true;
        } else containsMessage = false;

        System.assertEquals(true, containsMessage);
    }

    // ici on test un CCH qui ne contient aucun membre
    @isTest
    static void cchSansMembreActif() {
        //initData();
        List<Cercle_Confort_Habitat__c> cchList = [SELECT Id, Name, Tech_UUID__c FROM Cercle_Confort_Habitat__c WHERE code__c ='CCH-TEMOIN_VIDE'];
        String cchId;
        for (Cercle_Confort_Habitat__c c: cchList) 
        {
            cchId = c.Tech_UUID__c;
        }
        RestRequest request = new RestRequest();
        request.requestUri = '/services/apexrest/api/CCHBYID/'+cchId;
        request.httpMethod = 'GET';

        Test.startTest();
        RestResponse res = new RestResponse();
        RestContext.request = request;
        RestContext.response = res;

        String json = AP05_RechercheCCHById.doGet();
        Test.stopTest();

        AP05_RechercheCCHById.RootObject root = (AP05_RechercheCCHById.RootObject) System.JSON.deserialize(json, AP05_RechercheCCHById.RootObject.class);

        System.assertEquals(400, RestContext.response.statusCode);
        String message = 'ne contient aucun membre actif';
        Boolean containsMessage;
        if (json.contains(message))
        {
            containsMessage = true;
        } else containsMessage = false;

        System.assertEquals(true, containsMessage);
    }

}