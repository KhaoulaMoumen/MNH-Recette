@isTest(Seealldata=false)
private class  ScheduleBatchCompteUpdateQualite_TEST {

    // toutes les heures
    public static String CRON_EXP = '0 0 * * * ?';
  
    @isTest static void testSchedule()  {
        // Schedule the test job
        String jobId = System.schedule('ScheduleBatchCompteUpdateQualite',
                        CRON_EXP, 
                        new ScheduleBatchCompteUpdateQualite());
    }
}