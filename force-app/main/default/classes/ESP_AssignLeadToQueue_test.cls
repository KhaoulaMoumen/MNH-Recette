@isTest
public class ESP_AssignLeadToQueue_test {
    @testSetup 
    static void setup() {
        list<Account> accs = Datafactory.createAccounts(1, 'Adhérent', 'Accepté', true);
        List<Lead> leads = Datafactory.createLeads(1, false);
        leads[0].lastname = 'testESP';
        leads[0].LeadSource='PARRAINAGE';
        leads[0].parrain__c	=accs[0].id;
        insert leads;
    }
    
    static testmethod void test() {
        list<Id> leadIds = new list<Id>();
        Lead myLead = [select ownerid,id from Lead where lastname like 'testESP' limit 1 ];
        leadIds.add(myLead.id);
        Test.startTest();
        ESP_AssignLeadToQueue.LeadAssign(leadIds);
        Test.stopTest();
        Lead myLead1 = [select ownerid,id from Lead where lastname like 'testESP' limit 1 ];
        Group queue = [select name from Group where id =: myLead1.ownerid limit 1];
        system.assertEquals('Parrainage',queue.name);

    }

}