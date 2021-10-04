/* 

* Copyright (C) EuraNov -- All Rights Reserved
* Unauthorized copying of this file, via any medium is strictly prohibited
* Proprietary and confidential
* Written by Catherine DELEGLISE <catherine@euranov.com>, July 2019
 * Edited by Khaoula MOUMEN <khaoula.moumen@talan.com>, June 2020

*/

@isTest(SeeAllData=false)
global class SendToDocusignControllerTest {
    static testMethod void testNewClass() {

        // CREATE USER WITH PROFIL SYSTEM ADMINISTRATOR = OWNER With bypass on pb to bypass process builder creation tache mise en demeure (probleme recurrent de post chatter dans le pb sur les sbx)
        List<User> usersTest = DataFactory.createUsers(1, Label.Profile_Systeme_Administrateur_Name, false, true, false, true);

        System.runAs(usersTest[0]){

        // CREATE ACCOUNTS
        List<Account> accountsTest = DataFactory.createAccounts(1, 'Adhérent', 'Accepté', true);

        // CREATE CONTACTS
        List<Contact> contactsTest = DataFactory.createContacts(1, accountsTest[0].Id, 'Interlocuteur administratif', true);

        // CREATE OPPORTUNITIES
        List<Opportunity> oppsTest = DataFactory.createOpportunities(2, accountsTest[0].Id, 'Créé', true);
    
        // CREATE CONTENT VERSION
        List<ContentVersion> CvTest = DataFactory.createContentVersion(2, true);

        ContentVersion contentVersion_1 = [SELECT Id, Title, ContentDocumentId FROM ContentVersion WHERE Id = :CvTest[0].Id LIMIT 1];
        ContentVersion contentVersion_2 = [SELECT Id, Title, ContentDocumentId FROM ContentVersion WHERE Id = :CvTest[1].Id LIMIT 1];
        
        // CREATE CONTENT DOCUMENT LINKS
        List<ContentDocumentLink> cdlTest1 = DataFactory.createContentDocLinks(1, contentVersion_1, oppsTest[0].Id, true);
        List<ContentDocumentLink> cdlTest2 = DataFactory.createContentDocLinks(1, contentVersion_2, oppsTest[1].Id, true);

        Test.startTest();
        // load the page       
        ApexPages.StandardSetController controller = new ApexPages.StandardSetController(oppsTest);
        controller.setSelected(oppsTest);
        SendtoDocusignController extension = new SendtoDocusignController(controller);
        extension.SendDataToDocusign();
        extension.Prev();
        
    }
    
}
}