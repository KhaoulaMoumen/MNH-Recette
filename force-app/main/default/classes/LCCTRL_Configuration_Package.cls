global with sharing class LCCTRL_Configuration_Package {
	@AuraEnabled
	global static Map<String,Object> getPackageConf() {

		if (!Util_CrudFLS.isAccessible('Altares_Configuration__c', new List<String>{
				'Nombre_de_resultat__c'
		})){
			throw new AuraHandledException(Label.Erreur_Permissions_insuffisante);
		}

		Map<String,Object> mapConfig = new Map<String,Object>();
		
		Altares_Configuration__c config = Altares_Configuration__c.getOrgDefaults();

		mapConfig.put('nbResult', config.Nombre_de_resultat__c);

		List<Altares_Fields_Synchro__mdt> synchro = [SELECT MasterLabel, DeveloperName, Creation__c, Mise_a_jour__c , Required__c FROM Altares_Fields_Synchro__mdt Order By MasterLabel LIMIT 100
		
		];
		mapConfig.put('synchro',MD_Syncro_Configuration.getFromList(synchro));

		List<Altares_Field_Synchro_Dirigeant__mdt> synchro_dirigeant = [SELECT MasterLabel, DeveloperName, Creation__c, Mise_a_jour__c , Required__c FROM Altares_Field_Synchro_Dirigeant__mdt LIMIT 100
		
		];
		mapConfig.put('synchro_dirigeant', MD_Syncro_Configuration.getFromList(synchro_dirigeant));

		List<Altares_Field_Synchro_Actionnaire__mdt> synchro_actionaire = [SELECT MasterLabel, DeveloperName, Creation__c, Mise_a_jour__c , Required__c FROM Altares_Field_Synchro_Actionnaire__mdt LIMIT 100
		
		];
		mapConfig.put('synchro_actionaire', MD_Syncro_Configuration.getFromList(synchro_actionaire));

		List<Altares_Field_Synchro_Participation__mdt> synchro_participation = [SELECT MasterLabel, DeveloperName, Creation__c, Mise_a_jour__c , Required__c FROM Altares_Field_Synchro_Participation__mdt LIMIT 100
		
		];
		mapConfig.put('synchro_participation', MD_Syncro_Configuration.getFromList(synchro_participation));

		return mapConfig;
	}

	
	@AuraEnabled
	global static void setPackageConf(Decimal nbResult,String synchroJSON, String synchro_dirigeantJSON, String synchro_actionaireJSON, String synchro_participationJSON) {

		if (!Util_CrudFLS.isUpsertable('Altares_Configuration__c', new List<String>{
                'Nombre_de_resultat__c'
		})){
			throw new AuraHandledException(Label.Erreur_Permissions_insuffisante);
		}
		setNbResult(nbResult);
		System.debug(nbResult);


		Map<String,Map<String,Map<String,Object>>> datas = new Map<String,Map<String,Map<String,Object>>>();

		Map<String,Map<String,Object>> datas_syncro = new Map<String,Map<String,Object>>();

		List<MD_Syncro_Configuration> synchro = (List<MD_Syncro_Configuration>) JSON.deserialize(synchroJSON,List<MD_Syncro_Configuration>.class);
		List<MD_Syncro_Configuration> synchro_dirigeant = (List<MD_Syncro_Configuration>) JSON.deserialize(synchro_dirigeantJSON,List<MD_Syncro_Configuration>.class);
		List<MD_Syncro_Configuration> synchro_actionaire = (List<MD_Syncro_Configuration>) JSON.deserialize(synchro_actionaireJSON,List<MD_Syncro_Configuration>.class);
		List<MD_Syncro_Configuration> synchro_participation = (List<MD_Syncro_Configuration>) JSON.deserialize(synchro_participationJSON,List<MD_Syncro_Configuration>.class);

		System.debug(synchro);
		System.debug(synchro.size());
		for( MD_Syncro_Configuration sync : synchro){
			datas_syncro.put(''+sync.DeveloperName,new Map<String,Object>{
				'Creation__c' => sync.Creation || sync.Required,
				'Mise_a_jour__c' => sync.Mise_a_jour
			});
		}
		System.debug(datas_syncro);
		datas.put('Altares_Fields_Synchro__mdt',datas_syncro);

		Map<String,Map<String,Object>> datas_synchro_dirigeant = new Map<String,Map<String,Object>>();
		for( MD_Syncro_Configuration sync : synchro_dirigeant){
			datas_synchro_dirigeant.put(''+sync.DeveloperName,new Map<String,Object>{
				'Creation__c' => sync.Creation || sync.Required,
				'Mise_a_jour__c' => sync.Mise_a_jour
			});
		}
		System.debug(datas_synchro_dirigeant);
		datas.put('Altares_Field_Synchro_Dirigeant__mdt',datas_synchro_dirigeant);

		Map<String,Map<String,Object>> datas_synchro_actionaire = new Map<String,Map<String,Object>>();
		for( MD_Syncro_Configuration sync : synchro_actionaire){
			datas_synchro_actionaire.put(''+sync.DeveloperName,new Map<String,Object>{
				'Creation__c' => sync.Creation || sync.Required,
				'Mise_a_jour__c' => sync.Mise_a_jour
			});
		}
		System.debug(datas_synchro_actionaire);
		datas.put('Altares_Field_Synchro_Actionnaire__mdt',datas_synchro_actionaire);

		Map<String,Map<String,Object>> datas_synchro_participation = new Map<String,Map<String,Object>>();
		for( MD_Syncro_Configuration sync : synchro_participation){
			datas_synchro_participation.put(''+sync.DeveloperName,new Map<String,Object>{
				'Creation__c' => sync.Creation || sync.Required,
				'Mise_a_jour__c' => sync.Mise_a_jour
			});
		}
		System.debug(datas_synchro_participation);
		datas.put('Altares_Field_Synchro_Participation__mdt',datas_synchro_participation);

		try{
			Util_CustomMetadata.updateCustomMetadataValue(datas);
		}catch (Exception e) {
			throw new AuraHandledException('Custom Metadata Error : ' + e.getMessage());
		}

	}

	@future
	private static void setNbResult(Decimal nbResult){

		if (!Util_CrudFLS.isUpsertable('Altares_Configuration__c', new List<String>{
                'Nombre_de_resultat__c'
		})){
			throw new AuraHandledException(Label.Erreur_Permissions_insuffisante);
		}

		Altares_Configuration__c config = Altares_Configuration__c.getOrgDefaults();
		
		config.Nombre_de_resultat__c = nbResult;

		try {
			upsert config;
		} catch (Exception e) {
			System.debug(e.getMessage());
			throw new AuraHandledException(e.getMessage());
		}
	}
}