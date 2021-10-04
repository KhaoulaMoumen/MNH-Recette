/**
 * @description       : 
 * @author            : Talan
 * @group             : 
 * @last modified on  : 04-16-2021
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
 * Modifications Log 
 * Ver   Date         Author                               Modification
 * 1.0   04-16-2021   Alexis Ly  Initial Version 1.0        replaced contenu__c by TESTRICH__c for testting, put back to normal to retest
**/
global class BA15_CreateNotificationTasks implements Database.Batchable<sObject>, Database.Stateful {
    set<Id> notifsToUpdate = new set<Id>();
    RecordType rd = [select Id from RecordType where Name like 'Notification'];
    User admin = [select id from user where id =: Label.Administratif_Synerciel_Id limit 1];
    User contactTemoin = [SELECT Id,AccountId, ContactId FROM User WHERE Name = 'Contact TEMOIN' LIMIT 1];
    
    
    
    global Database.QueryLocator start (Database.BatchableContext bc) {
        return Database.getQueryLocator('SELECT Id, Ciblage__c, Name, Groupe_Interaction__c, Modele_Interaction__c, contenu__c,Envoi_utilisateurs_interne__c FROM Notification_My_Synerciel__c WHERE isProgrammed__c = true');
    }
    global void execute(Database.BatchableContext bc, List<Notification_My_Synerciel__c> scope){
        list<Task> tachesNotif = new list<Task>();
        
        for(Notification_My_Synerciel__c notif : scope){
            list<User> myUsers = new list<User>();
            list<User> internalUsers = new list<User>();
            
            switch on notif.Ciblage__c {
                when 'Tous les adhérents' {		
                    myUsers = [select id,contactid,AccountId from user where contactid != null and isActive = true and Account.Profil__c like 'Adhérent'];
                }
                when 'Tous les partenaires' {		
                    myUsers = [select id,contactid,AccountId from user where contactid != null and isActive = true and Account.Profil__c like 'Partenaire'];
                }
                when 'Les adhérents membre d\'un CCH' {		
                    myUsers = [select id,contactid,AccountId from user where contactid != null and isActive = true and Account.Profil__c like 'Adhérent' and Account.Club_CCH__c= true];
                }
                when 'Les adhérents PEE' {		
                    myUsers = [select id,contactid,AccountId from user where contactid != null and isActive = true and Account.Profil__c like 'Adhérent' and Account.ClubPEE__c= true];
                }
                when 'Les adhérents membre d\'un CME' {		
                    myUsers = [select id,contactid,AccountId from user where contactid != null and isActive = true and Account.Profil__c like 'Adhérent' and Account.ClubCME__c = : true];
                }
                when else {		  
                    return;
                }
            }
                if(notif.Envoi_utilisateurs_interne__c == true) {
                    List<User> marketingUsers = [SELECT Id FROM User WHERE Profile.Name like 'Marketing' AND isActive = true];
                    internalUsers.addAll(marketingUsers);
                    
                    List<User> respSecteurUsers = [SELECT Id FROM User WHERE Profile.Name like 'Responsable de secteur' AND isActive = true];
                    internalUsers.addAll(respSecteurUsers);
                    
                    List<User> commerceMUsers = [SELECT Id FROM User WHERE Profile.Name like 'Commerce Manager' AND isActive = true];
                    internalUsers.addAll(commerceMUsers);
                    
                    List<User> qualiteRUsers = [SELECT Id FROM User WHERE Profile.Name like 'Qualité réseau' AND isActive = true];
                    internalUsers.addAll(qualiteRUsers);
                    
                    List<User> directionUsers = [SELECT Id FROM User WHERE Profile.Name like 'Direction' AND isActive = true];
                    internalUsers.addAll(directionUsers);
                    
                    List<User> commerceBOUsers = [SELECT Id FROM User WHERE Profile.Name like 'Commerce BO' AND isActive = true];
                    internalUsers.addAll(commerceBOUsers);
                    
                    List<User> commercePUsers = [SELECT Id FROM User WHERE Profile.Name like 'Commerce Projets' AND isActive = true];
                    internalUsers.addAll(commercePUsers);
                    
                    List<User> qualiteCeeUsers = [SELECT Id FROM User WHERE Profile.Name like 'Qualité CEE' AND isActive = true];
                    internalUsers.addAll(qualiteCeeUsers);
                    
                    List<User> dafUsers = [SELECT Id FROM User WHERE Profile.Name like 'DAF' AND isActive = true];
                    internalUsers.addAll(dafUsers);
                }
            
            String MyRecordTypeId = rd.Id;
            for(User u : myUsers){
                Task myTask = new Task();
                myTask.RecordTypeId = MyRecordTypeId;
                myTask.Subject = notif.Name;
                myTask.interactionGroup__c = notif.Groupe_Interaction__c;
                myTask.interactionModel__c = notif.Modele_Interaction__c;
                myTask.Description = notif.contenu__c;
                myTask.Status = 'Programmée';
                myTask.Canal__c = 'Notification';
                myTask.WhoId = u.contactid;
                myTask.Notification_My_Synerciel__c = notif.id;
                myTask.OwnerId = admin.id;
                myTask.WhatId = u.AccountId;
                myTask.IsVisibleInSelfService = true;
                tachesNotif.add(myTask);
            }
            // CREATE TASKS FOR INTERNAL USERS
            for(User u : internalUsers){
                Task myTask = new Task();
                myTask.RecordTypeId = MyRecordTypeId;
                myTask.Subject = notif.Name;
                myTask.interactionGroup__c = notif.Groupe_Interaction__c;
                myTask.interactionModel__c = notif.Modele_Interaction__c;
                myTask.Description = notif.contenu__c;
                myTask.Status = 'Programmée';
                myTask.Canal__c = 'Notification';
                myTask.Notification_My_Synerciel__c = notif.id;
                myTask.OwnerId = u.id;
                myTask.IsVisibleInSelfService = true;
                tachesNotif.add(myTask);
            }
            
            // ADD Contact Temoin
            Task myTask = new Task();
            myTask.RecordTypeId = MyRecordTypeId;
            myTask.Subject = notif.Name;
            myTask.interactionGroup__c = notif.Groupe_Interaction__c;
            myTask.interactionModel__c = notif.Modele_Interaction__c;
            myTask.Description = notif.contenu__c;
            myTask.Status = 'Programmée';
            myTask.Canal__c = 'Notification';
            myTask.WhoId = contactTemoin.ContactId;
            myTask.Notification_My_Synerciel__c = notif.Id;
            myTask.OwnerId = admin.id;
            myTask.WhatId = contactTemoin.AccountId;
            myTask.IsVisibleInSelfService = true;
            tachesNotif.add(myTask);
            
            notifsToUpdate.add(notif.Id);
        }
        system.debug(tachesNotif);
        insert tachesNotif;
    }
    global void finish(Database.BatchableContext bc){
        MAJ_notif_synerciel(notifsToUpdate);
    }
    
    public static void MAJ_notif_synerciel(set<Id> myNotifIds){
        list<Notification_my_synerciel__c> myNotifs = [SELECT Id, Statut__c, Date_Heure_envoi__c 
                                                       FROM Notification_my_synerciel__c 
                                                       WHERE Id IN :myNotifIds];
        
        for(Notification_my_synerciel__c myNotif : myNotifs){
            myNotif.isProgrammed__c = false;
        }
        update myNotifs;
    }
}