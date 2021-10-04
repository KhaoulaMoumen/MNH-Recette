@isTest
public with sharing class TEST_Batch_Dataxess_UpdateAccounts {
    @testSetup 
    static void setup() {

        Altares_Configuration__c config = Util_Test.CustomSetting.createConfiguration();
        
        Datetime myDateTime = Datetime.now();
        Datetime newDateTime = myDateTime.addDays(-10);
	
        Account a = new Account();
        a.name='test';
        a.sirenSiret__c = '44059015600053';
        a.profil__c = 'Adhérent';
        a.administrativeStatus__c = 'Accepté';
        a.BillingPostalCode = '00000';
        a.Derniere_mise_jour_Altares__c = newDateTime;
        insert a;
    


    }
    @isTest static void test_Batch() {
        API_serviceCallistoAltaresCustomMockImpl mock = new API_serviceCallistoAltaresCustomMockImpl(null);

        
        Test.startTest();
        Test.setMock(WebServiceMock.class,mock);
            Batch_Dataxess_UpdateAccounts bc = new Batch_Dataxess_UpdateAccounts();
            Database.executeBatch(bc,10);
        Test.stopTest();

        List<Account> accLs = [SELECT id, SIRET__c,Derniere_mise_jour_Altares__c FROM Account  WHERE Derniere_mise_jour_Altares__c = LAST_N_DAYS:7];

        for(Account acc : accLs){

            Date myDate = date.newinstance(acc.Derniere_mise_jour_Altares__c.year(), acc.Derniere_mise_jour_Altares__c.month(), acc.Derniere_mise_jour_Altares__c.day());
            System.assertEquals(Date.today(), myDate);
        }
    }
}