public with sharing class API_serviceCallistoAltares {
	
	public with sharing class CallistoAlerteObjectHttpSoap11Endpoint {
		public String endpoint_x = 'https://intuiz.altares.fr/iws-v3.18/services/CallistoAlerteObject.CallistoAlerteObjectHttpsSoap11Endpoint/';
		public Map<String,String> inputHttpHeaders_x;
		public Map<String,String> outputHttpHeaders_x;
		public String clientCertName_x;
		public String clientCert_x;
		public String clientCertPasswd_x;
		public Integer timeout_x;
		private String[] ns_map_type_info = new String[]{'http://response.callisto.newsys.altares.fr/xsd','API_responseCallistoAltares','http://alerte.request.callisto.newsys.altares.fr/xsd','API_alerteRequestCallistoAltares','http://alertes.vo.callisto.newsys.altares.fr/xsd','API_alertesVoCallistoAltares','http://alertes.response.callisto.newsys.altares.fr/xsd','API_alertesResponseCallistoAltares','http://serviceobject.service.callisto.newsys.altares.fr','API_serviceCallistoAltares','http://vo.callisto.newsys.altares.fr/xsd','API_voCallistoAltares'};

		public API_responseCallistoAltares.CallistoResponse setPortfolioItem(API_alerteRequestCallistoAltares.PortfolioSetExtendedRequest request) {
			API_serviceCallistoAltares.setPortfolioItem_element request_x = new API_serviceCallistoAltares.setPortfolioItem_element();
			API_serviceCallistoAltares.setPortfolioItemResponse_element response_x;
			request_x.request = request;
			Map<String, API_serviceCallistoAltares.setPortfolioItemResponse_element> response_map_x = new Map<String, API_serviceCallistoAltares.setPortfolioItemResponse_element>();
			response_map_x.put('response_x', response_x);
			WebServiceCallout.invoke(
				this,
				request_x,
				response_map_x,
				new String[]{endpoint_x,
				'urn:setPortfolioItem',
				'http://serviceobject.service.callisto.newsys.altares.fr',
				'setPortfolioItem',
				'http://serviceobject.service.callisto.newsys.altares.fr',
				'setPortfolioItemResponse',
				'API_serviceCallistoAltares.setPortfolioItemResponse_element'}
			);
			response_x = response_map_x.get('response_x');
			return response_x.return_x;
		}
	}

	public with sharing class CallistoRisqueObjectHttpsSoap11Endpoint {
		public String endpoint_x = 'https://intuiz.altares.fr/iws-v3.18/services/CallistoRisqueObject.CallistoRisqueObjectHttpsSoap11Endpoint/';
		public Map<String,String> inputHttpHeaders_x;
		public Map<String,String> outputHttpHeaders_x;
		public String clientCertName_x;
		public String clientCert_x;
		public String clientCertPasswd_x;
		public Integer timeout_x;
		private String[] ns_map_type_info = new String[]{'http://response.callisto.newsys.altares.fr/xsd','responseCallistoNewsysAltaresFrXsd','http://request.callisto.newsys.altares.fr/xsd','requestCallistoNewsysAltaresFrXsd','http://serviceobject.service.callisto.newsys.altares.fr','serviceobjectServiceCallistoNewsysA','http://risque.vo.callisto.newsys.altares.fr/xsd','risqueVoCallistoNewsysAltaresFrXsd','http://vo.callisto.newsys.altares.fr/xsd','voCallistoNewsysAltaresFrXsd'};

		public API_responseCallistoAltares.ScoreResponse getScore(API_requestCallistoAltares.SirenRequest request) {
			API_serviceCallistoAltares.getScore_element request_x = new API_serviceCallistoAltares.getScore_element();
			API_serviceCallistoAltares.getScoreResponse_element response_x;
			request_x.request = request;
			Map<String, API_serviceCallistoAltares.getScoreResponse_element> response_map_x = new Map<String, API_serviceCallistoAltares.getScoreResponse_element>();
			response_map_x.put('response_x', response_x);
			WebServiceCallout.invoke(
				this,
				request_x,
				response_map_x,
				new String[]{endpoint_x,
				'urn:getScore',
				'http://serviceobject.service.callisto.newsys.altares.fr',
				'getScore',
				'http://serviceobject.service.callisto.newsys.altares.fr',
				'getScoreResponse',
				'API_serviceCallistoAltares.getScoreResponse_element'}
			);
			response_x = response_map_x.get('response_x');
			return response_x.return_x;
		}
	}
		
	

	public with sharing class CallistoIdentiteSecureHttpsSoap11Endpoint {
		public String endpoint_x = 'https://intuiz.altares.fr/iws-v3.18/services/CallistoIdentiteObject.CallistoIdentiteObjectHttpsSoap11Endpoint/';
		public Map<String,String> inputHttpHeaders_x;
		public Map<String,String> outputHttpHeaders_x;
		public String clientCertName_x;
		public String clientCert_x;
		public String clientCertPasswd_x;
		public Integer timeout_x;
		private String[] ns_map_type_info = new String[]{'http://identite.response.callisto.newsys.altares.fr/xsd','API_identiteResponseCallistoAltares','http://annonce.vo.callisto.newsys.altares.fr/xsd','API_annonceVoCallistoAltares','http://serviceobject.service.callisto.newsys.altares.fr','API_serviceCallistoAltares','http://response.callisto.newsys.altares.fr/xsd','API_responseCallistoAltares','http://finance.vo.callisto.newsys.altares.fr/xsd','API_financeVoCallistoAltares','http://lien.vo.callisto.newsys.altares.fr/xsd','API_lienVoCallistoAltares','http://vo.callisto.newsys.altares.fr/xsd','API_voCallistoAltares','http://util.service.callisto.newsys.altares.fr/xsd','API_utilServiceCallistoAltares','http://pcl.vo.callisto.newsys.altares.fr/xsd','API_pclVoCallistoAltares'};

		public API_responseCallistoAltares.RechercheAssociationResponse doRechercheAssociation(API_requestCallistoAltares.RechercheAssociationRequest request) {
			API_serviceCallistoAltares.doRechercheAssociation_element request_x = new API_serviceCallistoAltares.doRechercheAssociation_element();
			API_serviceCallistoAltares.doRechercheAssociationResponse_element response_x;
			request_x.request = request;
			Map<String, API_serviceCallistoAltares.doRechercheAssociationResponse_element> response_map_x = new Map<String, API_serviceCallistoAltares.doRechercheAssociationResponse_element>();
			response_map_x.put('response_x', response_x);
			WebServiceCallout.invoke(
				this,
				request_x,
				response_map_x,
				new String[]{endpoint_x,
				'urn:doRechercheAssociation',
				'http://serviceobject.service.callisto.newsys.altares.fr',
				'doRechercheAssociation',
				'http://serviceobject.service.callisto.newsys.altares.fr',
				'doRechercheAssociationResponse',
				'API_serviceCallistoAltares.doRechercheAssociationResponse_element'}
			);
			response_x = response_map_x.get('response_x');
			return response_x.return_x;
		}

		public API_responseCallistoAltares.RechercheEntrepriseResponse doRechercheEntreprise(API_requestCallistoAltares.RechercheEntrepriseRequest request) {
			API_serviceCallistoAltares.doRechercheEntreprise_element request_x = new API_serviceCallistoAltares.doRechercheEntreprise_element();
			API_serviceCallistoAltares.doRechercheEntrepriseResponse_element response_x;
			request_x.request = request;
			Map<String, API_serviceCallistoAltares.doRechercheEntrepriseResponse_element> response_map_x = new Map<String, API_serviceCallistoAltares.doRechercheEntrepriseResponse_element>();
			response_map_x.put('response_x', response_x);
			WebServiceCallout.invoke(
				this,
				request_x,
				response_map_x,
				new String[]{endpoint_x,
				'urn:doRechercheEntreprise',
				'http://serviceobject.service.callisto.newsys.altares.fr',
				'doRechercheEntreprise',
				'http://serviceobject.service.callisto.newsys.altares.fr',
				'doRechercheEntrepriseResponse',
				'API_serviceCallistoAltares.doRechercheEntrepriseResponse_element'}
			);
			response_x = response_map_x.get('response_x');
			return response_x.return_x;
		}

		public API_responseCallistoAltares.RechercheSimpleResponse doRechercheSimple(API_requestCallistoAltares.RechercheSimpleRequest request) {
			API_serviceCallistoAltares.doRechercheSimple_element request_x = new API_serviceCallistoAltares.doRechercheSimple_element();
			API_serviceCallistoAltares.doRechercheSimpleResponse_element response_x;
			request_x.request = request;
			Map<String, API_serviceCallistoAltares.doRechercheSimpleResponse_element> response_map_x = new Map<String, API_serviceCallistoAltares.doRechercheSimpleResponse_element>();
			response_map_x.put('response_x', response_x);
			WebServiceCallout.invoke(
				this,
				request_x,
				response_map_x,
				new String[]{endpoint_x,
				'urn:doRechercheSimple',
				'http://serviceobject.service.callisto.newsys.altares.fr',
				'doRechercheSimple',
				'http://serviceobject.service.callisto.newsys.altares.fr',
				'doRechercheSimpleResponse',
				'API_serviceCallistoAltares.doRechercheSimpleResponse_element'}
			);
			response_x = response_map_x.get('response_x');
			return response_x.return_x;
		}

		public API_identiteResponseCallistoAltares.IdentiteAltaN4EnResponse getIdentiteAltaN4Entreprise(API_requestCallistoAltares.SirenRnaRequest request) {
			API_serviceCallistoAltares.getIdentiteAltaN4Entreprise_element request_x = new API_serviceCallistoAltares.getIdentiteAltaN4Entreprise_element();
			API_serviceCallistoAltares.getIdentiteAltaN4EntrepriseResponse_element response_x;
			request_x.request = request;
			Map<String, API_serviceCallistoAltares.getIdentiteAltaN4EntrepriseResponse_element> response_map_x = new Map<String, API_serviceCallistoAltares.getIdentiteAltaN4EntrepriseResponse_element>();
			response_map_x.put('response_x', response_x);
			WebServiceCallout.invoke(
				this,
				request_x,
				response_map_x,
				new String[]{endpoint_x,
				'urn:getIdentiteAltaN4Entreprise',
				'http://serviceobject.service.callisto.newsys.altares.fr',
				'getIdentiteAltaN4Entreprise',
				'http://serviceobject.service.callisto.newsys.altares.fr',
				'getIdentiteAltaN4EntrepriseResponse',
				'API_serviceCallistoAltares.getIdentiteAltaN4EntrepriseResponse_element'}
			);
			response_x = response_map_x.get('response_x');
			return response_x.return_x;
		}

		public API_identiteResponseCallistoAltares.IdentiteAltaN4EtResponse getIdentiteAltaN4Etablissement(API_requestCallistoAltares.SirenSiretRequest request) {
			API_serviceCallistoAltares.getIdentiteAltaN4Etablissement_element request_x = new API_serviceCallistoAltares.getIdentiteAltaN4Etablissement_element();
			API_serviceCallistoAltares.getIdentiteAltaN4EtablissementResponse_element response_x;
			request_x.request = request;
			Map<String, API_serviceCallistoAltares.getIdentiteAltaN4EtablissementResponse_element> response_map_x = new Map<String, API_serviceCallistoAltares.getIdentiteAltaN4EtablissementResponse_element>();
			response_map_x.put('response_x', response_x);
			WebServiceCallout.invoke(
				this,
				request_x,
				response_map_x,
				new String[]{endpoint_x,
				'urn:getIdentiteAltaN4Etablissement',
				'http://serviceobject.service.callisto.newsys.altares.fr',
				'getIdentiteAltaN4Etablissement',
				'http://serviceobject.service.callisto.newsys.altares.fr',
				'getIdentiteAltaN4EtablissementResponse',
				'API_serviceCallistoAltares.getIdentiteAltaN4EtablissementResponse_element'}
			);
			response_x = response_map_x.get('response_x');
			return response_x.return_x;
		}

		public API_responseCallistoAltares.ListeDecideursResponse getListeDecideurs(API_requestCallistoAltares.SirenRequest request) {
			API_serviceCallistoAltares.getListeDecideurs_element request_x = new API_serviceCallistoAltares.getListeDecideurs_element();
			API_serviceCallistoAltares.getListeDecideursResponse_element response_x;
			request_x.request = request;
			Map<String, API_serviceCallistoAltares.getListeDecideursResponse_element> response_map_x = new Map<String, API_serviceCallistoAltares.getListeDecideursResponse_element>();
			response_map_x.put('response_x', response_x);
			WebServiceCallout.invoke(
				this,
				request_x,
				response_map_x,
				new String[]{endpoint_x,
				'urn:getListeDecideurs',
				'http://serviceobject.service.callisto.newsys.altares.fr',
				'getListeDecideurs',
				'http://serviceobject.service.callisto.newsys.altares.fr',
				'getListeDecideursResponse',
				'API_serviceCallistoAltares.getListeDecideursResponse_element'}
			);
			response_x = response_map_x.get('response_x');
			return response_x.return_x;
		}

		public API_responseCallistoAltares.ListeDirigeantsStatutairesResponse getListeDirigeantsStatutaires(API_requestCallistoAltares.ListeDirigeantRequest request) {
			API_serviceCallistoAltares.getListeDirigeantsStatutaires_element request_x = new API_serviceCallistoAltares.getListeDirigeantsStatutaires_element();
			API_serviceCallistoAltares.getListeDirigeantsStatutairesResponse_element response_x;
			request_x.request = request;
			Map<String, API_serviceCallistoAltares.getListeDirigeantsStatutairesResponse_element> response_map_x = new Map<String, API_serviceCallistoAltares.getListeDirigeantsStatutairesResponse_element>();
			response_map_x.put('response_x', response_x);
			WebServiceCallout.invoke(
				this,
				request_x,
				response_map_x,
				new String[]{endpoint_x,
				'urn:getListeDirigeantsStatutaires',
				'http://serviceobject.service.callisto.newsys.altares.fr',
				'getListeDirigeantsStatutaires',
				'http://serviceobject.service.callisto.newsys.altares.fr',
				'getListeDirigeantsStatutairesResponse',
				'API_serviceCallistoAltares.getListeDirigeantsStatutairesResponse_element'}
			);
			response_x = response_map_x.get('response_x');
			return response_x.return_x;
		}

		public API_responseCallistoAltares.LiensCapitalistiquesResponse getLiensCapitalistiques(API_requestCallistoAltares.SirenRequest request) {
			API_serviceCallistoAltares.getLiensCapitalistiques_element request_x = new API_serviceCallistoAltares.getLiensCapitalistiques_element();
			API_serviceCallistoAltares.getLiensCapitalistiquesResponse_element response_x;
			request_x.request = request;
			Map<String, API_serviceCallistoAltares.getLiensCapitalistiquesResponse_element> response_map_x = new Map<String, API_serviceCallistoAltares.getLiensCapitalistiquesResponse_element>();
			response_map_x.put('response_x', response_x);
			WebServiceCallout.invoke(
				this,
				request_x,
				response_map_x,
				new String[]{endpoint_x,
				'urn:getLiensCapitalistiques',
				'http://serviceobject.service.callisto.newsys.altares.fr',
				'getLiensCapitalistiques',
				'http://serviceobject.service.callisto.newsys.altares.fr',
				'getLiensCapitalistiquesResponse',
				'API_serviceCallistoAltares.getLiensCapitalistiquesResponse_element'}
			);
			response_x = response_map_x.get('response_x');
			return response_x.return_x;
		}
	}
	public with sharing class doRechercheAssociation_element {
		public API_requestCallistoAltares.RechercheAssociationRequest request;
		private String[] request_type_info = new String[]{'request','http://serviceobject.service.callisto.newsys.altares.fr','RechercheAssociationRequest','0','1','true'};
		private String[] apex_schema_type_info = new String[]{'http://serviceobject.service.callisto.newsys.altares.fr','true','false'};
		private String[] field_order_type_info = new String[]{'request'};
	}
	public with sharing class doRechercheAssociationResponse_element {
		public API_responseCallistoAltares.RechercheAssociationResponse return_x;
		private String[] return_x_type_info = new String[]{'return','http://serviceobject.service.callisto.newsys.altares.fr','RechercheAssociationResponse','0','1','true'};
		private String[] apex_schema_type_info = new String[]{'http://serviceobject.service.callisto.newsys.altares.fr','true','false'};
		private String[] field_order_type_info = new String[]{'return_x'};
	}
	public with sharing class doRechercheEntreprise_element {
		public API_requestCallistoAltares.RechercheEntrepriseRequest request;
		private String[] request_type_info = new String[]{'request','http://serviceobject.service.callisto.newsys.altares.fr','RechercheEntrepriseRequest','0','1','true'};
		private String[] apex_schema_type_info = new String[]{'http://serviceobject.service.callisto.newsys.altares.fr','true','false'};
		private String[] field_order_type_info = new String[]{'request'};
	}
	public with sharing class doRechercheEntrepriseResponse_element {
		public API_responseCallistoAltares.RechercheEntrepriseResponse return_x;
		private String[] return_x_type_info = new String[]{'return','http://serviceobject.service.callisto.newsys.altares.fr','RechercheEntrepriseResponse','0','1','true'};
		private String[] apex_schema_type_info = new String[]{'http://serviceobject.service.callisto.newsys.altares.fr','true','false'};
		private String[] field_order_type_info = new String[]{'return_x'};
	}
	public with sharing class doRechercheSimple_element {
		public API_requestCallistoAltares.RechercheSimpleRequest request;
		private String[] request_type_info = new String[]{'request','http://serviceobject.service.callisto.newsys.altares.fr','RechercheSimpleRequest','0','1','true'};
		private String[] apex_schema_type_info = new String[]{'http://serviceobject.service.callisto.newsys.altares.fr','true','false'};
		private String[] field_order_type_info = new String[]{'request'};
	}
	public with sharing class doRechercheSimpleResponse_element {
		public API_responseCallistoAltares.RechercheSimpleResponse return_x;
		private String[] return_x_type_info = new String[]{'return','http://serviceobject.service.callisto.newsys.altares.fr','RechercheSimpleResponse','0','1','true'};
		private String[] apex_schema_type_info = new String[]{'http://serviceobject.service.callisto.newsys.altares.fr','true','false'};
		private String[] field_order_type_info = new String[]{'return_x'};
	}

	public with sharing class getIdentiteAltaN4Entreprise_element {
		public API_requestCallistoAltares.SirenRnaRequest request;
		private String[] request_type_info = new String[]{'request','http://serviceobject.service.callisto.newsys.altares.fr','SirenRnaRequest','0','1','true'};
		private String[] apex_schema_type_info = new String[]{'http://serviceobject.service.callisto.newsys.altares.fr','true','false'};
		private String[] field_order_type_info = new String[]{'request'};
	}
	public with sharing class getIdentiteAltaN4EntrepriseResponse_element {
		public API_identiteResponseCallistoAltares.IdentiteAltaN4EnResponse return_x;
		private String[] return_x_type_info = new String[]{'return','http://serviceobject.service.callisto.newsys.altares.fr','IdentiteAltaN4EnResponse','0','1','true'};
		private String[] apex_schema_type_info = new String[]{'http://serviceobject.service.callisto.newsys.altares.fr','true','false'};
		private String[] field_order_type_info = new String[]{'return_x'};
	}
	public with sharing class getIdentiteAltaN4Etablissement_element {
		public API_requestCallistoAltares.SirenSiretRequest request;
		private String[] request_type_info = new String[]{'request','http://serviceobject.service.callisto.newsys.altares.fr','SirenSiretRequest','0','1','true'};
		private String[] apex_schema_type_info = new String[]{'http://serviceobject.service.callisto.newsys.altares.fr','true','false'};
		private String[] field_order_type_info = new String[]{'request'};
	}
	public with sharing class getIdentiteAltaN4EtablissementResponse_element {
		public API_identiteResponseCallistoAltares.IdentiteAltaN4EtResponse return_x;
		private String[] return_x_type_info = new String[]{'return','http://serviceobject.service.callisto.newsys.altares.fr','IdentiteAltaN4EtResponse','0','1','true'};
		private String[] apex_schema_type_info = new String[]{'http://serviceobject.service.callisto.newsys.altares.fr','true','false'};
		private String[] field_order_type_info = new String[]{'return_x'};
	}
	public with sharing class getListeDecideurs_element {
		public API_requestCallistoAltares.SirenRequest request;
		private String[] request_type_info = new String[]{'request','http://serviceobject.service.callisto.newsys.altares.fr','SirenRequest','0','1','true'};
		private String[] apex_schema_type_info = new String[]{'http://serviceobject.service.callisto.newsys.altares.fr','true','false'};
		private String[] field_order_type_info = new String[]{'request'};
	}
	public with sharing class getListeDecideursResponse_element {
		public API_responseCallistoAltares.ListeDecideursResponse return_x;
		private String[] return_x_type_info = new String[]{'return','http://serviceobject.service.callisto.newsys.altares.fr','ListeDecideursResponse','0','1','true'};
		private String[] apex_schema_type_info = new String[]{'http://serviceobject.service.callisto.newsys.altares.fr','true','false'};
		private String[] field_order_type_info = new String[]{'return_x'};
	}
	public with sharing class getListeDirigeantsStatutaires_element {
		public API_requestCallistoAltares.ListeDirigeantRequest request;
		private String[] request_type_info = new String[]{'request','http://serviceobject.service.callisto.newsys.altares.fr','ListeDirigeantRequest','0','1','true'};
		private String[] apex_schema_type_info = new String[]{'http://serviceobject.service.callisto.newsys.altares.fr','true','false'};
		private String[] field_order_type_info = new String[]{'request'};
	}
	public with sharing class getListeDirigeantsStatutairesResponse_element {
		public API_responseCallistoAltares.ListeDirigeantsStatutairesResponse return_x;
		private String[] return_x_type_info = new String[]{'return','http://serviceobject.service.callisto.newsys.altares.fr','ListeDirigeantsStatutairesResponse','0','1','true'};
		private String[] apex_schema_type_info = new String[]{'http://serviceobject.service.callisto.newsys.altares.fr','true','false'};
		private String[] field_order_type_info = new String[]{'return_x'};
	}

	public with sharing class getScore_element {
		public API_requestCallistoAltares.SirenRequest request;
		private String[] request_type_info = new String[]{'request','http://serviceobject.service.callisto.newsys.altares.fr','SirenRequest','0','1','true'};
		private String[] apex_schema_type_info = new String[]{'http://serviceobject.service.callisto.newsys.altares.fr','true','false'};
		private String[] field_order_type_info = new String[]{'request'};
	}
	public with sharing class getScoreResponse_element {
		public API_responseCallistoAltares.ScoreResponse return_x;
		private String[] return_x_type_info = new String[]{'return','http://serviceobject.service.callisto.newsys.altares.fr','ScoreResponse','0','1','true'};
		private String[] apex_schema_type_info = new String[]{'http://serviceobject.service.callisto.newsys.altares.fr','true','false'};
		private String[] field_order_type_info = new String[]{'return_x'};
	}

	public with sharing class getLiensCapitalistiques_element {
		public API_requestCallistoAltares.SirenRequest request;
		private String[] request_type_info = new String[]{'request','http://serviceobject.service.callisto.newsys.altares.fr','SirenRequest','0','1','true'};
		private String[] apex_schema_type_info = new String[]{'http://serviceobject.service.callisto.newsys.altares.fr','true','false'};
		private String[] field_order_type_info = new String[]{'request'};
	}
	public with sharing class getLiensCapitalistiquesResponse_element {
		public API_responseCallistoAltares.LiensCapitalistiquesResponse return_x;
		private String[] return_x_type_info = new String[]{'return','http://serviceobject.service.callisto.newsys.altares.fr','LiensCapitalistiquesResponse','0','1','true'};
		private String[] apex_schema_type_info = new String[]{'http://serviceobject.service.callisto.newsys.altares.fr','true','false'};
		private String[] field_order_type_info = new String[]{'return_x'};
	}
	public with sharing class setPortfolioItem_element {
		public API_alerteRequestCallistoAltares.PortfolioSetExtendedRequest request;
		private String[] request_type_info = new String[]{'request','http://serviceobject.service.callisto.newsys.altares.fr','PortfolioSetExtendedRequest','0','1','true'};
		private String[] apex_schema_type_info = new String[]{'http://serviceobject.service.callisto.newsys.altares.fr','true','false'};
		private String[] field_order_type_info = new String[]{'request'};
	}
	public with sharing class setPortfolioItemResponse_element {
		public API_responseCallistoAltares.CallistoResponse return_x;
		private String[] return_x_type_info = new String[]{'return','http://serviceobject.service.callisto.newsys.altares.fr','CallistoResponse','0','1','true'};
		private String[] apex_schema_type_info = new String[]{'http://serviceobject.service.callisto.newsys.altares.fr','true','false'};
		private String[] field_order_type_info = new String[]{'return_x'};
	}	
}