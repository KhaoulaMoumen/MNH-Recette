@isTest
private class TEST_Batch_Dataxess_Scheduler {
        static testMethod void TEST_Batch_Scheduler() {
            Test.startTest();

        String CRON_EXP = '0 0 0 3 9 ? 2022';
        // Schedule the test job
        String jobId = System.schedule('SchedulerTE', CRON_EXP, new Batch_Dataxess_UpdateAccounts_Scheduler());


        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId]; 
        // Verify the expressions are the same System.assertEquals(CRON_EXP, ct.CronExpression); 
        // Verify the job has not run 
        System.assertEquals(0, ct.TimesTriggered); 
        Test.stopTest();
    }

}