global class BA14_BatchDeleteEmptyStatisticAnalytics implements Database.Batchable<sObject> {
    String query = '';
    Id utilisateurRT = Schema.SObjectType.Statistique_Analtytics__c.getRecordTypeInfosByName().get('Utilisateur').getRecordTypeId();
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        query = 'SELECT Id FROM Statistique_Analtytics__c WHERE RecordTypeId = :utilisateurRT AND Nb__c = 0 AND Date_de_fin__c < THIS_MONTH AND Date_de_debut__c >= LAST_MONTH';
        return Database.getQueryLocator(query); 
    }
     
    global void execute(Database.BatchableContext BC, List<Statistique_Analtytics__c> stats) {        
        try {
            if(stats.size() > 0) CTRL12_AnalyticsManagement.deleteEmptyStats(stats);
        } catch(Exception e) {
            System.debug(e);
        }
         
    }   
     
    global void finish(Database.BatchableContext BC) {
        
    }
}