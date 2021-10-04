@isTest
public class Envoi_notif_test {
    @testSetup 
    static void setup() {
        user u = [select id from user where name like '%talan' limit 1];
        Recordtype rt = [select id from recordtype where name = 'Notification'];
        Notification_My_Synerciel__c notif = new Notification_My_Synerciel__c(Name='test',Titre_notification__c='test',
                                                                             Contenu__c='test',Ciblage__c='Tous les adhérents',
                                                                             Date_Heure_envoi__c=Datetime.now(),
                                                                             Date_envoi_programmee__c=Date.today(),
                                                                             Heure_envoi_programmee__c='6 heures');
        insert notif;
        list<Task> tasks =DataFactory.createTaches(1, 'Mise en demeure – Motif : XXXX', notif.id, u.id, Date.today(), true);
        tasks[0].Notification_My_Synerciel__c =notif.id;
        tasks[0].Status ='Programmée';
        tasks[0].Canal__c = 'Notification';
        tasks[0].RecordTypeId=Schema.SObjectType.Task.getRecordTypeInfosByName().get('Notification').getRecordTypeId();
        update tasks[0];
    }
    static testmethod void test() {
        
        
       Test.startTest();
        list<Task> tasks = [select id,Status,Heure_envoi_programmee__c,Canal__c,Subject,Date_envoi_programmee__c,
                            RecordType.name,Utilisateur_My_Synerciel__c, notification_my_synerciel__c,
                            notification_my_synerciel__r.contenu__c,notification_my_synerciel__r.name,notification_my_synerciel__r.Titre_notification__c 
                            from task where Canal__c = 'Notification' ];
        Envoi_notif.action(tasks,DateTime.newInstance(2020, 1, 31, 6, 8, 16));
        SchBT06_envoi_notif myClass = new SchBT06_envoi_notif ();   
         String chron = '0 0 6 * * ?';        
         system.schedule('Test Sched', chron, myClass);
        Test.stopTest();  
        
    }
}