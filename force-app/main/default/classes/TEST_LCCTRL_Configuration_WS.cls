@isTest
private with sharing class TEST_LCCTRL_Configuration_WS {
	
	/* SETUP */
	@testSetup static void setup_testSetup() {
		setup_CreateConfiguration();
	}

	@isTest static void setup_CreateConfiguration() {
		Altares_Configuration__c config = Util_Test.CustomSetting.createConfiguration();
		System.assertEquals('Login__c', config.Login__c);
		System.assertEquals('Mot_de_passe__c', config.Mot_de_passe__c);
		System.assertEquals('Reference_client__c', config.Reference_client__c);
	}

	@isTest static void test_getConfiguration() {
		Map<String,String> config = LCCTRL_Configuration_WS.getConfiguration();
		System.assertEquals('Login__c', config.get('login'));
		System.assertEquals('Reference_client__c', config.get('refClient'));
		System.assertEquals('******************', config.get('password'));
		
	}
	
	@isTest static void test_setConfiguration() {
		
		String refClient = 'ref';
		String login = 'log';
		String password = 'pas';

		LCCTRL_Configuration_WS.setConfiguration(refClient, login, password );

		Altares_Configuration__c config = Altares_Configuration__c.getOrgDefaults();
		System.assertEquals(login, config.Login__c);
		System.assertEquals(refClient, config.Reference_client__c);
		System.assertEquals(password, config.Mot_de_passe__c);

	}
	
}