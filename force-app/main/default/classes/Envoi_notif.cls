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
public class Envoi_notif {
    public static void action(list<Task> myTasks,Datetime mytime){
        set<Notification_My_Synerciel__c> notifsToUpdate = new set<Notification_My_Synerciel__c>();
        set<Notification_My_Synerciel__c> notifsNotToUpdate = new set<Notification_My_Synerciel__c>();

        CustomNotificationType notifType = [SELECT Id, CustomNotifTypeName from CustomNotificationType 
                                            WHERE DeveloperName = 'Notification_My_Synerciel' limit 1 ];
        for(Task myTask : myTasks){
           // if((myTask.Status == 'Programmée') && (myTask.Canal__c == 'Notification')&& (myTask.Date_envoi_programmee__c == Date.today() )&& (myTask.Heure_envoi_programmee__c.split(' ')[0].equals(string.valueOf(mytime.hour())))&& (myTask.RecordType.name == 'Notification')){
           if((myTask.Status == 'Programmée') && (myTask.Canal__c == 'Notification')&& (myTask.Date_envoi_programmee__c == Date.today() )&& (myTask.RecordType.name == 'Notification')){
                Envoi_notif.envoyer(myTask,notifType.id);
            }
            if(myTask.Status == 'Envoyée'){
                notifsToUpdate.add(myTask.notification_my_synerciel__r);
            }
            else{
                notifsNotToUpdate.add(myTask.notification_my_synerciel__r);
            }
            
        }
        notifsToUpdate.removeAll(notifsNotToUpdate);
        Envoi_notif.MAJ_notif_synerciel(notifsToUpdate);
        update myTasks;
    }
    
    public static void envoyer(Task myTask, String strNotificationId){
        Messaging.CustomNotification obj = new Messaging.CustomNotification();
        obj.setNotificationTypeId(strNotificationId);
        obj.setTargetId(myTask.id);
        obj.setTitle(myTask.notification_my_synerciel__r.Titre_notification__c);
        obj.setBody(myTask.notification_my_synerciel__r.contenu__c);
        set <String> users = new set <String>();
        users.add(myTask.Utilisateur_My_Synerciel__c);
        try {
            obj.send(users);
            myTask.Status = 'Envoyée';
            myTask.Description= myTask.notification_my_synerciel__r.contenu__c;
            myTask.ActivityDate= Date.today();
            
        }
        catch (Exception e) {
            System.debug('Problem sending notification: ' + e.getMessage());
        }
    }
    
    
    
    public static void MAJ_notif_synerciel(set<notification_my_synerciel__c> myNotifs){
        list<notification_my_synerciel__c> notifs = new list<notification_my_synerciel__c>();
        for(notification_my_synerciel__c myNotif : myNotifs){
            myNotif.Statut__c = '✅ - Envoyée';
            myNotif.Date_Heure_envoi__c= Datetime.now(); 
            notifs.add(myNotif);
        }
        update notifs;
        
    }
}