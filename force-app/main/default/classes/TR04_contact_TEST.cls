/*
* Edited by Khaoula MOUMEN <khaoula.moumen@talan.com>, June 2020
 */
@isTest
public class TR04_contact_TEST {
    
    @isTest static void TestUpdateUserAccount(){
        
    // CREATE USER WITH PROFIL SYSTEM ADMINISTRATOR 
    List<User> usersTest = DataFactory.createUsers(2, Label.Profile_Systeme_Administrateur_Name, false, false, false, true);

    // CREATE ACCOUNTS 
    List<Account> accountsTest = DataFactory.createAccounts(4, 'Adhérent', 'Accepté', true);
        
    System.runAs(usersTest[0]){
        
        Test.startTest();
        // CREATE CONTACT RELATED TO ACCOUNT 
        List<Contact> contactTest = DataFactory.createContacts(1, accountsTest[0].Id, 'Interlocuteur CCH', true);

        // UPDATE CONTACT RELATED ACCOUNT
        contactTest[0].AccountId = accountsTest[1].Id;
        Database.SaveResult result2 = Database.update(contactTest[0], false);

        // DELETE CONTACT 
        Database.delete(contactTest[0], false);
       
        Test.stopTest();
    }    
        
    }
    
}