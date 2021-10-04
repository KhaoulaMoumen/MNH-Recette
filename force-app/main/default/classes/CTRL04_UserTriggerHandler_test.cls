@isTest(SeeAllData=false)
public class CTRL04_UserTriggerHandler_test {
    @testSetup  
    static void setup() {
        list<Account> accs = Datafactory.createAccounts(1, 'Adhérent', 'Accepté', false);
        accs[0].Profil__c='Adhérent';
        accs[0].sirenSiret__c='32104533800019';
        insert accs;
        list<User> users = Datafactory.createUsers(1, 'System Administrator', false, true, false, false);
        users[0].username = 'testPBFalse@test.com';
        insert users;
        
        list<Account> accs1 = Datafactory.createAccountsPartenaire(1, 'Partenaire', 'Non applicable', true);
        list<Contact> cons1 = Datafactory.createContacts(3, accs1[0].id, 'Interlocuteur administratif', false);
        cons1[0].Fonction__c = 'Co-gérant';
        cons1[1].Fonction__c = 'Gérant / Directeur Général';
        insert cons1;
        
    }
    static testmethod void testInsert() {
        Test.startTest();
        list<Account> accs1 = Datafactory.createAccounts(1, 'Adhérent', 'Accepté', false);
        accs1[0].Profil__c='Adhérent';
        accs1[0].sirenSiret__c='47911587500029';
        insert accs1;
        list<Account> accs = Datafactory.createAccounts(1, 'Partenaire', 'Non applicable', false);
        accs[0].Profil__c='Partenaire';
        insert accs;
        list<Contact> cons =Datafactory.createContacts(1, accs[0].id, 'Interlocuteur administratif', true);
        list<Contact> cons1 =Datafactory.createContacts(1, accs1[0].id, 'Interlocuteur administratif', true);
        list<User> users = Datafactory.createUsers(2, 'Adhérent', false, false, false, false);
        users[0].contactid = cons[0].id;
        users[1].contactid = cons1[0].id;

        insert users;
        
        accs1[0].BillingPostalCode = '75000';
        update accs1[0];
		Test.stopTest();
    }
    static testmethod void testUpdate() {
        /*User runUser = [select id from user where username like 'testPBFalse@test.com' limit 1];
        list<Account> accs = Datafactory.createAccounts(1, 'Partenaire', 'Non applicable', false);
        accs[0].Profil__c='Partenaire';
        insert accs;
        list<Contact> cons =Datafactory.createContacts(1, accs[0].id, 'Interlocuteur administratif', true);
        System.runAs(runUser) {
        list<User> users = Datafactory.createUsers(1, 'Partenaire', false, false, false, false);
        users[0].contactid = cons[0].id;
        users[0].username = 'testUpdate@test.com';
        users[0].isActive = true;
        
        insert users;
        test.startTest();
        User u = [select id,isActive from user where username like 'testUpdate@test.com' limit 1 ];
        u.isActive=false;
        update u;
        test.stopTest();
        }*/
        Set<ID> accountIDs = new Set<ID>();
        Id acc = [select id from Account where Profil__c='Partenaire' limit 1].id;
        accountIDs.add(acc);
        test.startTest();
        CTRL04_UserTriggerHandler.Meth01_afterDisablingPartners(accountIDs);
        test.stopTest();
        
    }

}