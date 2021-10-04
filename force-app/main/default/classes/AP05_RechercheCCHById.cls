/**
     * @description       : API appelée par les mini-sites CCH
     * @author            : Alexis Ly
     * @group             : 
     * @last modified on  : 07-21-2021
     * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
     * Modifications Log 
     * Ver   Date         Author                               Modification
     * 1.0   06-25-2021   AL                                   Initial Version
**/
@RestResource(urlMapping='/CCHBYID/*')
global with sharing class AP05_RechercheCCHById {
    
    global class RootObject {
        public String Id;
        public String CCHName;
        public List<CCHBYID> CCHBYID;
    }
    global class CCHBYID {
        public String CCHAName;
        public String Name;
        public String idCompte;
        public String NomDuRepresentant;
        public String PrenomDuRepresentant;
        public String BillingAddress;
        public String BillingPostalCode;
        public Decimal BillingLattitude;
        public Decimal BillingLongitude;
        public String Metier1;
        public String Metier2;
        public String Website;
        public String Phone;
        public String Email;
    }

    /**
     * WS permettant de récupérer une liste d'adhérents en fonction du CCH
     * fourni en paramètre
     * Webservice allowing to retrieve the list of accounts members of CCH clubs, CCH autonumber is given in URL parameter
     */
    @HttpGET
    global static String doGet() {
        RestRequest req = RestContext.request;
        String cchbyId = req.requestURI.substring(req.requestURI.lastIndexOf('/')+1);
        System.debug('[AP05_RechercheCCHById][doGet] CCH reçu : ' + cchbyId);
        
        // tester que le Code CCH est = CCH-000ddd sinon retourne erreur // test the CCH Code is correctly formatted
        string format = 'CCH-000';
        if(! Pattern.matches(format+'\\d{3}', cchbyId)) {
            RestContext.response.statusCode  = 400;
            return generateErreurJSON('Format code Cercle Confort Habitat', 'Le numéro de Cercle Confort Habitat ' + cchbyId + ' n\'est pas correct');
        }      
        
        // [1] On vérifie si le CCH existe / verify if there is a CCH record
        List<Cercle_Confort_Habitat__c> cchList = [SELECT Id FROM Cercle_Confort_Habitat__c WHERE tech_UUID__c =:cchbyId];
        if(cchList.size() < 1) 
        {
            RestContext.response.statusCode  = 400;
            return generateErreurJSON('Cercle Confort Habitat non existant', 'Le Cercle Confort Habitat ' + cchbyId + ' n\'existe pas');
        }

        // [2] liste des membres du CCH demandé / get the list of members of the CCH club (CCH > CCHMember >> Account)
        List<CCHBYID> listCCHMembers = new List<CCHBYID>();
        Id adherentRTId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Adherent').getRecordTypeId();

        List <String> listId = new List<String>();
        List <String> listCCHName = new List <String>(); 
        for(Cercle_confort_habitat_adh_rent__c ccha: [SELECT Id, Name, Cercle_Confort_Habitat__r.name, Cercle_Confort_Habitat__r.Coordonnees__Longitude__s, Cercle_Confort_Habitat__r.Coordonnees__Latitude__s, Cercle_Confort_Habitat__r.Point_d_ancrage__c, Cercle_Confort_Habitat__r.Code_postal__c, 
                                                    Compte__c,Compte__r.Name2__c, Nom_representant__c, Prenom_representant__c, Compte__r.BillingStreet, Compte__r.billingcity, Compte__r.BillingPostalCode, Compte__r.BillingLatitude, Compte__r.BillingLongitude,
                                                    Metier_1__c,Metier_2__c, Compte__r.website, compte__r.phone, compte__r.email__c,
                                                    Cercle_Confort_Habitat__r.Tech_UUID__c
                                                        FROM Cercle_confort_habitat_adh_rent__c
                                                            WHERE Compte__r.RecordTypeId =: adherentRTId 
                                                                AND Compte__r.Profil__c = 'Adhérent'
                                                                AND (Date_sortie_CCH__c = null OR Date_sortie_CCH__c >= TODAY)
                                                                AND Cercle_Confort_Habitat__r.Tech_UUID__c =: cchbyId])
        {

        /* 
        ====
            on va construire les informations à retourner dans le JSON de réponse / build the JSON response
        ====
        */ 
            CCHBYID cchaobj = new CCHBYID();
            String billingAddressToString = ccha.Compte__r.BillingStreet + ', ' + ccha.compte__r.BillingPostalCode + ', ' + ccha.Compte__r.BillingCity;
            cchaobj.CCHAName = ccha.name;
            cchaobj.idCompte = ccha.Compte__c;
            cchaobj.Name = ccha.Compte__r.Name2__c;
            cchaobj.NomDuRepresentant = ccha.Nom_representant__c;
            cchaobj.PrenomDuRepresentant = ccha.Prenom_representant__c;
            cchaobj.BillingAddress = billingAddressToString;
            cchaobj.BillingPostalCode = ccha.Compte__r.BillingPostalCode;
            cchaobj.Metier1 = ccha.metier_1__c;
            cchaobj.Metier2 = ccha.metier_2__c;
            cchaobj.Website = ccha.Compte__r.Website;
            cchaobj.Phone = ccha.Compte__r.phone;
            cchaobj.Email = ccha.Compte__r.email__c;
            cchaobj.BillingLattitude = ccha.Compte__r.BillingLatitude;
            cchaobj.BillingLongitude = ccha.Compte__r.BillingLongitude;
            listCCHMembers.add(cchaobj);
            listId.add(ccha.Cercle_Confort_Habitat__r.Tech_UUID__c);
            listCCHName.add(ccha.Cercle_Confort_Habitat__r.Name);
        }

        // si le CCH n'a aucun membre actif / there is no member in the CCH club
        if (listCCHMembers.size() == 0)
        {
            RestContext.response.statusCode  = 400;
            return generateErreurJSON('Cercle Confort Habitat Inactif', 'Le Cercle Confort Habitat ' + cchbyId + ' ne contient aucun membre actif');
        }
       
        // retour HTTP Ok avec le JSON de la liste des membres du CCH demandé / if the CCH club contains member with status code 200
        RestContext.response.statusCode = 200;
        RootObject root = new RootObject();
        root.Id = listId[0];
        root.CCHName = listCCHName[0];    
        root.CCHBYID = listCCHMembers;
        return JSON.serializePretty(root);
    }

    /**
     * Retourne l'erreur / returns the error
     */
    private static String generateErreurJSON(String errorCode, String message) {
        JSONGenerator gen = JSON.createGenerator(true);
        gen.writeStartObject();
        gen.writeStringField('errorCode', errorCode);
        gen.writeStringField('message', message);
        gen.writeEndObject();

        return gen.getAsString();
    }

}