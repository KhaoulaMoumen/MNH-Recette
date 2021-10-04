@isTest
public class LNC09_ParrainageFormController_test {
    @testSetup 
    static void setup() {
        list<Account> accs = Datafactory.createAccounts(1, 'Adhérent', 'Accepté', false);
        accs[0].name = 'test lnc09';
        insert accs;
        list<Contact> cons =Datafactory.createContacts(1, accs[0].id, 'Interlocuteur administratif', true);
        list<User> users = Datafactory.createUsers(1, 'Adhérent', false, false, false, false);
        users[0].contactid = cons[0].id;
        insert users;
        List<Parrainage__c > p = Datafactory.createParrainage(1, accs[0].id, true);

    }
    static testmethod void testgetUserInfos() {
        User u = [select username,accountid from user where profile.name = 'Responsable de secteur' limit 1 ];
        Test.startTest();
        User result = LNC09_ParrainageFormController.getUserInfos(u.username);
        Test.stopTest();
        system.assertEquals(u.accountid, result.accountid);
        
    }
    static testmethod void testlaunchFlowParrainage() {
        Parrainage__c parrainage = [select id from Parrainage__c limit 1];
        Id userID = [select id from user where profile.name = 'Responsable de secteur' limit 1 ].id;
        Test.startTest();
        String result = LNC09_ParrainageFormController.launchFlowParrainage( parrainage, userID);
        Test.stopTest();
        system.assertEquals('success', result);
    }
    static testmethod void testgetLeadDepartment() {
        Parrainage__c parrainage = [select id,leadDepartementParrainage__c from Parrainage__c limit 1];
        Test.startTest();
        List<String> result = LNC09_ParrainageFormController.getLeadDepartment();
        Test.stopTest();
        system.assert(result.contains(Parrainage__c.leadDepartementParrainage__c.getDescribe().getPicklistValues()[0].getLabel()));
        
    }


}