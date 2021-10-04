@isTest(SeeAllData=false)
public class BA08_envoi_notif_TEST {
    
    @testSetup 
    static void setup() {
        
        User admin = [SELECT id FROM user WHERE id =: Label.Administratif_Synerciel_Id LIMIT 1];
        
        Recordtype rt = [SELECT Id FROM recordtype WHERE name = 'Notification'];
        
        list<Account> accs = Datafactory.createAccounts(1, 'Adhérent', 'Accepté', true);
        list<Contact> cons =Datafactory.createContacts(1, accs[0].id, 'Interlocuteur administratif', false);
        
        list<User> users = Datafactory.createUsers(1, 'Adhérent', false, false, false, false);
     
        Notification_My_Synerciel__c notif = new Notification_My_Synerciel__c(Name='TEST NOTIF XX',
                                                                              Titre_notification__c='test',
                                                                              Contenu__c='test',
                                                                              Ciblage__c='Tous les adhérents',
                                                                              Statut__c = '📝 - Brouillon',
                                                                              Date_Heure_envoi__c=Datetime.now(),
                                                                              Date_envoi_programmee__c=Date.today(),
                                                                              Heure_envoi_programmee__c='6 heures',
                                                                              Groupe_Interaction__c = 'CCH',
                                                                              Modele_Interaction__c = 'COACHING 1	'
                                                                             );
        insert notif;
        
        // GENERATE TASKS
        notif.Statut__c = '🕓 - Programmée';
        update notif;
        
        
        
        list<Task> tasks = DataFactory.createTaches(10, notif.Name, notif.id, UserInfo.getUserId(), Date.today(), true);
        tasks[0].Notification_My_Synerciel__c =notif.id;
        tasks[0].Subject = notif.Name;
        tasks[0].interactionGroup__c = notif.Groupe_Interaction__c;
        tasks[0].interactionModel__c = notif.Modele_Interaction__c;
        tasks[0].Description = notif.Contenu__c;
        tasks[0].Status = 'Programmée';
        tasks[0].Canal__c = 'Notification';
        tasks[0].WhoId = cons[0].id;
        tasks[0].Notification_My_Synerciel__c = notif.id;
        tasks[0].OwnerId = admin.id;
        tasks[0].WhatId = accs[0].id;
        tasks[0].RecordTypeId=Schema.SObjectType.Task.getRecordTypeInfosByName().get('Notification').getRecordTypeId();
        update tasks[0];
    }
    
    static testmethod void test() {
        
        
        Test.startTest();
        
        Notification_My_Synerciel__c notification = [SELECT Id 
                                                     FROM Notification_My_Synerciel__c
                                                     WHERE Name='TEST NOTIF XX' 
                                                     LIMIT 1
                                                    ];
        
        list<Task> tasks = [SELECT Id, Status, Heure_envoi_programmee__c, Canal__c, Subject,Date_envoi_programmee__c,WhoId,
                            RecordType.name, Utilisateur_My_Synerciel__c, notification_my_synerciel__c, 
                            notification_my_synerciel__r.contenu__c, notification_my_synerciel__r.name, notification_my_synerciel__r.Titre_notification__c 
                            FROM Task
                            WHERE Canal__c = 'Notification' AND notification_my_synerciel__c = :notification.Id
                           ];
        
        system.debug('tasks'+tasks);
        
        //Envoi_notif.action(tasks,DateTime.newInstance(2020, 1, 31, 6, 8, 16));
       // BA08_envoi_notif.envoyer(tasks[0], tasks[0].Notification_My_Synerciel__c);
        SchBT06_envoi_notif myClass = new SchBT06_envoi_notif ();   
        String chron = '0 0 6 * * ?';        
        system.schedule('Test Sched', chron, myClass);
        Test.stopTest();  
        
    }
}