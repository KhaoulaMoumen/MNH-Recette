@isTest
public class TR06_Notification_my_synerciel_test {
    @testSetup 
    static void setup() {
        
        // CREATE ACCOUNTS		
        list<Account> accs = Datafactory.createAccounts(1, 'Adhérent', 'Accepté', true);
        
        // CREATE CONTACTS
        list<Contact> cons =Datafactory.createContacts(1, accs[0].id, 'Interlocuteur administratif', true);
        
        // CREATE USERS
        list<User> myusers = Datafactory.createUsers(1,'Adhérent',false,false,false,false);
        myusers[0].contactid=cons[0].id;
        insert myusers[0];
        
        Recordtype rt = [select id from recordtype where name = 'Notification'];
        
        // CREATE NOTIFICATIONS MYSYNERCIEL
        Notification_My_Synerciel__c notif = new Notification_My_Synerciel__c(Name='test',
                                                                              Titre_notification__c='test',
                                                                              Contenu__c='test',
                                                                              Ciblage__c='Tous les adhérents',
                                                                              Date_Heure_envoi__c=Datetime.now(),
                                                                              Date_envoi_programmee__c=Date.today(),
                                                                              Heure_envoi_programmee__c='6 heures',
                                                                              Statut__c='📝 - Brouillon',
                                                                              Envoi_utilisateurs_interne__c = true);
        insert notif;
        Notification_My_Synerciel__c notif1 = new Notification_My_Synerciel__c(Name='test1',
                                                                               Titre_notification__c='test1',
                                                                               Contenu__c='test',
                                                                               Ciblage__c='Tous les partenaires',
                                                                               Date_Heure_envoi__c=Datetime.now(),
                                                                               Date_envoi_programmee__c=Date.today(),
                                                                               Heure_envoi_programmee__c='12 heures',
                                                                               Statut__c='📝 - Brouillon',
                                                                               Envoi_utilisateurs_interne__c = true);
        insert notif1;
        Notification_My_Synerciel__c notif2 = new Notification_My_Synerciel__c(Name='test2',
                                                                               Titre_notification__c='test2',
                                                                               Contenu__c='test',
                                                                               Ciblage__c='Les adhérents membre d\'un CCH',
                                                                               Date_Heure_envoi__c=Datetime.now(),
                                                                               Date_envoi_programmee__c=Date.today(),
                                                                               Heure_envoi_programmee__c='17 heures',
                                                                               Statut__c='📝 - Brouillon',
                                                                               Envoi_utilisateurs_interne__c = true);
        insert notif2;
        Notification_My_Synerciel__c notif3 = new Notification_My_Synerciel__c(Name='test3',
                                                                               Titre_notification__c='test3',
                                                                               Contenu__c='test',
                                                                               Ciblage__c='Les adhérents PEE',
                                                                               Date_Heure_envoi__c=Datetime.now(),
                                                                               Date_envoi_programmee__c=Date.today(),
                                                                               Heure_envoi_programmee__c='6 heures',
                                                                               Statut__c='📝 - Brouillon',
                                                                               Envoi_utilisateurs_interne__c = true);
        insert notif3;
        
        list<Task> tasks =DataFactory.createTaches(1, 'Notification', notif.id, myusers[0].id, Date.today(), true);
        tasks[0].Notification_My_Synerciel__c =notif.id;
        tasks[0].Status ='Programmée';
        tasks[0].Canal__c = 'Notification';
        tasks[0].RecordTypeId=Schema.SObjectType.Task.getRecordTypeInfosByName().get('Notification').getRecordTypeId();
        update tasks[0];
        
    }
    
    static testmethod void testSuppression() {
        Test.startTest();
        Notification_My_Synerciel__c myNotif = [select id from Notification_My_Synerciel__c where Name like 'test' limit 1];
        myNotif.Statut__c = '⛔ - Annulée';
        update myNotif;
        Test.stopTest();
        list<Task> tasks = [select id from Task where Notification_My_Synerciel__c =: myNotif.id];
        System.assertEquals(0, tasks.size());
        
    }
    static testmethod void testCreation() {
        Test.startTest();
        
        Notification_My_Synerciel__c myNotif = [select id from Notification_My_Synerciel__c where Name = 'test' limit 1];
        myNotif.Statut__c = '🕓 - Programmée';
        update myNotif;
        
        Notification_My_Synerciel__c myNotif1 = [select id from Notification_My_Synerciel__c where Name = 'test1' limit 1];
        myNotif1.Statut__c = '🕓 - Programmée';
        //update myNotif1;
        
        Notification_My_Synerciel__c myNotif2 = [select id from Notification_My_Synerciel__c where Name = 'test2' limit 1];
        myNotif2.Statut__c = '🕓 - Programmée';
        //update myNotif2;
        
        Notification_My_Synerciel__c myNotif3 = [select id from Notification_My_Synerciel__c where Name = 'test3' limit 1];
        myNotif3.Statut__c = '🕓 - Programmée';
        //update myNotif3;
        
        Test.stopTest();
        list<Task> tasks = [select id from Task where Notification_My_Synerciel__c =: myNotif.id];
        
        //System.assertEquals(tasks.size(), 3);
        
    }
    
}