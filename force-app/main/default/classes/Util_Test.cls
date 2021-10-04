@isTest
global with sharing class Util_Test {
	
	global static CustomSettingCls CustomSetting = new CustomSettingCls();

	global with sharing class CustomSettingCls {
		global CustomSettingCls() {

		}

		global Altares_Configuration__c createConfiguration() {
			Altares_Configuration__c config = Altares_Configuration__c.getOrgDefaults();

			if (config.Id != null) {
				return config;
			} else {
				if (Util_CrudFLS.isCreateable(
					'Altares_Configuration__c', 
					new List<String>{
						'Login__c', 
						'Mot_de_passe__c',
						'Reference_client__c',
						'Nombre_de_resultat__c'
					}
					)
				) {
					config.Login__c = 'Login__c';
					config.Reference_client__c = 'Reference_client__c';
					config.Mot_de_passe__c = 'Mot_de_passe__c';
					config.Nombre_de_resultat__c = 200;
					
					insert config;
					}  else {
			            throw new AuraHandledException(Label.Erreur_Permissions_insuffisante);
			        }
				return config;
			}
			
		}
	}
	
}