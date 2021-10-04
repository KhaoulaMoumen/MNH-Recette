@isTest
public class BATCH_RDD_TEST {
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
        
        Offre_et_service_partenaire__c offreTest1 = new Offre_et_service_partenaire__c(Categorie__c='Je me déplace',Titre_offre_service__c='11111');
        insert offreTest1;
        
        Offre_et_service_partenaire__c offreTest2 = new Offre_et_service_partenaire__c(Categorie__c='Je me déplace',Titre_offre_service__c='11211');
        insert offreTest2;
        
        listUser.add(u);
        
    }
    
    
    @isTest(SeeAllData=false)
    public static void testBatch(){
        List<User> listUser = [SELECT Id,ContactId,Contact.AccountId FROM User WHERE isActive = true AND isPortalEnabled = true LIMIT 1];        
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        BATCH_RDD myBatchObject2 = new BATCH_RDD(02,2021); 
        myBatchObject2.start(null);
        myBatchObject2.execute(null,listUser);
        myBatchObject2.finish(null);
        
        
        /*Id batchId = Database.executeBatch(myBatchObject2,1);*/
        Test.stopTest();
        
        
        
    }
    
   	@isTest(SeeAllData=false)
    public static void testRDDConstructor(){
         BATCH_RDD batch = new BATCH_RDD('2020-01-01','2020-01-01');
      	 System.assertEquals('2020-01-01', batch.startDate);
    
    }
    
    
}