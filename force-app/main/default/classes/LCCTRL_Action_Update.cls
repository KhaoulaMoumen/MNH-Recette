public with sharing class LCCTRL_Action_Update {
	
	@AuraEnabled
	public static Boolean updateRecord(String sObjectName , Id recordId){

		List<String> correctSobjectName = new List<String>{'Account', 'Lead'};

		if(!correctSobjectName.contains(sObjectName)){
			throw new AuraHandledException(Label.Erreur_action_non_autorisee);
		}

		List<String> fields = new List<String>{
				'Id',
				'sirenSiret__c'
		};

		if (!Util_CrudFLS.isAccessible(sObjectName,fields)){
			throw new AuraHandledException(Label.Erreur_Permissions_insuffisante);
		}


		sObject[] records = Database.query('SELECT sirenSiret__c FROM '+sObjectName+' WHERE id = :recordId');
		if(records.isEmpty()){
			throw new AuraHandledException(Label.Erreur_Enregistrement_non_trouve);
		}

		String siret = (String) records[0].get('sirenSiret__c');

		if(String.isBlank(siret)){
			throw new AuraHandledException(Label.Erreur_Siret_vide);
		}

		Util_IntuizSDK intuiz = new Util_IntuizSDK();

		intuiz.upsertRecord(sObjectName,siret,recordId);


		return true;
	}

}