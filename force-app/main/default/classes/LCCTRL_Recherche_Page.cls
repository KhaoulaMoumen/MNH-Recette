global with sharing class LCCTRL_Recherche_Page {
	
	@AuraEnabled
	public static Map<String,Object> searchSimple(String qui  , String ou) {

		Map<String,Object> result = new Map<String,Object>();

		Util_IntuizSDK intuiz = new Util_IntuizSDK();

		API_responseCallistoAltares.RechercheSimpleResponse response =  intuiz.doRechercheSimple(qui,ou);

		result.put('nbMatch',response.nbMatch);
		result.put('nbResult',response.nbElt);
		result.put('results', (response.nbMatch == 0) ? (Object) new List<String>() : (Object) response.myInfo);

		return result;
	}

	@AuraEnabled
	public static Map<String,Object> searchEtablissement(Integer typeRecherche, String raisonSociale, String enseigne, String sirent, String rcs, String rue, String codePostal, String ville) {
		Map<String,Object> result = new Map<String,Object>();
		
		if(sirent == null)
			sirent = '';

		if(rcs == null)
			rcs = '';

		sirent = sirent.replaceAll( '[^0-9]', '');
		rcs = rcs.replaceAll( '\\s+', '');

		String siren = sirent.length() == 9 ? sirent : '' ;
		String siret = sirent.length() == 14 ? sirent : '' ;

		System.System.debug(siren);
		System.System.debug(siret);

		Util_IntuizSDK intuiz = new Util_IntuizSDK();

		API_responseCallistoAltares.RechercheEntrepriseResponse response =  intuiz.doRechercheEntreprise(typeRecherche, raisonSociale, siren, siret,  enseigne,  rcs, rue,  ville,  codePostal );

		result.put('nbMatch',response.nbMatch);
		result.put('nbResult',response.nbElt);
		result.put('results', (response.nbMatch == 0) ? (Object) new List<String>() : (Object) response.myInfo);
		
		return result;
	}

	@AuraEnabled
	public static Map<String,Object> searchAssociation(String titre, String rna, String departement) {

		Map<String,Object> result = new Map<String,Object>();
		Util_IntuizSDK intuiz = new Util_IntuizSDK();
		API_responseCallistoAltares.RechercheAssociationResponse response =  intuiz.doRechercheAssociation(titre, rna, departement);
		System.debug(response.myInfo);
		result.put('nbMatch',response.nbMatch);
		result.put('nbResult',response.nbElt);
		result.put('results', (response.nbMatch == 0) ? (Object) new List<String>() : (Object) response.myInfo);
		
		return result;
	}

	@AuraEnabled
	public static List<sObject> findDoublon(String sObjectName, String siret){

		List<String> correctSobjectName = new List<String>{'Account', 'Lead'};

		if(!correctSobjectName.contains(sObjectName)){
			throw new AuraHandledException(Label.Erreur_action_non_autorisee);
		}

		List<String> fields = new List<String>{
				'Id',
				'SIRET__c', 
				'Raison_sociale__c',
				'Siege__c',
				'Etablissement_actif__c',
				'Adresse__c',
				'Code_postal__c',
				'Ville__c'
		};

		if (!Util_CrudFLS.isAccessible(sObjectName,fields)){
			throw new AuraHandledException(Label.Erreur_Permissions_insuffisante);
		}

		System.debug('siret: ' + siret);

		return Database.query('SELECT ' +String.join(fields,' , ')+' FROM '+sObjectName+' WHERE SIRET__c = :siret');

	}

	@AuraEnabled
	public static Id createRecord(String sObjectName, String siret){

		List<String> correctSobjectName = new List<String>{'Account', 'Lead'};

		if(!correctSobjectName.contains(sObjectName)){
			throw new AuraHandledException(Label.Erreur_action_non_autorisee);
		}

		Util_IntuizSDK intuiz = new Util_IntuizSDK();

		Id recordId = intuiz.upsertRecord(sObjectName, siret, null);

		return recordId;

	}
}