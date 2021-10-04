@isTest
public class ESP_SendEmailFileulParrainage_test {
    @testSetup 
    static void setup() {
        List<Lead> leads = Datafactory.createLeads(1, true);
    }
    
    static testmethod void test() {
        Lead sponsoredLead = [select id from Lead limit 1 ];
        ESP_SendEmailFileulParrainage.Request req = new ESP_SendEmailFileulParrainage.Request ();
        req.sponsoredLead = sponsoredLead.id;
        Test.startTest();
        ESP_SendEmailFileulParrainage.Request[] rqs = new ESP_SendEmailFileulParrainage.Request[]{req};
        ESP_SendEmailFileulParrainage.SendEmail(rqs);
        Integer invocations = Limits.getEmailInvocations();
        Test.stopTest();
        system.assertEquals(1, invocations,  ' An email should be sent');


    }

}