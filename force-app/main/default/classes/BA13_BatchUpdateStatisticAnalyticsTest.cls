@isTest
public class BA13_BatchUpdateStatisticAnalyticsTest {
    @TestSetup
    public static void setup(){
        List<User> listUser = new List<User>();
        
        ID ProfileID = [ Select id from Profile where name = 'Adhérent'].id;
        
        Account acc = new Account(Name = 'Test Account');
        
        insert acc ;
        
        List<Contact> ContactList = new List<Contact>();
        
        Contact Con = new Contact( AccountID = acc .id, FirstName = 'User', LastName = 'test',
                                  
                                  email = 'testuser@xyz.com',Salutation = 'Mr.',Phone = '0101010101');
        
        insert Con;
        
        User u = new User( email='testuser@xyz.com', contactid = Con.id, profileid = profileid, UserName='testuser@xyz.com', alias='tuser', CommunityNickName='tuser',
                          
                          TimeZoneSidKey='America/New_York', LocaleSidKey='en_US', EmailEncodingKey='ISO-8859-1',
                          
                          LanguageLocaleKey='en_US', FirstName = 'User', LastName = 'Test' );
        
        insert u;
        
        
        String idUser = u.Id;
        list<Offre_et_service_partenaire__c> Offers =  new list<Offre_et_service_partenaire__c>();
        Offre_et_service_partenaire__c offreTest1 = new Offre_et_service_partenaire__c(Categorie__c='Je me déplace',Titre_offre_service__c='11111');
        offreTest1.Libelle_de_l_offre_service__c='Test';
        Offers.add(offreTest1);
        
        Offre_et_service_partenaire__c offreTest2 = new Offre_et_service_partenaire__c(Categorie__c='Je me déplace',Titre_offre_service__c='11211');
        offreTest2.Libelle_de_l_offre_service__c='Test';
        Offers.add(offreTest2); 
        insert Offers;
        
        listUser.add(u);
         
    }
    
   
    @isTest(SeeAllData=false)
    public static void testBatch(){
        List<User> listUser = [SELECT Id,ContactId,Contact.AccountId FROM User WHERE isActive = true AND isPortalEnabled = true LIMIT 1];
        
        
       System.debug(listUser.size());
        BA12_BatchCreateEmptyStatisticAnalytics myBatchObject = new BA12_BatchCreateEmptyStatisticAnalytics(); 
        //Id batchId = Database.executeBatch(myBatchObject,1);*/
        myBatchObject.start(null);
        myBatchObject.execute(null,listUser);
        myBatchObject.finish(null);
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
         BA13_BatchUpdateStatisticAnalytics myBatchObject2 = new BA13_BatchUpdateStatisticAnalytics(); 
        myBatchObject2.start(null);
        myBatchObject2.execute(null,listUser);
        myBatchObject2.finish(null);
        
         String CRON_EXP2 = '0 0 0 3 9 ? 2022';
        String job2Id = System.schedule('SchedulerTE2', CRON_EXP2, new SchBT09_ScheduleStatAnalyticsUpdate());
        CronTrigger ct2 = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :job2Id]; 
        System.assertEquals(0, ct2.TimesTriggered);
           
         
       /*Id batchId = Database.executeBatch(myBatchObject2,1);*/
        Test.stopTest();
      
        
        
    }
    
    
}