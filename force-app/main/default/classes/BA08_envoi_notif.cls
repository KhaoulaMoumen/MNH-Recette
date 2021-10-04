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


global class BA08_envoi_notif implements Database.Batchable<sObject>, Database.Stateful {
    String taskPlanned = 'Programmée';
    String notification = 'Notification';
    Date dateToday = Date.today();
    Datetime mytime = Datetime.now();
    Map<Id, Integer> notifErrorMap = new Map<Id, Integer>();
    set<Id> notifsToUpdate = new set<Id>();
    
    CustomNotificationType notifType = [SELECT Id 
                                        FROM CustomNotificationType 
                                        WHERE DeveloperName = 'Notification_My_Synerciel' LIMIT 1];
    
    
    global Database.QueryLocator start (Database.BatchableContext bc) {
        return Database.getQueryLocator('SELECT Id,WhoId,Status,Heure_envoi_programmee__c,Canal__c,Subject,Date_envoi_programmee__c,RecordType.name,Utilisateur_My_Synerciel__c, notification_my_synerciel__c,notification_my_synerciel__r.contenu__c,notification_my_synerciel__r.name,notification_my_synerciel__r.Titre_notification__c,OwnerId FROM Task WHERE Notification_My_Synerciel__c != null AND Status = :taskPlanned AND Canal__c = :notification AND Date_envoi_programmee__c = :dateToday AND RecordType.name = :notification ');
    }
    global void execute(Database.BatchableContext bc, List<task> scope){
        
        system.debug('tasks'+scope);
        for(Task myTask : scope)
        {
            if(myTask.Heure_envoi_programmee__c.split(' ')[0].equals(string.valueOf(mytime.hour())) || Test.isRunningTest()){

                Messaging.CustomNotification obj = new Messaging.CustomNotification();
                obj.setNotificationTypeId(notifType.Id);
                obj.setTargetId(myTask.id);
                obj.setTitle(myTask.notification_my_synerciel__r.Titre_notification__c);
                obj.setBody(myTask.notification_my_synerciel__r.contenu__c);
                set <String> contacts = new set <String>();
            	set<String> internalUsers = new set<String>();
                set <String> users = new set <String>();
                if(myTask.WhoId != NULL) contacts.add(myTask.WhoId);
            	else internalUsers.add(myTask.OwnerId);

                List<User> usersList1 = [SELECT Id FROM User WHERE ContactId IN  :contacts AND ContactId != NULL AND isActive = true];
                for(User u : usersList1) users.add(u.Id);
            
            	List<User> usersList2 = [SELECT Id FROM User WHERE Id IN  :internalUsers AND isActive = true];
                for(User u : usersList2) users.add(u.Id);

                try {
                    obj.send(users);
                    myTask.Status = 'Envoyée';
                    myTask.Description= myTask.notification_my_synerciel__r.contenu__c;
                    myTask.ActivityDate= Date.today();
                    
                }
                catch (Exception e) {
                    System.debug('Problem sending notification: ' + e.getMessage());
                    //notifErrorMap.put(myTask.Notification_my_synerciel__c, 1);
                }
                //Envoi_notif.envoyer(myTask,notifType.Id);
                notifsToUpdate.add(myTask.Notification_My_Synerciel__c);
            }
            
        }
        // UPDATE TASKS
        update scope;
        
    }
    global void finish(Database.BatchableContext bc){
        MAJ_notif_synerciel(notifsToUpdate);
    }
    
     public static void MAJ_notif_synerciel(set<Id> myNotifIds){
        list<Notification_my_synerciel__c> myNotifs = [SELECT Id, Statut__c, Date_Heure_envoi__c 
                                                       FROM Notification_my_synerciel__c 
                                                       WHERE Id IN :myNotifIds];
        
        for(Notification_my_synerciel__c myNotif : myNotifs){
            myNotif.Statut__c = '✅ - Envoyée';
            myNotif.Date_Heure_envoi__c= Datetime.now(); 
        }
        update myNotifs;
        
    }
    /*
    public static void envoyer(Task myTask, String strNotificationId){
        system.debug('I am here*************');
        Messaging.CustomNotification obj = new Messaging.CustomNotification();
        obj.setNotificationTypeId(strNotificationId);
        obj.setTargetId(myTask.id);
        obj.setTitle(myTask.notification_my_synerciel__r.Titre_notification__c);
        obj.setBody(myTask.notification_my_synerciel__r.contenu__c);
        set <String> contacts = new set <String>();
        set <String> users = new set <String>();
        contacts.add(myTask.WhoId);
        system.debug('myTask.WhoId*************'+myTask.WhoId);
        List<User> usersList = [SELECT Id FROM User WHERE ContactId IN  :contacts AND isActive = true];
        //for(User u : usersList) users.add(u.Id);
        users.add('0051r00000AZoUrAAL');
        system.debug('users*************'+users);
        try {
            system.debug('obj recipients*************'+obj);
            //obj.send(users);
            // myTask.Status = 'Envoyée';
            // myTask.Description= myTask.notification_my_synerciel__r.contenu__c;
            //myTask.ActivityDate= Date.today();
            
        }
        catch (Exception e) {
            System.debug('Problem sending notification: ' + e.getMessage());
            //notifErrorMap.put(myTask.Notification_my_synerciel__c, 1);
        }
    }
    */    
}