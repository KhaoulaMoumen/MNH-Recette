@isTest
private with sharing class API_serviceCallistoAltaresWebSvcTest {
	
    
    
	@isTest static void coverGeneratedCodeTypes() {
		Test.startTest();
		Test.setMock(WebServiceMock.class, new API_serviceCallistoAltaresMockImpl());

		Exception unexpectedException;

		try
		{
			API_serviceCallistoAltares parentObject = new API_serviceCallistoAltares();
			new API_serviceCallistoAltares.doRechercheAssociation_element();
			new API_serviceCallistoAltares.doRechercheAssociationResponse_element();
			new API_serviceCallistoAltares.doRechercheEntreprise_element();
			new API_serviceCallistoAltares.doRechercheEntrepriseResponse_element();
			new API_serviceCallistoAltares.doRechercheSimple_element();
			new API_serviceCallistoAltares.doRechercheSimpleResponse_element();
			new API_serviceCallistoAltares.getScore_element();
			new API_serviceCallistoAltares.getScoreResponse_element();
			new API_serviceCallistoAltares.getIdentiteAltaN4Entreprise_element();
			new API_serviceCallistoAltares.getIdentiteAltaN4EntrepriseResponse_element();
			new API_serviceCallistoAltares.getIdentiteAltaN4Etablissement_element();
			new API_serviceCallistoAltares.getIdentiteAltaN4EtablissementResponse_element();
			new API_serviceCallistoAltares.getListeDecideurs_element();
			new API_serviceCallistoAltares.getListeDecideursResponse_element();
			new API_serviceCallistoAltares.getListeDirigeantsStatutaires_element();
			new API_serviceCallistoAltares.getListeDirigeantsStatutairesResponse_element();
			new API_serviceCallistoAltares.getLiensCapitalistiques_element();
			new API_serviceCallistoAltares.getLiensCapitalistiquesResponse_element();
			new API_serviceCallistoAltares.setPortfolioItem_element();
			new API_serviceCallistoAltares.setPortfolioItemResponse_element();
			new API_requestCallistoAltares.ListeDirigeantRequest();
			new API_requestCallistoAltares.RechercheAssociationRequest();
			new API_requestCallistoAltares.RechercheEntrepriseRequest();
			new API_requestCallistoAltares.RechercheSimpleRequest();
			new API_requestCallistoAltares.SirenRequest();
			new API_requestCallistoAltares.SirenRnaRequest();
			new API_requestCallistoAltares.SirenSiretRequest();
			new API_responseCallistoAltares.ListeDecideursResponse();
			new API_responseCallistoAltares.ListeDirigeantsStatutairesResponse();
			new API_responseCallistoAltares.RechercheAssociationResponse();
			new API_responseCallistoAltares.RechercheEntrepriseResponse();
			new API_responseCallistoAltares.RechercheSimpleResponse();
			new API_responseCallistoAltares.RechercheAssociationResponse();
			new API_responseCallistoAltares.RechercheEntrepriseResponse();
			new API_responseCallistoAltares.RechercheSimpleResponse();
			new API_responseCallistoAltares.LiensCapitalistiquesResponse();
			new API_responseCallistoAltares.ScoreResponse();
			new API_responseCallistoAltares.CallistoResponse();
			new API_voCallistoAltares.AssociationInfo();
			new API_voCallistoAltares.CallistoException_x();
			new API_voCallistoAltares.CategorieRecherche();
			new API_voCallistoAltares.CategorieRechercheItem();
			new API_voCallistoAltares.DecideurInfo();
			new API_voCallistoAltares.DirigeantsStatutaireInfo();
			new API_voCallistoAltares.DirigeantStatutaireInfo();
			new API_voCallistoAltares.IdentiteAltaN4EntrepriseInfo();
			new API_voCallistoAltares.IdentiteAltaN4EtablissementInfo();
			new API_voCallistoAltares.ParametreCallisto();
			new API_voCallistoAltares.ParametreCallistoInfo();
			new API_voCallistoAltares.RechercheAssociationInfo();
			new API_voCallistoAltares.RechercheInfo();
			new API_voCallistoAltares.LiensCapitalistiquesInfo();
			new API_voCallistoAltares.ScoreInfo();
			new API_alerteRequestCallistoAltares.PortfolioSetExtendedRequest();
			new API_identiteResponseCallistoAltares.IdentiteAltaN4EnResponse();
			new API_identiteResponseCallistoAltares.IdentiteAltaN4EtResponse();
			new API_lienVoCallistoAltares.Actionnaire();
			new API_lienVoCallistoAltares.Participation();
		}
		catch (Exception excp)
		{
			unexpectedException = excp;
		}

		system.assertEquals(null, unexpectedException, 'Exceptions should be handled by the method');

		Test.stopTest();
	}
	@isTest static void coverCodeFordoRechercheAssociation(){
		Test.startTest();
		Test.setMock(WebServiceMock.class, new API_serviceCallistoAltaresMockImpl());
		API_serviceCallistoAltares.CallistoIdentiteSecureHttpsSoap11Endpoint testObject = new API_serviceCallistoAltares.CallistoIdentiteSecureHttpsSoap11Endpoint();
		Test.stopTest();
		System.assertEquals(null, testObject.doRechercheAssociation(null));
	}
	@isTest static void coverCodeFordoRechercheEntreprise(){
		Test.startTest();
		Test.setMock(WebServiceMock.class, new API_serviceCallistoAltaresMockImpl());
		API_serviceCallistoAltares.CallistoIdentiteSecureHttpsSoap11Endpoint testObject = new API_serviceCallistoAltares.CallistoIdentiteSecureHttpsSoap11Endpoint();
		Test.stopTest();
		System.assertEquals(null, testObject.doRechercheEntreprise(null));
	}
	@isTest static void coverCodeFordoRechercheSimple(){
		Test.startTest();
		Test.setMock(WebServiceMock.class, new API_serviceCallistoAltaresMockImpl());
		API_serviceCallistoAltares.CallistoIdentiteSecureHttpsSoap11Endpoint testObject = new API_serviceCallistoAltares.CallistoIdentiteSecureHttpsSoap11Endpoint();
		Test.stopTest();
		System.assertEquals(null, testObject.doRechercheSimple(null));
	}
	@isTest static void coverCodeForgetIdentiteAltaN4Entreprise(){
		Test.startTest();
		Test.setMock(WebServiceMock.class, new API_serviceCallistoAltaresMockImpl());
		API_serviceCallistoAltares.CallistoIdentiteSecureHttpsSoap11Endpoint testObject = new API_serviceCallistoAltares.CallistoIdentiteSecureHttpsSoap11Endpoint();
		Test.stopTest();
		System.assertEquals(null, testObject.getIdentiteAltaN4Entreprise(null));
	}
	@isTest static void coverCodeForgetIdentiteAltaN4Etablissement(){
		Test.startTest();
		Test.setMock(WebServiceMock.class, new API_serviceCallistoAltaresMockImpl());
		API_serviceCallistoAltares.CallistoIdentiteSecureHttpsSoap11Endpoint testObject = new API_serviceCallistoAltares.CallistoIdentiteSecureHttpsSoap11Endpoint();
		Test.stopTest();
		System.assertEquals(null, testObject.getIdentiteAltaN4Etablissement(null));
	}
	@isTest static void coverCodeForgetListeDecideurs(){
		Test.startTest();
		Test.setMock(WebServiceMock.class, new API_serviceCallistoAltaresMockImpl());
		API_serviceCallistoAltares.CallistoIdentiteSecureHttpsSoap11Endpoint testObject = new API_serviceCallistoAltares.CallistoIdentiteSecureHttpsSoap11Endpoint();
		Test.stopTest();
		System.assertEquals(null, testObject.getListeDecideurs(null));
	}
	@isTest static void coverCodeForgetListeDirigeantsStatutaires(){
		Test.startTest();
		Test.setMock(WebServiceMock.class, new API_serviceCallistoAltaresMockImpl());
		API_serviceCallistoAltares.CallistoIdentiteSecureHttpsSoap11Endpoint testObject = new API_serviceCallistoAltares.CallistoIdentiteSecureHttpsSoap11Endpoint();
		Test.stopTest();
		System.assertEquals(null, testObject.getListeDirigeantsStatutaires(null));
	}
	@isTest static void coverCodeForgetLiensCapitalistiques(){
		Test.startTest();
		Test.setMock(WebServiceMock.class, new API_serviceCallistoAltaresMockImpl());
		API_serviceCallistoAltares.CallistoIdentiteSecureHttpsSoap11Endpoint testObject = new API_serviceCallistoAltares.CallistoIdentiteSecureHttpsSoap11Endpoint();
		Test.stopTest();
		System.assertEquals(null, testObject.getLiensCapitalistiques(null));
	}
	@isTest static void coverCodeForgetScore(){
		Test.startTest();
		Test.setMock(WebServiceMock.class, new API_serviceCallistoAltaresMockImpl());
		API_serviceCallistoAltares.CallistoRisqueObjectHttpsSoap11Endpoint testObject = new API_serviceCallistoAltares.CallistoRisqueObjectHttpsSoap11Endpoint();
		Test.stopTest();
		System.assertEquals(null, testObject.getScore(null));
	}
	@isTest static void coverCodeForsetPortfolioItem(){
		Test.startTest();
		Test.setMock(WebServiceMock.class, new API_serviceCallistoAltaresMockImpl());
		API_serviceCallistoAltares.CallistoAlerteObjectHttpSoap11Endpoint testObject = new API_serviceCallistoAltares.CallistoAlerteObjectHttpSoap11Endpoint();
		Test.stopTest();
		System.assertEquals(null, testObject.setPortfolioItem(null));
	}
}