@isTest
private class  SchBT01_AccountConventionTypeUpdateTest {
    // toutes les heures
    public static String CRON_EXP = '0 30 * * * ?';  
    @isTest static void testSchedule()  {
        Test.StartTest();
        // Schedule the test job
        String jobId = System.schedule('SchBT01_AccountConventionTypeUpdate',
                        CRON_EXP, 
                        new SchBT01_AccountConventionTypeUpdate());
		Test.stopTest();        
    }
}