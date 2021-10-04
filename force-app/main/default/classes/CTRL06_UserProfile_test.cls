@isTest
public class CTRL06_UserProfile_test {
    @testSetup 
    static void setup() {
        list<Account> accs = Datafactory.createAccounts(1, 'Adhérent', 'Accepté', true);
        list<Contact> cons =Datafactory.createContacts(1, accs[0].id, 'Interlocuteur administratif', true);
    }
    static testmethod void test() {
        Contact c  = [select id from contact limit 1];
        Account a  = [select id from account limit 1];
        Test.startTest();
        CTRL06_UserProfile.sendEmailverification(a.id,c.id,'hayfa.garbout@talan.com');
        CTRL06_UserProfile.getAccountInfos();
        Test.stopTest();
    }

}