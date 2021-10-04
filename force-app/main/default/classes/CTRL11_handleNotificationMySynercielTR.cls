public class CTRL11_handleNotificationMySynercielTR {
   
    public static void createTaskswithBatch(){
        Database.executeBatch(new BA15_CreateNotificationTasks(),1); 
    }
    
    public static void updateNotifications(Set<Id> notifIds){
        List<Notification_My_Synerciel__c> notifs = [SELECT Id, isProgrammed__c FROM Notification_My_Synerciel__c WHERE Id IN :notifIds];
        if(notifs.size() > 0){
            for(Notification_My_Synerciel__c n : notifs)  n.isProgrammed__c = true;
            update notifs;
        }
    }
    public static void deleteTacheNotif (Notification_My_Synerciel__c notif){
        list<Task> tachesNotif = [select id from Task where Notification_My_Synerciel__c =: notif.id];
        delete tachesNotif;
    }
 /*public static void createTacheNotif (Notification_My_Synerciel__c notif){
        list<User> myUsers = new list<User>();
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
        RecordType rd = [select Id from RecordType where Name like 'Notification'];
        String MyRecordTypeId = rd.Id;
        list<Task> tachesNotif = new list<Task>();
        User admin = [select id from user where id =: Label.Administratif_Synerciel_Id limit 1];
        for(User u : myUsers){
            Task myTask = new Task();
            myTask.RecordTypeId = MyRecordTypeId;
            myTask.Subject = notif.Name;
            myTask.interactionGroup__c = notif.Groupe_Interaction__c;
            myTask.interactionModel__c = notif.Modele_Interaction__c;
            myTask.Description = notif.Contenu__c;
            myTask.Status = 'Programmée';
            myTask.Canal__c = 'Notification';
            myTask.WhoId = u.contactid;
            myTask.Notification_My_Synerciel__c = notif.id;
            myTask.OwnerId = admin.id;
            myTask.WhatId = u.AccountId;
            myTask.IsVisibleInSelfService = true;
            tachesNotif.add(myTask);
        }
        // ADD Contact Temoin
        User contactTemoin = [SELECT Id,AccountId, ContactId FROM User WHERE Name = 'Contact TEMOIN' LIMIT 1];
        Task myTask = new Task();
        myTask.RecordTypeId = MyRecordTypeId;
        myTask.Subject = notif.Name;
        myTask.interactionGroup__c = notif.Groupe_Interaction__c;
        myTask.interactionModel__c = notif.Modele_Interaction__c;
        myTask.Description = notif.Contenu__c;
        myTask.Status = 'Programmée';
        myTask.Canal__c = 'Notification';
        myTask.WhoId = contactTemoin.ContactId;
        myTask.Notification_My_Synerciel__c = notif.id;
        myTask.OwnerId = admin.id;
        myTask.WhatId = contactTemoin.AccountId;
        myTask.IsVisibleInSelfService = true;
        tachesNotif.add(myTask);
        
        // INSERT TASKS
        insert tachesNotif;
        
    }*/    
}