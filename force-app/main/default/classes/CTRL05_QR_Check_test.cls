@isTest
public class CTRL05_QR_Check_test {
    
    static testmethod void test() {
        Test.startTest();
        list<Account> accs =DataFactory.createAccounts(1,'Adhérent', 'Accepté', false);
        accs[0].sirenSiret__c='79165704200010';
        accs[0].Profil__c = 'Adhérent';
        insert accs[0];
        Test.setCurrentPage(Page.VF11_QR_Checking);
        ApexPages.currentPage().getParameters().put('Siret', '79165704200010');
        list<Contact> cons =Datafactory.createContacts(1, accs[0].id, 'Interlocuteur administratif', true);
        list<User> myusers = Datafactory.createUsers(1,'Adhérent',false,false,false,false);
        myusers[0].contactid=cons[0].id;
        insert myusers[0];
        CTRL05_QR_Check cont = new CTRL05_QR_Check();
        Test.stopTest();
        system.assertequals(cont.isActiveUser,true);
        
        }

}