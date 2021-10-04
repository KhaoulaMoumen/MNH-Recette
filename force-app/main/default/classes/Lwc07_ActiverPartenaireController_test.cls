@isTest
public class Lwc07_ActiverPartenaireController_test {
    @testSetup 
    static void setup() {
        list<Account> accs = Datafactory.createAccounts(1, 'Adhérent', 'Accepté', true);
        list<Contact> cons =Datafactory.createContacts(3, accs[0].id, 'Interlocuteur administratif', false);
        list<User> users = Datafactory.createUsers(1, 'Adhérent', false, false, false, false);
        cons[0].email='0testlwc07@gmail.com';
        cons[1].email='1testlwc07@gmail.com';
        cons[2].email='2testlwc07@gmail.com';
        insert cons;
        users[0].contactid = cons[2].id;
        system.debug(cons[2]);
        insert users[0];
    }
    static testmethod void test() {
        list<Contact> cons  = [select id,email from contact where email like '%0%' limit 1];
        system.debug('hayfa'+cons[0].email);
        Test.startTest();
        Lwc07_ActiverPartenaireController.activerPartenaire(cons[0].id);
        list<User> users = [select id from user where contactid=:cons[0].id];
        try{
            Lwc07_ActiverPartenaireController.activerPartenaire(cons[0].id);
        }
        catch(Exception e){
                system.debug('exception');
            }
        
        Test.stopTest();
        system.assertequals(users.size(),1);
        
        }
    
    static testmethod void testSynercielException() {
        User myUser  = [select id from User limit 1];
        System.runAs(myUser) {
             list<Contact> cons  = [select id,email from contact where email like '%1%' limit 1];
            system.debug(cons[0].email);
        Test.startTest();
            try{
                Lwc07_ActiverPartenaireController.activerPartenaire(cons[0].id);
            }
            catch(Exception e){
                system.debug('exception');
            }
        
        Test.stopTest();
        }
    }
    

}