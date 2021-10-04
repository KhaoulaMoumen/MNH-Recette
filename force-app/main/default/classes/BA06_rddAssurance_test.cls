@isTest
public class BA06_rddAssurance_test {
     @testSetup 
    static void setup() {
        List<Account> accountsTest = DataFactory.createAccounts(1, 'Adhérent', 'Accepté', true);
        List<Lead> leadsTest = DataFactory.createLeads(1, true);
        List<Assurance__c> AssuranceTest = DataFactory.createAssurances(1, 'Autorisée', true);
        List<Assurances__c> AssurancesTest = DataFactory.createAssurancesPH(1, AssuranceTest[0].id, accountsTest[0].id, leadsTest[0].id, Date.today()-1, Date.today()+10, 'Responsabilité civile', true);
        List<Qualification_prospect_adherent__c> qualifsTest = DataFactory.createQualificationsPH(1, accountsTest[0].id, leadsTest[0].id, Date.today()-1, Date.today()+10, true);

    }

    static testmethod void test() {
        Test.startTest();
        Database.executeBatch(new BA06_rddAssurance());
        Database.executeBatch(new BA07_rddqualifis());
        Test.stopTest();
    }

}