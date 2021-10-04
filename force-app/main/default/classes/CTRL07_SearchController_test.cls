@isTest
public class CTRL07_SearchController_test {
    @testSetup 
    static void setup() {
        list<Account> accs = Datafactory.createAccounts(1, 'Adhérent', 'Accepté', true);
        list<Contact> cons =Datafactory.createContacts(1, accs[0].id, 'Interlocuteur administratif', true);
        list<User> myusers = Datafactory.createUsers(1,'Adhérent',false,false,false,false);
        myusers[0].contactid=cons[0].id;
        insert myusers[0];

    }
    static testmethod void test() {
        Test.startTest();
        User u =[select username,Contact.account.name from user where profile.name like 'Adhérent' limit 1];
        list<String> metiers =CTRL07_SearchController.getMetierList();
        list<user> users =CTRL07_SearchController.fetchUsers( u.username, 'a-b c', 'a k', '14', 'a', 'a');
        Test.stopTest();
        system.assertequals(users.size(),0);
        
        }

}