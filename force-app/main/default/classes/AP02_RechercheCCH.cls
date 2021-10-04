/*
----------------------------------------------------------------------
-- - Name          : AP02_RechercheCCH
-- - Author        : RDB
-- - Description   : Web service permettant de retourner une liste de CCH en fonction d'un
--                      code postal
--                  Ce WS est utilisé par le site web de Synerciel
-- Maintenance History:
--
-- Date         Name                Version     Remarks 
-- -----------  -----------         --------    ---------------------------------------
-- 25-03-2020   RDB                 1.0         Init
-- 30-03-2021   RDB                 1.1         SF-TMA #1476 : ne garder que les artisans encore adhérent (date de sortie vide ou > date du jour)
-- 09-04-2021   AL                  1.2         redmine.synerciel.fr/issues/1658 (AJOUT DATE DE DISSOLUTION DU CCH)
-- 22-04-2021   AL                  1.3         Redmine #2625
-- 23-04-2021   AL                  1.2         Redmine #2625 failed, retour a la version du code 1.2 (avec ajout point d'ancrage et coordonnées geoloc)
-- 28-04-2021   AL                  1.3         Redmine #2625 && #1658
-- 17-05-2021   AL                  1.4         Redmine #2718
-- 28-05-2021   AL                  1.5         Redmine #2718 - #2751
-- 02-06-2021   AL                  1.6         Redmine #2718 - #2751 ADDITIONAL/CHANGE REQUEST
---------------------------------------------------------------------------------------
*/
@RestResource(urlMapping='/CCH/*')
global with sharing class AP02_RechercheCCH {
    
    global class RootObject {
        public List<CCH> CCH = new List<CCH>();
    }

    global class CCH {
        public CCH() {
            Metiers_de_reference = new Set<String>();
            Zones_de_chalandise = new Set<String>();
            Artisans = new List<Account>();
        }

        public String Id;
        public String Name;
        public String Description;
        public Set<String> Metiers_de_reference;
        public Set<String> Zones_de_chalandise; 
        public List<Account> Artisans;
        public String Point_d_ancrage;
        public Double CoordonneesLatitude;
        public Double CoordonneesLongitude;

        public String Metier1;
        public String Metier2;
        public String NomDuRepresentant;
        public String PrenomDuRepresentant;

    }


    /**
     * WS permettant de récupérer une liste de CCH et de ses adhérents en fonction du code postal
     * fourni en paramètre
     */
    @HttpGET
    global static String doGet() {
        RestRequest req = RestContext.request;
        String codePostal = req.requestURI.substring(req.requestURI.lastIndexOf('/')+1);
        System.debug('[AP02_RechercheCCH][doGet] Code postal reçu : ' + codePostal);
        
        // tester que le CP est = 5 caracteres numérique sinon retourne erreur
        if(! Pattern.matches('\\d{5}', codePostal)) {
            RestContext.response.statusCode  = 400;
            return generateErreurJSON('CODE_POSTAL', 'Code postal invalide : ' + codePostal);
        }      
        
        // [1] liste des comptes dans la zone de chalandise
        List<Account> listAccounts;
        if(codePostal.startsWith('20')) {
            // c'est un code postal de la Corse et en base le code département est stocké sous la forme 2a et 2b
            listAccounts = [SELECT Id, Name
                                        FROM Account
                                        WHERE RecordTypeId = '0121r000000ubBPAAY'
                                        AND Profil__c = 'Adhérent'
                                        AND Holding__c = false AND TDR_Industriel__c = false // exclusion des TRD et Holding sinon ça remonte sur le siteweb avec rech gestion d'entreprises
                                        AND Id IN (SELECT Compte__c 
                                                    FROM Zone_de_chalandise__c
                                                    WHERE Departement__c LIKE '2a%'
                                                    OR Departement__c LIKE '2b%')];
        } else {
            String codeDepartement;
            if(codePostal.startsWith('97')) {
                // c'est un code postal des DOM donc on prend les 3 premiers pour la recherche par code département
                codeDepartement = codePostal.substring(0, 3) + '%';
            }  else {
                codeDepartement = codePostal.substring(0, 2) + '%';
            }

            listAccounts = [SELECT Id, Name, Holding__c, TDR_Industriel__c
                                        FROM Account
                                        WHERE RecordTypeId = '0121r000000ubBPAAY'
                                        AND Holding__c = false AND TDR_Industriel__c = false // exclusion des TRD et Holding sinon ça remonte sur le siteweb avec rech gestion d'entreprises
                                        AND Profil__c = 'Adhérent'
                                        AND Id IN (SELECT Compte__c 
                                                    FROM Zone_de_chalandise__c
                                                    WHERE Departement__c LIKE :codeDepartement)];
        }
        
        System.debug('[AP02_RechercheCCH][doGet] Liste des comptes dans la zone de chalandise : ' + listAccounts);

        // [2] liste des CCH (avec leurs CCHA encore adhérents) de ces comptes
        List<Cercle_Confort_Habitat__c> listCCH = [SELECT Id, Name, Description__c, Tech_UUID__c , Point_d_ancrage__c, Date_de_cr_ation_du_CCH__c, Date_de_dissolution_du_CCH__c,Coordonnees__Longitude__s, Coordonnees__Latitude__s, // Ajout Alexis point d'ancrage, geolocation, date creation et date de dissolution
                                                    (SELECT Id, Name, Compte__c, Compte__r.RecordTypeId, Compte__r.Profil__c, Date_sortie_CCH__c, Compte__r.BillingPostalCode, Compte__r.BillingAddress,
                                                    Compte__r.website,Compte__r.name, Nom_representant__c, Prenom_representant__c, Metier_1__c,Metier_2__c, compte__r.phone, compte__r.email__c
                                                        FROM Cercles_Confort_Habitat_adh_rent__r 
                                                        WHERE 
                                                        Compte__r.RecordTypeId = '0121r000000ubBPAAY' 
                                                        AND Compte__r.Profil__c = 'Adhérent'
                                                        AND (Date_sortie_CCH__c = null OR Date_sortie_CCH__c >= TODAY))
                                                    FROM  Cercle_Confort_Habitat__c
                                                    WHERE 
                                                    Id IN (SELECT Cercle_Confort_Habitat__c
                                                            FROM Cercle_confort_habitat_adh_rent__c
                                                            WHERE Compte__c IN :listAccounts) AND (Date_de_dissolution_du_CCH__c = NULL OR Date_de_dissolution_du_CCH__c >= TODAY)];
        System.debug('[AP02_RechercheCCH][doGet] Liste des CCH avec leurs CCHA en fct des comptes : ' + listCCH);

        // Liste des CCHA

        Set<Id> setAccountIds = new Set<Id>();
        for (Cercle_Confort_Habitat__c cch : listCCH) {
            for (Cercle_confort_habitat_adh_rent__c ccha : cch.Cercles_Confort_Habitat_adh_rent__r) {
                setAccountIds.add(ccha.Compte__c);
            }
        }
        System.debug('[AP02_RechercheCCH][doGet] Liste de tous les ID des comptes des CCHA : ' + setAccountIds);

        // [3] liste des comptes (avec leurs zones de chalandise et métiers) des CCH qu'on a récupéré en partie 2
        Map<Id, Account> mapAccountsById = new Map<Id, Account>([SELECT 
                                                        Id, Name, BillingAddress, BillingLatitude, BillingLongitude, BillingCountry, BillingPostalCode, BillingStreet, BillingCity, 
                                                        Phone, mobile__c, email__c, IdNav__c, Website,Name2__c,
                                                        (SELECT FirstName, LastName FROM Account.Contacts WHERE Fonction__c = 'Gérant / Directeur Général'),
                                                        (SELECT Cercle_Confort_Habitat__r.Name FROM Account.Cercles_Confort_Habitat__r),
                                                        (SELECT Code_metier__c, Metier__c FROM Account.Metiers_de_reference__r),
                                                        (SELECT Departement__c FROM Account.Zones_de_chalandise__r)
                                                    FROM Account
                                                    WHERE RecordTypeId = '0121r000000ubBPAAY'
                                                    AND Profil__c = 'Adhérent'
                                                    AND Id IN :setAccountIds]);
        System.debug('[AP02_RechercheCCH][doGet] On récupère tous les artisans de ces CCH (Nb='+mapAccountsById.keySet().size()+')');
        
        // ====
        // on va construire les informations à retourner dans le JSON de réponse
        // ====
        List<CCH> listCCHObj = new List<CCH>();
        for (Cercle_Confort_Habitat__c cch : listCCH) {
            // on parcourt les CCH
            CCH cchObj = new CCH();
            cchObj.Id = cch.Tech_UUID__c;
            cchObj.Name = cch.Name;
            cchObj.Description = cch.Description__c;
            cchObj.Point_d_ancrage = cch.Point_d_ancrage__c;
            cchObj.CoordonneesLatitude = cch.Coordonnees__Latitude__s;
            cchObj.CoordonneesLongitude = cch.Coordonnees__Longitude__s;


            System.debug('[AP02_RechercheCCH][doGet] On construit l\'objet CCH :' + cch);
            
            // on parcourt les CCHA du CCH pour retrouver les comptes associés (=artisans)
            for (Cercle_confort_habitat_adh_rent__c ccha : cch.Cercles_Confort_Habitat_adh_rent__r) {
                System.debug('[AP02_RechercheCCH][doGet] Traitement du CCHA:' + ccha);

                Account artisan = mapAccountsById.get(ccha.Compte__c);

                cchObj.Metier1 = ccha.metier_1__c;
                cchObj.Metier2 = ccha.metier_2__c;
                cchObj.NomDuRepresentant = ccha.Nom_representant__c;
                cchObj.PrenomDuRepresentant = ccha.Prenom_representant__c;


                if(artisan != null) {
                    cchObj.Artisans.add(artisan);

                    // on va ajouter la liste des métiers de l'artisan en ne prenant que le nom du métier (sans les infos de l'objet)
                    // et remonter cette info au niveau du CCH
                    if(artisan.Metiers_de_reference__r != null) {
                        for (Metier_de_reference__c metier : artisan.Metiers_de_reference__r) {
                            cchObj.Metiers_de_reference.add(metier.Metier__c);
                        }
                    }

                    // on va ajouter la liste des zones de chalandise de l'artisan en ne prenant que le nom du département (sans les infos de l'objet)
                    // et remonter cette info au niveau du CCH
                    if(artisan.Zones_de_chalandise__r != null) {
                        for (Zone_de_chalandise__c chalandise : artisan.Zones_de_chalandise__r) {
                            // ex : "75 Paris" devient => "Paris"
                            String departement = chalandise.Departement__c.split(' ')[1];
                            cchObj.Zones_de_chalandise.add(departement);

                        }
                    }
                } else {
                    System.debug('[AP02_RechercheCCH][doGet] ERREUR artisan non trouvé pr le compte :' + ccha.Compte__c);
                }
            }

            listCCHObj.add(cchObj);
        }

        // retour HTTP Ok avec le JSON de la liste des CCH
        RestContext.response.statusCode = 200;
        RootObject root = new RootObject();
        root.CCH = listCCHObj;

        return JSON.serializePretty(root);
    }

    /**
     * Retourne l'erreur
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