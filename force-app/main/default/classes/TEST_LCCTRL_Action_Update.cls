@isTest
private with sharing class TEST_LCCTRL_Action_Update {
	
	@testSetup static void setup_testSetup() {
		setup_CreateConfiguration();
	}

	@isTest static void setup_CreateConfiguration() {
		Altares_Configuration__c config = Util_Test.CustomSetting.createConfiguration();
		System.assertEquals('Login__c', config.Login__c);
		System.assertEquals('Mot_de_passe__c', config.Mot_de_passe__c);
		System.assertEquals('Reference_client__c', config.Reference_client__c);
	}

	@isTest static void test_updateRecord() {
		
		
		Account a = new Account();
		a.name='TEST';
		a.sirenSiret__c = '44059015600053';
        a.profil__c = 'Adhérent';
        a.administrativeStatus__c = 'Accepté';
		insert a;

		API_serviceCallistoAltaresCustomMockImpl mock = new API_serviceCallistoAltaresCustomMockImpl(null);

		Test.startTest();
		Test.setMock(WebServiceMock.class,mock);
		LCCTRL_Action_Update.updateRecord('Account', a.Id);
		Test.stopTest();

		Account newAccount = [SELECT Code_postal__c FROM Account WHERE Id = :a.Id];
		System.assertEquals('00000',newAccount.Code_postal__c);
	}
	
}