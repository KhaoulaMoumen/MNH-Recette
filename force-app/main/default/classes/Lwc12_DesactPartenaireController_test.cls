@isTest
public class Lwc12_DesactPartenaireController_test {
    @testSetup 
    static void setup() {
        list<Account> accs = Datafactory.createAccounts(1, 'Adhérent', 'Accepté', true);
        list<Contact> cons =Datafactory.createContacts(4, accs[0].id, 'Interlocuteur administratif', false);
        
        list<User> users = Datafactory.createUsers(3, 'Adhérent', false, false, false, false);
        cons[0].email='0testlwc12@gmail.com';
        cons[1].email='1testlwc12@gmail.com';
        cons[2].email='2testlwc12@gmail.com';
        insert cons;
        users[0].contactid = cons[0].id;
        users[1].contactid = cons[1].id;
        users[2].contactid = cons[2].id;
        users[1].username = 'runUser@test.com';
        users[0].IsActive=true;
        users[1].IsActive=true;
        users[2].IsActive=true;
        insert users;
        
        
        
        
        
    }
    static testmethod void test() {
        Id conId = [select id from contact where email like '%0%' limit 1].id;
        Lwc12_DesactiverPartenaireController.desactiverPartenaire(conId);
        test.startTest();
        try{
            Id conId1 = [select id from user limit 1].id;
            Lwc12_DesactiverPartenaireController.desactiverPartenaire('test');
            
        }
        catch(Exception e){
            system.debug('exception');
        }
        
        test.stopTest();
        list<User> users = [select id,IsActive from user where contactid =: conId];
        system.assertEquals(false, users[0].IsActive);
        
    }
    static testmethod void testSynercielException() {
        User myUser  = [select id from User where username like 'runUser@test.com' limit 1];
        Contact contact = [SELECT Id FROM Contact WHERE LastName = 'TEST3' LIMIT 1];
        
        System.runAs(myUser) {
            
            list<Contact> cons  = [select id,email from contact where email like '%0%' limit 1];
            Test.startTest();
            
            
            try{
                Lwc12_DesactiverPartenaireController.desactiverPartenaire(cons[0].id);
            }
            catch(Exception e){
                system.debug('exception');
            }
            
            Test.stopTest();
        }
    }
    
}