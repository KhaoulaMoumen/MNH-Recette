@isTest(SeeAllData=false)
public class AP03_GestionCommunityUsers_test {
    @testSetup 
    static void setup() {
        list<Account> accs1 = Datafactory.createAccounts(1, 'Adhérent', 'Accepté', true);
        list<Contact> cons1 = Datafactory.createContacts(3, accs1[0].id, 'Interlocuteur administratif', false);
        cons1[0].Fonction__c = 'Co-gérant';
        cons1[1].Fonction__c = 'Gérant / Directeur Général';
        insert cons1;
        
    }
    static testmethod void testactiverAdherent() {
        Set<ID> accIds= new Set<ID>();
        Id accId = [select id from account where recordtype.name = 'Adhérent' limit 1].id;
        accIds.add(accId);
        test.startTest();
        AP03_GestionCommunityUsers.activerAdherent(accIds);
        test.stopTest();
        list<User> users = [select id from user where accountid =: accId];
        system.assertEquals(1, users.size());
    }
    static testmethod void testactiverDesPartenaire() {
        Id conId = [select id from contact where Fonction__c = 'Président' limit 1].id;
        test.startTest();
        AP03_GestionCommunityUsers.activerPartenaire(conId);
        AP03_GestionCommunityUsers.desactiverPartenaire(conId);
        test.stopTest();
        list<User> users = [select id,IsActive from user where contactid =: conId];
        system.assertEquals(1, users.size());
        system.assertEquals(false, users[0].IsActive);
        
    }
    static testmethod void testdeactivatePortalUser() {
        Set<ID> accIds= new Set<ID>();
        Id accId = [select id from account where recordtype.name = 'Adhérent' limit 1].id;
        accIds.add(accId);
        test.startTest();
        AP03_GestionCommunityUsers.activerAdherent(accIds);
        AP03_GestionCommunityUsers.deactivatePortalUser(accIds);
        test.stopTest();
        list<User> users = [select id,IsActive from user where accountid =: accId];
        system.assertEquals(false, users[0].IsActive);
    }
    static testmethod void testgroupUsersByContactId() {
        test.startTest();
        Id conId = [select id from contact where Fonction__c = 'Président' limit 1].id;
        list<User> users =Datafactory.createUsers(1, 'Adhérent', false, false, false, false);
        users[0].contactid = conId;
        insert users;
        
        AP03_GestionCommunityUsers.groupUsersByContactId(users);
        test.stopTest();
    }
    static testmethod void testactiverClient() {
        test.startTest();
        list<Account> accs2 = Datafactory.createAccountsClient(1, 'Client', 'Non applicable', true);
        list<Contact> cons2 = Datafactory.createContacts(1, accs2[0].id, 'Interlocuteur administratif', false);
        cons2[0].Fonction__c = 'Gérant / Directeur Général';
        insert cons2;
        Set<ID> accIds= new Set<ID>();
        Id accId = [select id from account where recordtype.name = 'Client' limit 1].id;
        accIds.add(accId);
        
        AP03_GestionCommunityUsers.activerClient(accIds);
        test.stopTest();
        list<User> users = [select id from user where accountid =: accId];
        system.assertEquals(1, users.size());
    }
    
}