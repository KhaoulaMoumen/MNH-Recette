//Written by Kevin Mercier , 20/08/2019

@isTest
private class TriggerExecutedTest {

    static testMethod void testGetSet() {
        Test.startTest();
        System.assertEquals(0, TriggerExecuted.getExecuted());
        TriggerExecuted.setExecuted();
        System.assertEquals(1, TriggerExecuted.getExecuted());
        TriggerExecuted.reset();
        System.assertEquals(0, TriggerExecuted.getExecuted());
        Test.stopTest(); 
    }
    
}