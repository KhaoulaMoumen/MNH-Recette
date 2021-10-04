@isTest
private with sharing class TEST_LCCTRL_Configuration_Package {
	
	/* SETUP */
	@testSetup static void setup_testSetup() {
		setup_CreateConfiguration();
	}

	@isTest static void setup_CreateConfiguration() {
		Altares_Configuration__c conf = Util_Test.CustomSetting.createConfiguration();
		System.assertEquals(200, conf.Nombre_de_resultat__c);
	}

	@isTest static void test_getPackageConf() {
		Map<String,Object> config = LCCTRL_Configuration_Package.getPackageConf();
		System.assertEquals(200, config.get('nbResult'));
		System.assert(config.containsKey('synchro'));
		System.assert(config.containsKey('synchro_dirigeant'));
		System.assert(config.containsKey('synchro_actionaire'));
		System.assert(config.containsKey('synchro_participation'));
	}
	
	@isTest static void test_setPackageConf() {
		
		Decimal nbResult = 20;

		List<MD_Syncro_Configuration> synchro = new List<MD_Syncro_Configuration>{new MD_Syncro_Configuration('Adresse','Adresse',true,true,false)};
		String synchroJSON = JSON.serialize(synchro);

		Test.startTest();
		
		LCCTRL_Configuration_Package.setPackageConf(nbResult,synchroJSON,synchroJSON,synchroJSON,synchroJSON);
		
		Test.stopTest();

		Altares_Configuration__c config = Altares_Configuration__c.getOrgDefaults();

		System.assertEquals(nbResult, config.Nombre_de_resultat__c);
	}
	
}