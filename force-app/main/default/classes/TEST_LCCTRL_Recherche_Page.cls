@isTest
private with sharing class TEST_LCCTRL_Recherche_Page {
	
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

	@isTest static void test_searchSimple() {

		API_voCallistoAltares.RechercheInfo info = new API_voCallistoAltares.RechercheInfo();
		info.actif = true;
		info.raisonSociale = 'TEST';

		API_responseCallistoAltares.RechercheSimpleResponse mockResponse = new API_responseCallistoAltares.RechercheSimpleResponse();
		mockResponse.correct = true;
		mockResponse.nbElt = 20;
		mockResponse.nbMatch = 40;
		mockResponse.myInfo = new List<API_voCallistoAltares.RechercheInfo>{info , info};

		API_serviceCallistoAltaresCustomMockImpl mock = new API_serviceCallistoAltaresCustomMockImpl(mockResponse);
		
		
		Test.startTest();
		Test.setMock(WebServiceMock.class,mock);
		Map<String,Object> result = LCCTRL_Recherche_Page.searchSimple('TEST' ,'');
		Test.stopTest();

		List<API_voCallistoAltares.RechercheInfo> company = (List<API_voCallistoAltares.RechercheInfo>) result.get('results');

		System.assertEquals(20,(Integer)result.get('nbResult'));
		System.assertEquals(40,(Long)result.get('nbMatch'));
		System.assertEquals(new List<API_voCallistoAltares.RechercheInfo>{info , info},company);

	}
	
	@isTest static void test_searchEtablissement() {
		
		API_voCallistoAltares.RechercheInfo info = new API_voCallistoAltares.RechercheInfo();
		info.actif = true;
		info.raisonSociale = 'TEST';

		API_responseCallistoAltares.RechercheEntrepriseResponse mockResponse = new API_responseCallistoAltares.RechercheEntrepriseResponse();
		mockResponse.correct = true;
		mockResponse.nbElt = 20;
		mockResponse.nbMatch = 40;
		mockResponse.myInfo = new List<API_voCallistoAltares.RechercheInfo>{info , info};

		API_serviceCallistoAltaresCustomMockImpl mock = new API_serviceCallistoAltaresCustomMockImpl(mockResponse);
		
		
		Test.startTest();
		Test.setMock(WebServiceMock.class,mock);
		Map<String,Object> result = LCCTRL_Recherche_Page.searchEtablissement(0,'TEST', 'test', '123456789', 'test', 'test', 'test', 'test');
		Test.stopTest();

		List<API_voCallistoAltares.RechercheInfo> company = (List<API_voCallistoAltares.RechercheInfo>) result.get('results');

		System.assertEquals(20,(Integer)result.get('nbResult'));
		System.assertEquals(40,(Long)result.get('nbMatch'));
		System.assertEquals(new List<API_voCallistoAltares.RechercheInfo>{info , info},company);

	}

	@isTest static void test_searchAssociation() {
		API_voCallistoAltares.RechercheAssociationInfo info = new API_voCallistoAltares.RechercheAssociationInfo();
		info.titre = 'TEST';

		API_responseCallistoAltares.RechercheAssociationResponse mockResponse = new API_responseCallistoAltares.RechercheAssociationResponse();
		mockResponse.correct = true;
		mockResponse.nbElt = 20;
		mockResponse.nbMatch = 40;
		mockResponse.myInfo = new List<API_voCallistoAltares.RechercheAssociationInfo>{info , info};

		API_serviceCallistoAltaresCustomMockImpl mock = new API_serviceCallistoAltaresCustomMockImpl(mockResponse);
		
		
		Test.startTest();
		Test.setMock(WebServiceMock.class,mock);
		Map<String,Object> result = LCCTRL_Recherche_Page.searchAssociation('TEST', 'test', '');
		Test.stopTest();

		List<API_voCallistoAltares.RechercheAssociationInfo> company = (List<API_voCallistoAltares.RechercheAssociationInfo>) result.get('results');

		System.assertEquals(20,(Integer)result.get('nbResult'));
		System.assertEquals(40,(Long)result.get('nbMatch'));
		System.assertEquals(new List<API_voCallistoAltares.RechercheAssociationInfo>{info , info},company);
	}

	@isTest static void test_findDoublon() {


		Account l = new Account();
		l.name='TEST';
		l.SIRET__c = '1234567891011';
		insert l;
		
		Test.startTest();
		List<sObject> result = LCCTRL_Recherche_Page.findDoublon('Account', '1234567891011');
		Test.stopTest();


		System.assertEquals(1,result.size());
		System.assertEquals(l.id,result[0].get('Id'));
	}

	@isTest static void test_createRecord() {

		API_serviceCallistoAltaresCustomMockImpl mock = new API_serviceCallistoAltaresCustomMockImpl(null);

		Test.startTest();
		Test.setMock(WebServiceMock.class,mock);
		Id result = LCCTRL_Recherche_Page.createRecord('Account', '1234567891011');
		Test.stopTest();

		Account newAccount = [SELECT name FROM Account WHERE Id = :result];
		System.assertEquals('CompanyName',newAccount.name);

	}
	
}