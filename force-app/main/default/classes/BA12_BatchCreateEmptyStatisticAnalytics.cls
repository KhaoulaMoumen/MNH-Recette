global class BA12_BatchCreateEmptyStatisticAnalytics implements Database.Batchable<sObject> {
    
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
        Date startDate = Date.newInstance(Date.Today().year(),Date.today().month(),1);
        Integer numberOfDays = Date.daysInMonth(Date.Today().year(), Date.Today().month());
        Date endDate = Date.newInstance(Date.Today().year(), Date.Today().month(), numberOfDays);
        
        try {
            
            CTRL12_AnalyticsManagement.createStatisticsAnalyticsEmpty(users, startDate, endDate);
            
        } catch(Exception e) {
            System.debug(e);
        }
        
    }   
    
    global void finish(Database.BatchableContext BC) {
        
    }
}