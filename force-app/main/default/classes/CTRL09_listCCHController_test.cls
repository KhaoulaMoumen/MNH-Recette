@isTest
public class CTRL09_listCCHController_test {
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
        User u =[select id, username from user limit 1 ]     ;  
        
        CTRL09_listCCHController.getCCHs(u.id);
        Test.stopTest();
        
        }


}