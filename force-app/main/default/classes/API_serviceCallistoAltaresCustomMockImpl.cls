@isTest
global with sharing class API_serviceCallistoAltaresCustomMockImpl implements WebServiceMock {

	private Object customResponse;

	global API_serviceCallistoAltaresCustomMockImpl(Object response){
        this.customResponse = response;
    }

	global void doInvoke(
			Object stub,
			Object request,
			Map<String, Object> response,
			String endpoint,
			String soapAction,
			String requestName,
			String responseNS,
			String responseName,
			String responseType) {
       

		if(request instanceOf API_serviceCallistoAltares.doRechercheAssociation_element) {
			API_serviceCallistoAltares.doRechercheAssociationResponse_element customResponseElement = new API_serviceCallistoAltares.doRechercheAssociationResponse_element();
			if(customResponse != null)
				customResponseElement.return_x = (API_responseCallistoAltares.RechercheAssociationResponse)  customResponse;
			else{
				API_responseCallistoAltares.RechercheAssociationResponse defaultResponse = new API_responseCallistoAltares.RechercheAssociationResponse();
				defaultResponse.correct = true;
				//todo
				customResponseElement.return_x = defaultResponse;
			}
			response.put( 'response_x',customResponseElement);
		}
		else if(request instanceOf API_serviceCallistoAltares.doRechercheEntreprise_element) {
			API_serviceCallistoAltares.doRechercheEntrepriseResponse_element customResponseElement = new API_serviceCallistoAltares.doRechercheEntrepriseResponse_element();
			if(customResponse != null)
				customResponseElement.return_x = (API_responseCallistoAltares.RechercheEntrepriseResponse)  customResponse;
			else{
				API_responseCallistoAltares.RechercheEntrepriseResponse defaultResponse = new API_responseCallistoAltares.RechercheEntrepriseResponse();
				defaultResponse.correct = true;
				//todo
				customResponseElement.return_x = defaultResponse;
			}
			response.put( 'response_x',customResponseElement);
		}
		else if(request instanceOf API_serviceCallistoAltares.doRechercheSimple_element) {
			API_serviceCallistoAltares.doRechercheSimpleResponse_element customResponseElement = new API_serviceCallistoAltares.doRechercheSimpleResponse_element();
			if(customResponse != null)
				customResponseElement.return_x = (API_responseCallistoAltares.RechercheSimpleResponse)  customResponse;
			else{
				API_responseCallistoAltares.RechercheSimpleResponse defaultResponse = new API_responseCallistoAltares.RechercheSimpleResponse();
				defaultResponse.correct = true;
				//todo
				customResponseElement.return_x = defaultResponse;
			}
			response.put( 'response_x',customResponseElement);
		}
		else if(request instanceOf API_serviceCallistoAltares.getScore_element) {
			API_serviceCallistoAltares.getScoreResponse_element customResponseElement = new API_serviceCallistoAltares.getScoreResponse_element();
			if(customResponse != null)
				customResponseElement.return_x = (API_responseCallistoAltares.ScoreResponse)  customResponse;
			else{
				API_responseCallistoAltares.ScoreResponse defaultResponse = new API_responseCallistoAltares.ScoreResponse();
				defaultResponse.correct = true;
				//todo
				customResponseElement.return_x = defaultResponse;
			}
			response.put( 'response_x',customResponseElement);
		}
		else if(request instanceOf API_serviceCallistoAltares.getIdentiteAltaN4Entreprise_element) {
			API_serviceCallistoAltares.getIdentiteAltaN4EntrepriseResponse_element customResponseElement = new API_serviceCallistoAltares.getIdentiteAltaN4EntrepriseResponse_element();
			if(customResponse != null)
				customResponseElement.return_x = (API_identiteResponseCallistoAltares.IdentiteAltaN4EnResponse)  customResponse;
			else{
				API_identiteResponseCallistoAltares.IdentiteAltaN4EnResponse defaultResponse = new API_identiteResponseCallistoAltares.IdentiteAltaN4EnResponse();
				defaultResponse.correct = true;
				//todo
				defaultResponse.myInfo =  new API_voCallistoAltares.IdentiteAltaN4EntrepriseInfo();
				defaultResponse.myInfo.raisonSociale = 'CompanyName';
				defaultResponse.myInfo.codePostal = '00000';
                defaultResponse.myInfo.siret = '44059015600053';

				customResponseElement.return_x = defaultResponse;
			}
			response.put( 'response_x',customResponseElement);
		}
		else if(request instanceOf API_serviceCallistoAltares.getIdentiteAltaN4Etablissement_element) {
			API_serviceCallistoAltares.getIdentiteAltaN4EtablissementResponse_element customResponseElement = new API_serviceCallistoAltares.getIdentiteAltaN4EtablissementResponse_element();
			if(customResponse != null)
				customResponseElement.return_x = (API_identiteResponseCallistoAltares.IdentiteAltaN4EtResponse)  customResponse;
			else{
				API_identiteResponseCallistoAltares.IdentiteAltaN4EtResponse defaultResponse = new API_identiteResponseCallistoAltares.IdentiteAltaN4EtResponse();
				defaultResponse.correct = true;
				defaultResponse.myInfo =  new API_voCallistoAltares.IdentiteAltaN4EtablissementInfo();
				defaultResponse.myInfo.raisonSociale = 'CompanyName';
				defaultResponse.myInfo.siege = true;
				defaultResponse.myInfo.actif = true;
				defaultResponse.myInfo.codePostal = '00000';
                defaultResponse.myInfo.siret = '44059015600053';
				//todo
				customResponseElement.return_x = defaultResponse;
			}
			response.put( 'response_x',customResponseElement);
		}
		
		else if(request instanceOf API_serviceCallistoAltares.getListeDecideurs_element) {
			API_serviceCallistoAltares.getListeDecideursResponse_element customResponseElement = new API_serviceCallistoAltares.getListeDecideursResponse_element();
			if(customResponse != null)
				customResponseElement.return_x = (API_responseCallistoAltares.ListeDecideursResponse)  customResponse;
			else{
				API_responseCallistoAltares.ListeDecideursResponse defaultResponse = new API_responseCallistoAltares.ListeDecideursResponse();

				List<API_voCallistoAltares.DecideurInfo> infos = new List<API_voCallistoAltares.DecideurInfo>();
				API_voCallistoAltares.DecideurInfo info = new API_voCallistoAltares.DecideurInfo();

				info.civilite='MR';
				info.nom='TEST';
				info.prenom='TEST';
				info.fonctionCode='1234';
				info.fonction='DIRECTEUR';
				infos.add(info);

				

				defaultResponse.myInfo = infos;
		
			defaultResponse.correct = true;


				//todo
				customResponseElement.return_x = defaultResponse;
			}
			response.put( 'response_x',customResponseElement);
		}
		else if(request instanceOf API_serviceCallistoAltares.getListeDecideurs_element) {
			API_serviceCallistoAltares.getLiensCapitalistiquesResponse_element customResponseElement = new API_serviceCallistoAltares.getLiensCapitalistiquesResponse_element();
			if(customResponse != null)
				customResponseElement.return_x = (API_responseCallistoAltares.LiensCapitalistiquesResponse)  customResponse;
			else{
				API_responseCallistoAltares.LiensCapitalistiquesResponse defaultResponse = new API_responseCallistoAltares.LiensCapitalistiquesResponse();
				defaultResponse.correct = true;
				//todo
				defaultResponse.myInfo=  new API_voCallistoAltares.LiensCapitalistiquesInfo();

				defaultResponse.myInfo.raisonSocialeTeteGroupe25 = 'CompanyName';
				defaultResponse.myInfo.sirenTeteGroupe25 = '440590156';

				customResponseElement.return_x = defaultResponse;
			}
			response.put( 'response_x',customResponseElement);
		}
		else if(request instanceOf API_serviceCallistoAltares.getListeDirigeantsStatutaires_element) {
			API_serviceCallistoAltares.getListeDirigeantsStatutairesResponse_element customResponseElement = new API_serviceCallistoAltares.getListeDirigeantsStatutairesResponse_element();
			if(customResponse != null)
				customResponseElement.return_x = (API_responseCallistoAltares.ListeDirigeantsStatutairesResponse)  customResponse;
			else{
				API_responseCallistoAltares.ListeDirigeantsStatutairesResponse defaultResponse = new API_responseCallistoAltares.ListeDirigeantsStatutairesResponse();
				defaultResponse.correct = true;
				//todo
				customResponseElement.return_x = defaultResponse;
			}
			response.put( 'response_x',customResponseElement);
		}
		else if(request instanceOf API_serviceCallistoAltares.getLiensCapitalistiques_element) {
			
			API_serviceCallistoAltares.getLiensCapitalistiquesResponse_element customResponseElement = new API_serviceCallistoAltares.getLiensCapitalistiquesResponse_element();
			if(customResponse != null)
				customResponseElement.return_x = (API_responseCallistoAltares.LiensCapitalistiquesResponse)  customResponse;
			else{
				API_responseCallistoAltares.LiensCapitalistiquesResponse defaultResponse = new API_responseCallistoAltares.LiensCapitalistiquesResponse();
				defaultResponse.correct = true;

				defaultResponse.myInfo=  new API_voCallistoAltares.LiensCapitalistiquesInfo();

				defaultResponse.myInfo.raisonSocialeTeteGroupe25 = 'CompanyName';
				defaultResponse.myInfo.sirenTeteGroupe25 = '440590156';

				//todo
				customResponseElement.return_x = defaultResponse;
			}
			response.put( 'response_x',customResponseElement);
		}
		else if(request instanceOf API_serviceCallistoAltares.setPortfolioItem_element) {
			API_serviceCallistoAltares.setPortfolioItemResponse_element customResponseElement = new API_serviceCallistoAltares.setPortfolioItemResponse_element();
			if(customResponse != null)
				customResponseElement.return_x = (API_responseCallistoAltares.CallistoResponse)  customResponse;
			else{
				API_responseCallistoAltares.CallistoResponse defaultResponse = new API_responseCallistoAltares.CallistoResponse();
				defaultResponse.correct = true;
				//todo
				customResponseElement.return_x = defaultResponse;
			}
			response.put( 'response_x',customResponseElement);
		}


	}
}