/*----------------------------------------------------------------------
-- - Name          : AP03_GestionCommunityUsers
-- - Author        : KM
-- - Description   : Activation/désactivation de comptes utilisateurs pour l'epace pro Synerciel
--   
-- Maintenance History:
--
-- Date         Name                Version     Remarks 
-- -----------  -----------         --------    ---------------------------------------
-- XX-07-2020   KM                  1.0         Init
-- 30-07-2020   RDB                 1.1         gestion du cas ou le user existait déjà, il faut le réactiver
--                                               et non créer un nouvel user
-- 12-08-2020   KM                  1.2         gestion du cas ou le user existait déjà, il faut le réactiver
--                                               et non créer un nouvel user
-- 13-08-2020   RDB                 1.3         plus de gesestion du user existant + gestion des erreurs
-- 26-02-2021   KM                  1.4         Crée un compte utilisateur CLIENT pour la communauté
---------------------------------------------------------------------------------------
*/
public with sharing class AP03_GestionCommunityUsers {
    
    
    /**
    * Crée un compte utilisateur ADHERENT pour la communauté
    */
    @future
    public static void activerAdherent(Set<ID> accountIDs){
        System.debug('[AP03_GestionCommunityUsers][activateAdherent] start');
        List<User> listUsersToInsert = new List<User>();
        List<User> listUsersToUpdate = new List<User>();
        Set<Id> userToUpdateIds = new Set<Id>();
        
        List<Contact> listContactsForCommunity = new List<Contact>(); 
        
        List<Account> accounts = [SELECT Id, Name, (SELECT Id, LastName, FirstName, Email, MobilePhone, Fonction__c  FROM Contacts) FROM Account WHERE Id IN :accountIDs];
        
        // pour chaque compte on va parcourir les contacts associés
        // et trouver le Gérant, si pas trouvé on prend le Président, si pas trouvé
        // on prend le Co-gérant, si toujours pas trouvé alors on ne fait rien
        // Quand on trouve une de ses 3 fonctions alors on crée un User community
        for(Account acc : accounts) {
            Contact contactForCommunity = findContact(acc.Contacts);
            System.debug('[AP03_GestionCommunityUsers][activateAdherent] contact a creer : '  + contactForCommunity);
            
            // le compte n'a pas encore de user créé pour la community
            User userCommunity = new User(
                UserName = contactForCommunity.Email, // TODO vérifier que le username est unique
                FirstName = contactForCommunity.FirstName,
                LastName = contactForCommunity.LastName,
                Alias = String.valueof(contactForCommunity.FirstName.substring(0,1) + contactForCommunity.LastName.substring(0,1)),
                Email = contactForCommunity.Email,
                MobilePhone = contactForCommunity.MobilePhone,
                ContactId = contactForCommunity.Id,
                ProfileId = System.Label.ESP_Adherent_Profil_ID,
                EmailEncodingKey = 'UTF-8',
                CommunityNickname = contactForCommunity.FirstName + '.' + contactForCommunity.LastName,
                TimeZoneSidKey = 'Europe/Paris',
                LocaleSidKey = 'fr',
                LanguageLocaleKey = 'fr'
            );
            System.debug('[AP03_GestionCommunityUsers][activateAdherent] on crée un User : '  + userCommunity);
            
            listUsersToInsert.add(userCommunity);
        }
        
        if(listUsersToInsert.size() > 0){
            List<Database.SaveResult> results = Database.insert(listUsersToInsert, false);
            
            for (Database.SaveResult sr : results) {
                if (sr.isSuccess()) {
                    System.debug('user community créé ' + sr.getId());
                }
                else {
                    // Operation failed, so get all errors                
                    for(Database.Error err : sr.getErrors()) {
                        System.debug('Impossible de créer le compte utilisateur :');                    
                        System.debug(err.getStatusCode() + ': ' + err.getMessage());
                        System.debug('Problème avec les champs ' + err.getFields());
                    }
                }
            }
        }
    }
   
     /**
    * Crée un compte utilisateur CLIENT pour la communauté
    */
    @future
    public static void activerClient(Set<ID> accountIDs){
        System.debug('[AP03_GestionCommunityUsers][activateClieny] start');
        List<User> listUsersToInsert = new List<User>();
        List<User> listUsersToUpdate = new List<User>();
        Set<Id> userToUpdateIds = new Set<Id>();
        
        List<Contact> listContactsForCommunity = new List<Contact>(); 
        
        List<Account> accounts = [SELECT Id, Name, (SELECT Id, LastName, FirstName, Email, MobilePhone, Fonction__c  FROM Contacts) FROM Account WHERE Id IN :accountIDs];
        
        // pour chaque compte on va parcourir les contacts associés
        // et trouver le Gérant, si pas trouvé on prend le Président, si pas trouvé
        // on prend le Co-gérant, si toujours pas trouvé alors on ne fait rien
        // Quand on trouve une de ses 3 fonctions alors on crée un User community
        for(Account acc : accounts) {
            Contact contactForCommunity = findContact(acc.Contacts);
            System.debug('[AP03_GestionCommunityUsers][activateAdherent] contact a creer : '  + contactForCommunity);
            
            // le compte n'a pas encore de user créé pour la community
            User userCommunity = new User(
                UserName = contactForCommunity.Email, // TODO vérifier que le username est unique
                FirstName = contactForCommunity.FirstName,
                LastName = contactForCommunity.LastName,
                Alias = String.valueof(contactForCommunity.FirstName.substring(0,1) + contactForCommunity.LastName.substring(0,1)),
                Email = contactForCommunity.Email,
                MobilePhone = contactForCommunity.MobilePhone,
                ContactId = contactForCommunity.Id,
                ProfileId = System.Label.ESP_Client_Profil_ID,
                EmailEncodingKey = 'UTF-8',
                CommunityNickname = contactForCommunity.FirstName + '.' + contactForCommunity.LastName,
                TimeZoneSidKey = 'Europe/Paris',
                LocaleSidKey = 'fr',
                LanguageLocaleKey = 'fr'
            );
            System.debug('[AP03_GestionCommunityUsers][activateAdherent] on crée un User : '  + userCommunity);
            
            listUsersToInsert.add(userCommunity);
        }
        
        if(listUsersToInsert.size() > 0){
            List<Database.SaveResult> results = Database.insert(listUsersToInsert, false);
            
            for (Database.SaveResult sr : results) {
                if (sr.isSuccess()) {
                    System.debug('user community créé ' + sr.getId());
                }
                else {
                    // Operation failed, so get all errors                
                    for(Database.Error err : sr.getErrors()) {
                        System.debug('Impossible de créer le compte utilisateur :');                    
                        System.debug(err.getStatusCode() + ': ' + err.getMessage());
                        System.debug('Problème avec les champs ' + err.getFields());
                    }
                }
            }
        }
    }

    /**
    * Crée un compte utilisateur PARTENAIRE pour la communauté
    */
    public static void activerPartenaire(Id contactId) {
        String result;         
        Boolean isPermissionGranted = FeatureManagement.checkPermission('CP1_ActivationUserPartenaire');
       
        system.debug('isPermissionGranted **'+isPermissionGranted);       

        if(isPermissionGranted) {
                // nv user à créer
            Contact contactToActivate = [SELECT Id, LastName, FirstName, Email, MobilePhone, Fonction__c  FROM Contact WHERE Id = :contactId];
            
            User userCommunity = new User(
                UserName = contactToActivate.Email,
                FirstName = contactToActivate.FirstName,
                LastName = contactToActivate.LastName,
                Alias = String.valueof(contactToActivate.FirstName.substring(0,1) + contactToActivate.LastName.substring(0,1)),
                Email = contactToActivate.Email,
                MobilePhone = contactToActivate.MobilePhone,
                ContactId = contactToActivate.Id,
                ProfileId = System.Label.ESP_Partenaire_Profil_ID,
                EmailEncodingKey = 'UTF-8',
                CommunityNickname = contactToActivate.FirstName + '.' + contactToActivate.LastName,
                TimeZoneSidKey = 'Europe/Paris',
                LocaleSidKey = 'fr',
                LanguageLocaleKey = 'fr'
            );
            System.debug('[AP03_GestionCommunityUsers][activatePartenaire] on crée un User pour le contact : '  + contactToActivate);
            System.debug('[AP03_GestionCommunityUsers][activatePartenaire] on crée un User  : '  + userCommunity);
            
            Database.insert(userCommunity);
        } else {
            System.debug('[AP03_GestionCommunityUsers][activatePartenaire] on ne peut pas activer le partenaire : pas la permission');
            throw new SynercielException.PermissionException('L\'utilisateur n\'a pas les permissions pour activer le partenaire', 
                                                                SynercielException.PARTENAIRE_ACTIVATION_NOT_PERMITTED);
        }

    }
    
    /*
    * Fonction permettant de désactiver un partenaire
    */
    public static void desactiverPartenaire(Id contactId){  
        Boolean isPermissionGranted = FeatureManagement.checkPermission('CP2_DesactivationUserPartenaire');
        
        if(isPermissionGranted){
            List<User> portalUsers = [SELECT Id, IsActive, IsPortalEnabled, Account.Profil__c
                                      FROM User 
                                      WHERE ContactId = :contactId  
                                      ];
            
            if(portalUsers.size() > 0) {
                User partenaire = portalUsers[0];
                partenaire.IsActive = false;
                partenaire.IsPortalEnabled = false;
                system.debug('desactivate user'+partenaire);
                update partenaire;
            } else {
                // user non trouvé
                // erreur probable : user déjà désactivé
                System.debug('[AP03_GestionCommunityUsers][desactiverPartenaire] User du partenaire non trouvé');
            }
        } else {
            System.debug('[AP03_GestionCommunityUsers][desactiverPartenaire] on ne peut pas désactiver le partenaire : pas la permission');
            throw new SynercielException.PermissionException('L\'utilisateur n\'a pas les permissions pour activer le partenaire', 
                                                                SynercielException.PARTENAIRE_DEACTIVATION_NOT_PERMITTED);
        }
    }

    /*
    * Fonction permettant de désactiver un User du portail community
    * en fonction de son appartenance à un compte
    */
	@future
    public static void deactivatePortalUser(Set<ID> accountIDs){
        List<User> usersToDesactivate = new List<User>();  
        
        List<User> users = [SELECT Id, AccountId, IsActive, IsPortalEnabled, CommunityNickName 
                            FROM User 
                            WHERE AccountId IN :accountIDs 
                            AND IsActive = :true 
                            AND IsPortalEnabled = :true];
        
        for(User portalUser : users){
            portalUser.IsActive = false;
            portalUser.IsPortalEnabled = false;
            portalUser.CommunityNickName = portalUser.CommunityNickName+'_'+String.valueOf(System.now().getTime());
            
            system.debug('desactivate user'+portalUser);
            usersToDesactivate.add(portalUser);
        }
        
        if(usersToDesactivate.size() > 0){
            Database.update(usersToDesactivate, false);
        }
    }
    
    /**
    * 
    */
    private static Contact findContact(List<Contact> listContacts) {
        // on récupère les contacts par fonction
        Contact gerant = null;
        Contact president = null;
        Contact cogerant = null;
        
        for(Contact con : listContacts) {
            if(con.Fonction__c == 'Gérant / Directeur Général') {
                gerant = con;
            } else if(con.Fonction__c == 'Président') {
                president = con;
            } else if(con.Fonction__c == 'Co-gérant') {
                cogerant = con;
            }
        }
        
        // on détermine quel contact on va utiliser pour créer le User Community associé
        Contact contactCommunity = null;
        if(gerant != null) {
            contactCommunity = gerant;
        } else if(president != null) {
            contactCommunity = president;
        } else if(cogerant != null) {
            contactCommunity = cogerant;
        }
        
        return contactCommunity;
    }
    
    @TestVisible
    private static Map<Id, User> groupUsersByContactId(List<User> listUsers) {
        Map<Id, User> mapUsersByContactId = new Map<Id, User>();
        
        for (User user : listUsers) {
            mapUsersByContactId.put(user.ContactId, user);
        }
        
        return mapUsersByContactId;
    }
    
}