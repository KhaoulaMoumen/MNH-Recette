/*
    Modfications:
        Ahmad Koubeissy    24-06-2021      Added the labels to the dates for data recevory purpose
*/

global class BA13_BatchUpdateStatisticAnalytics implements Database.Batchable<sObject>,Database.AllowsCallouts, Database.Stateful{
    global Database.QueryLocator start(Database.BatchableContext BC) {
        String query = '';
        if(!Test.isRunningTest()){
            query = 'SELECT Id,ContactId,Contact.AccountId FROM User WHERE  isPortalEnabled = true'; //isActive = true AND
        }else{
            query = 'SELECT Id,ContactId,Contact.AccountId FROM User WHERE isActive = true AND isPortalEnabled = true LIMIT 1';
       }
        return Database.getQueryLocator(query); 
    }
     
    global void execute(Database.BatchableContext BC, List<User> users) {
        /* Commented by Ahmad Koubeissy and used System.now().format
        String month = (Date.today().month() < 10)?'0'+Date.today().month():String.valueOf(Date.today().month()); 
        String day =   (Date.today().day() < 10)?'0'+Date.today().day():String.valueOf(Date.today().day()); 
        String startDate = Date.today().year()+'-'+month+'-'+day;*/
        
        //Labels values should always be equal to null. Only change them in case of data recovery
        // (Date are expected in format YYYY-MM-DD )
        String startDate = (system.label.GetAnalyticsFromDate !='null' ? system.label.GetAnalyticsFromDate: System.now().format('yyyy-MM-dd'));
        String endDate = (system.label.GetAnalyticsToDate != 'null' ? system.label.GetAnalyticsToDate : startDate);
        // process each batch of records default size is 200
        
        try {
            // Update the Account Record
            CTRL12_AnalyticsManagement.updateMonthStats(users, startDate, endDate);
         
        } catch(Exception e) {
            System.debug(e);
        }
         
    }   
     
    global void finish(Database.BatchableContext BC) {
        // execute any post-processing operations like sending email
    }
}