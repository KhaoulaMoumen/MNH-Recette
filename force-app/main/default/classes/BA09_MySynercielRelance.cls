/*
BATCH
CreatedBy : MOUMEN Khaoula
@Email : khaoula.moumen@talan.com
CreateDate : 04/12/2020
*/
global class BA09_MySynercielRelance implements Database.Batchable<sObject>, Database.Stateful {
    public String  query;
    
    String requete = 'SELECT Id FROM User WHERE Tech_PortailRelance__c = true'+(Test.isRunningTest()?' LIMIT 200':'');

    global Database.QueryLocator start(Database.BatchableContext bc){
        
        this.query = requete;
        
        return Database.getQueryLocator(this.query);
    }
    
    global void execute(Database.BatchableContext BC, List<User> scope){
        
        for(User u : scope) {
            System.resetPassword(u.Id, true);
        }
        
    }
    global void finish(Database.BatchableContext BC){
        
    }
}