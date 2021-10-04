/*
* Edited by Khaoula MOUMEN <khaoula.moumen@talan.com>, June 2020
*/
@isTest(SeeAllData=false)
global class SendToDocuSignOffrePSHController_Test {
    static testMethod void testNewClass() {

        // CREATE USER WITH PROFIL SYSTEM ADMINISTRATOR = OWNER With bypass on pb to bypass process builder creation tache mise en demeure (probleme recurrent de post chatter dans le pb sur les sbx)
        List<User> usersTest = DataFactory.createUsers(1, Label.Profile_Systeme_Administrateur_Name, false, true, false, true);

        // CREATE ACCOUNTS
        List<Account> accountsTest = DataFactory.createAccounts(1, 'Adhérent', 'Accepté', true);
        
        accountsTest[0].Ownership = usersTest[0].Id;
        update accountsTest[0];

        // CREATE CONTACTS
        List<Contact> contactsTest = DataFactory.createContacts(1, accountsTest[0].Id, 'Interlocuteur administratif', true);

        // CREATE OFFRES PSH
        List<Offre_PSH__c> offresPSHTest1 = DataFactory.createOffresPSH(1, accountsTest[0].Id, '2019', Date.Today().addMonths(1), true);
        List<Offre_PSH__c> offresPSHTest2 = DataFactory.createOffresPSH(1, accountsTest[0].Id, '2021', Date.Today().addMonths(1), true);
   
        List<Offre_PSH__c> offres = new List<Offre_PSH__c>();
        offres.add(offresPSHTest1[0]);
        offres.add(offresPSHTest2[0]);

        // CREATE CONTENT VERSION
        List<ContentVersion> CvTest = DataFactory.createContentVersion(2, true);

        ContentVersion contentVersion_1 = [SELECT Id, Title, ContentDocumentId FROM ContentVersion WHERE Id = :CvTest[0].Id LIMIT 1];
        ContentVersion contentVersion_2 = [SELECT Id, Title, ContentDocumentId FROM ContentVersion WHERE Id = :CvTest[1].Id LIMIT 1];
        
        // CREATE CONTENT DOCUMENT LINKS
        List<ContentDocumentLink> cdlTest1 = DataFactory.createContentDocLinks(1, contentVersion_1, offresPSHTest1[0].Id, true);
        List<ContentDocumentLink> cdlTest2 = DataFactory.createContentDocLinks(1, contentVersion_2, offresPSHTest2[0].Id, true);
        
        Test.startTest();
        // load the page       
        ApexPages.StandardSetController controller = new ApexPages.StandardSetController(offres);
        controller.setSelected(offres);
        SendToDocuSignOffrePSHController extension = new SendToDocuSignOffrePSHController(controller);
        extension.SendDataToDocusign();
        extension.Prev();        
    }  
}