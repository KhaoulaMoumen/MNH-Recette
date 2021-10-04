public with sharing class Util_CURules {
    private static Util_CURules classInstance;

    private static Map<String,Altares_Fields_Synchro__mdt> synchro;
    private static Map<String,Altares_Field_Synchro_Dirigeant__mdt> synchro_dirigeant;
    private static Map<String,Altares_Field_Synchro_Actionnaire__mdt> synchro_actionaire;
    private static Map<String,Altares_Field_Synchro_Participation__mdt> synchro_participation;
    
    private static String prefix;

    static {
        synchro = new Map<String,Altares_Fields_Synchro__mdt>();
        synchro_dirigeant = new Map<String,Altares_Field_Synchro_Dirigeant__mdt>();
        synchro_actionaire = new Map<String,Altares_Field_Synchro_Actionnaire__mdt>();
        synchro_participation = new Map<String,Altares_Field_Synchro_Participation__mdt>();
        classInstance = new Util_CURules();
        prefix = '';
    }

    private Util_CURules() {

        List<Altares_Fields_Synchro__mdt> synchroList = [SELECT DeveloperName, Creation__c, Mise_a_jour__c FROM Altares_Fields_Synchro__mdt Order By MasterLabel LIMIT 1000];
        for (Altares_Fields_Synchro__mdt rule : synchroList) {
           synchro.put(rule.DeveloperName,rule);
        }

		List<Altares_Field_Synchro_Dirigeant__mdt> synchro_dirigeantList = [SELECT DeveloperName, Creation__c, Mise_a_jour__c FROM Altares_Field_Synchro_Dirigeant__mdt LIMIT 1000];
        for (Altares_Field_Synchro_Dirigeant__mdt rule : synchro_dirigeantList) {
           synchro_dirigeant.put(rule.DeveloperName,rule);
        }

		List<Altares_Field_Synchro_Actionnaire__mdt> synchro_actionaireList = [SELECT DeveloperName, Creation__c, Mise_a_jour__c FROM Altares_Field_Synchro_Actionnaire__mdt LIMIT 1000];
        for (Altares_Field_Synchro_Actionnaire__mdt rule : synchro_actionaireList) {
           synchro_actionaire.put(rule.DeveloperName,rule);
        }

		List<Altares_Field_Synchro_Participation__mdt> synchro_participationList = [SELECT DeveloperName, Creation__c, Mise_a_jour__c FROM Altares_Field_Synchro_Participation__mdt LIMIT 1000];
        for (Altares_Field_Synchro_Participation__mdt rule : synchro_participationList) {
           synchro_participation.put(rule.DeveloperName,rule);
        }
    }

    public static Util_CURules getInstance() {
        return classInstance;
    }

    public void synchro(sObject record, String field , Object value){
        String fieldWithoutPrefix = field.replace(prefix,'').replace('__c','');
        if( (record.Id == null && synchro.get(fieldWithoutPrefix).Creation__c) || record.Id != null && synchro.get(fieldWithoutPrefix).Mise_a_jour__c ){
            record.put(field,value);
        }
    }

    public void synchro_dirigeant(sObject record, String field , Object value){
        String fieldWithoutPrefix = field.replace(prefix,'').replace('__c','');
        if( (record.Id == null && synchro_dirigeant.get(fieldWithoutPrefix).Creation__c) || record.Id != null && synchro_dirigeant.get(fieldWithoutPrefix).Mise_a_jour__c ){
            record.put(field,value);
        }
    }

    public void synchro_actionaire(sObject record, String field , Object value){
        String fieldWithoutPrefix = field.replace(prefix,'').replace('__c','');
        if( (record.Id == null && synchro_actionaire.get(fieldWithoutPrefix).Creation__c) || record.Id != null && synchro_actionaire.get(fieldWithoutPrefix).Mise_a_jour__c ){
            record.put(field,value);
        }
    }

    public void synchro_participation(sObject record, String field , Object value){
        String fieldWithoutPrefix = field.replace(prefix,'').replace('__c','');
        if( (record.Id == null && synchro_participation.get(fieldWithoutPrefix).Creation__c) || record.Id != null && synchro_participation.get(fieldWithoutPrefix).Mise_a_jour__c ){
            record.put(field,value);
        }
    }

}