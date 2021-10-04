global class BA06_rddAssurance implements Database.Batchable<sObject>  {

    global Database.QueryLocator start (Database.BatchableContext bc) {
         return Database.getQueryLocator('select id,Compte__c,Prospect__c from Assurances__c');
    }
    global void execute(Database.BatchableContext bc, List<Assurances__c> scope){
      EUR05_AssurancesPATriggered manageAssurancesInsertOrDelete = new EUR05_AssurancesPATriggered(scope,true);
    }
    global void finish(Database.BatchableContext bc){
        // execute any post-processing operations
    }
}