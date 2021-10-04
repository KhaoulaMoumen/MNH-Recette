@isTest
public class CTRL08_listViewController_test {
    @testSetup 
    static void setup() {
        Network n = [select id from network where name like 'My Synerciel'];
        list<Account> accs = Datafactory.createAccounts(1, 'Adhérent', 'Accepté', true);
        list<Contact> cons =Datafactory.createContacts(1, accs[0].id, 'Interlocuteur administratif', true);
        list<User> myusers = Datafactory.createUsers(1,'Adhérent',false,false,false,false);
        myusers[0].username='testCollaborationMember@test.com';
        myusers[0].contactid=cons[0].id;
        insert myusers[0];
        CollaborationGroup g = new CollaborationGroup(Name='grpName', CollaborationType='Public',networkid=n.id);
        insert g;
        CollaborationGroupMember gm=new CollaborationGroupMember();
        gm.collaborationGroupId=g.id;
        gm.memberId=myusers[0].Id;
        insert gm;

    }
    
    static testmethod void test() {
        Test.startTest();
        User u =[select username from user where username like 'testCollaborationMember@test.com' ]     ;  
        
        CTRL08_listViewController.getGroups(u.username);
        Test.stopTest();
        
        }


}