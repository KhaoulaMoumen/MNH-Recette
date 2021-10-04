global with sharing class MD_Syncro_Configuration {

	@auraEnabled global String MasterLabel;
	@auraEnabled global String DeveloperName;
	@auraEnabled global Boolean Creation;
	@auraEnabled global Boolean Mise_a_jour;
	@auraEnabled global Boolean Required;

	public MD_Syncro_Configuration(String MasterLabel, String DeveloperName, Boolean Creation, Boolean Mise_a_jour , Boolean Required) {
		System.debug('MD_Syncro_Configuration');
		this.MasterLabel = MasterLabel;
		this.DeveloperName = DeveloperName;
		this.Creation = Creation;
		this.Mise_a_jour = Mise_a_jour;
		this.Required = Required;
	}

	public MD_Syncro_Configuration(Altares_Fields_Synchro__mdt md)
	{
		this(md.MasterLabel,md.DeveloperName,md.Creation__c,md.Mise_a_jour__c,md.Required__c);
		useTranslate('Account',md.DeveloperName);
		useTranslate('Lead',md.DeveloperName);
	}

	public MD_Syncro_Configuration(Altares_Field_Synchro_Dirigeant__mdt md)
	{
		this(md.MasterLabel,md.DeveloperName,md.Creation__c,md.Mise_a_jour__c,md.Required__c);
		useTranslate('Dirigeant_et_decideur__c',md.DeveloperName);
	}

	public MD_Syncro_Configuration(Altares_Field_Synchro_Actionnaire__mdt md)
	{
		this(md.MasterLabel,md.DeveloperName,md.Creation__c,md.Mise_a_jour__c,md.Required__c);
		useTranslate('Actionnaire__c',md.DeveloperName);
	}

	public MD_Syncro_Configuration(Altares_Field_Synchro_Participation__mdt md)
	{
		this(md.MasterLabel,md.DeveloperName,md.Creation__c,md.Mise_a_jour__c,md.Required__c);
		useTranslate('Participation__c',md.DeveloperName);
	}

	public static List<MD_Syncro_Configuration> getFromList(List<Altares_Fields_Synchro__mdt> mds){
		List<MD_Syncro_Configuration> output = new List<MD_Syncro_Configuration>();
		for (Altares_Fields_Synchro__mdt md : mds) {
			output.add(new MD_Syncro_Configuration(md));
		}
		return output;
	}

	public static List<MD_Syncro_Configuration> getFromList(List<Altares_Field_Synchro_Dirigeant__mdt> mds){
		List<MD_Syncro_Configuration> output = new List<MD_Syncro_Configuration>();
		for (Altares_Field_Synchro_Dirigeant__mdt md : mds) {
			output.add(new MD_Syncro_Configuration(md));
		}
		return output;
	}

	public static List<MD_Syncro_Configuration> getFromList(List<Altares_Field_Synchro_Actionnaire__mdt> mds){
		List<MD_Syncro_Configuration> output = new List<MD_Syncro_Configuration>();
		for (Altares_Field_Synchro_Actionnaire__mdt md : mds) {
			output.add(new MD_Syncro_Configuration(md));
		}
		return output;
	}

	public static List<MD_Syncro_Configuration> getFromList(List<Altares_Field_Synchro_Participation__mdt> mds){
		List<MD_Syncro_Configuration> output = new List<MD_Syncro_Configuration>();
		for (Altares_Field_Synchro_Participation__mdt md : mds) {
			output.add(new MD_Syncro_Configuration(md));
		}
		return output;
	}

	private void useTranslate(String sObjectName,String fieldName){
		Map<String,Schema.SObjectField> descMap = Schema.getGlobalDescribe().get(sObjectName).getDescribe().fields.getMap();

		if(descMap.get(fieldName) != null)
			this.MasterLabel = descMap.get(fieldName).getDescribe().getLabel();
		
		if(descMap.get(''+fieldName+'__c') != null)
			this.MasterLabel = descMap.get(''+fieldName+'__c').getDescribe().getLabel();
	}
}