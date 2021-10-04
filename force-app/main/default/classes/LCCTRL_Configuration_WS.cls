global with sharing class LCCTRL_Configuration_WS {
	
	@AuraEnabled
	global static Map<String,String> getConfiguration() {

		if (!Util_CrudFLS.isAccessible('Altares_Configuration__c', new List<String>{
				'Login__c', 
				'Mot_de_passe__c',
				'Reference_client__c'
		})){
			throw new AuraHandledException(Label.Erreur_Permissions_insuffisante);
		}

		Map<String,String> mapConfig = new Map<String,String>();
		
		Altares_Configuration__c config = Altares_Configuration__c.getOrgDefaults();

		mapConfig.put('login',config.Login__c);
		mapConfig.put('refClient',config.Reference_client__c);
		mapConfig.put('password',String.isBlank(config.Mot_de_passe__c)?null:'******************');

		return mapConfig;
	}

	@AuraEnabled
	global static void setConfiguration(String refClient, String login, String password ) {
		
		if (!Util_CrudFLS.isUpsertable('Altares_Configuration__c', new List<String>{
                'Login__c', 
				'Mot_de_passe__c',
				'Reference_client__c'
		})){
			throw new AuraHandledException(Label.Erreur_Permissions_insuffisante);
		}

		Altares_Configuration__c config = Altares_Configuration__c.getOrgDefaults();
		
		config.Reference_client__c = refClient;
		config.Login__c = login;
		config.Mot_de_passe__c = password;

		try {
			upsert config;
		} catch (Exception e) {
			System.debug(e.getMessage());
			throw new AuraHandledException(e.getMessage());
		}
	}
}