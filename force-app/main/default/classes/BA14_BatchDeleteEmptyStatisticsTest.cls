@isTest
public class BA14_BatchDeleteEmptyStatisticsTest {

   @isTest
    public static void testDeletion(){
        Statistique_Analtytics__c statTest = new Statistique_Analtytics__c();
        statTest.Nb__c = 0;
        insert statTest;
        
        List<Statistique_Analtytics__c> retSOQL = [SELECT Id FROM Statistique_Analtytics__c];
        
        System.assertEquals(1, retSOQL.size());
        
        Test.startTest();
        
        BA14_BatchDeleteEmptyStatisticAnalytics myBatchObject = new BA14_BatchDeleteEmptyStatisticAnalytics(); 

        myBatchObject.start(null);
        myBatchObject.execute(null,retSOQL);
        myBatchObject.finish(null);
        
        String CRON_EXP2 = '0 0 0 3 9 ? 2022';
        String job2Id = System.schedule('SchedulerTE2', CRON_EXP2, new SchBT10_ScheduleStatAnalyticsDeletion());
        CronTrigger ct2 = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :job2Id]; 
        System.assertEquals(0, ct2.TimesTriggered);
        
        retSOQL = [SELECT Id FROM Statistique_Analtytics__c];
        System.assertEquals(0, retSOQL.size());
        
        Test.stopTest();
        
    }
}