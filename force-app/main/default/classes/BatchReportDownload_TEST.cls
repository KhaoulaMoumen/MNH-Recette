@isTest(seeAllData=true)
public class BatchReportDownload_TEST {

    @isTest
    static void testReportDownload() {
        Test.setMock(HttpCalloutMock.class, new ReportHttpCalloutMock()); 
        
    	System.Test.startTest();
        BatchReportDownload theBatch = new BatchReportDownload();
        Database.executeBatch(theBatch);
        System.Test.stopTest();
        
    }
}