global class BA07_rddqualifis implements Database.Batchable<sObject>  {

    global Database.QueryLocator start (Database.BatchableContext bc) {
         return Database.getQueryLocator('select id,Compte__c,Prospect__c from Qualification_prospect_adherent__c');
    }
    global void execute(Database.BatchableContext bc, List<Qualification_prospect_adherent__c> scope){
      EUR04_QualificationTriggered manageAssurancesInsertOrDelete = new EUR04_QualificationTriggered(scope,true);
    }
    global void finish(Database.BatchableContext bc){
        // execute any post-processing operations
    }
}