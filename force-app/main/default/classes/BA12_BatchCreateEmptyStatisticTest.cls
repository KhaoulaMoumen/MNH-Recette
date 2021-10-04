@isTest
public class BA12_BatchCreateEmptyStatisticTest {
    
    
    @isTest(SeeAllData=false)
    public static void testBatch(){
        
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
        
        Offre_et_service_partenaire__c offreTest1 = new Offre_et_service_partenaire__c(Categorie__c='Je me déplace',Titre_offre_service__c='11111');
        insert offreTest1;
        
        Offre_et_service_partenaire__c offreTest2 = new Offre_et_service_partenaire__c(Categorie__c='Je me déplace',Titre_offre_service__c='11211');
        insert offreTest2;
        
        listUser.add(u);
        
        Test.startTest();
        BA12_BatchCreateEmptyStatisticAnalytics myBatchObject = new BA12_BatchCreateEmptyStatisticAnalytics(); 
        //Id batchId = Database.executeBatch(myBatchObject,1);
        String CRON_EXP2 = '0 0 0 3 9 ? 2022';
        String job2Id = System.schedule('SchedulerTE2', CRON_EXP2, new SchBT08_ScheduleStatAnalyticsCreation());
        CronTrigger ct2 = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :job2Id]; 
        System.assertEquals(0, ct2.TimesTriggered);
        Test.stopTest();
        
        List<Statistique_Analtytics__c> retList = [SELECT Id FROM Statistique_Analtytics__c];
        
        //System.assertNotEquals(0, retList.size());
        //System.assertEquals(2, retList.size());
        
        
        
    }
    
    
}