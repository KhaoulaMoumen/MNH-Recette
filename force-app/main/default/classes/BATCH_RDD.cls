global class BATCH_RDD implements Database.Batchable<sObject>, Database.AllowsCallouts {
    global String startDate;
    global Integer numberOfDays;
    global String endDate;
    
    public BATCH_RDD(Integer mois, Integer year) {
        numberOfDays = Date.daysInMonth(year, mois);
        String month = (mois < 10)?'0'+mois:String.valueOf(mois); 
        startDate = year+'-'+month+'-01';
        endDate = year+'-'+month+'-'+numberOfDays;
    }
    
    public BATCH_RDD(String startDate, String endDate) {
        this.startDate = startDate;
        this.endDate = endDate;        
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        String query = '';
        if(!Test.isRunningTest()){
            query = 'SELECT Id,ContactId,Contact.AccountId FROM User WHERE isActive = true AND isPortalEnabled = true';
        }else{
            query = 'SELECT Id,ContactId,Contact.AccountId FROM User WHERE isActive = true AND isPortalEnabled = true LIMIT 1';
        }
        return Database.getQueryLocator(query); 
    }
    
    global void execute(Database.BatchableContext BC, List<User> users) {
        try {
            BATCH_RDD_Manager.updateMonthStats(users, startDate, endDate);
        } 
        catch(Exception e) {
            System.debug(e);
        }
    }   
    
    global void finish(Database.BatchableContext BC) {}
}