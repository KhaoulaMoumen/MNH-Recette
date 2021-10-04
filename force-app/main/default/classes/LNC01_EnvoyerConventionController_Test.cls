@isTest(SeeAllData=false)
public class LNC01_EnvoyerConventionController_Test {
    
    static testMethod void testBA05Class() {

        List<User> usersTest = DataFactory.createUsers(1, Label.Profile_Systeme_Administrateur_Name, false, true, false, true);
        
        System.runAs(usersTest[0]){
            
            // CREATE ACCOUNTS
            List<Account> accountsTest = DataFactory.createAccounts(1, 'Adhérent', 'Accepté', true);
            
            // CREATE CONTACTS
            List<Contact> contactsTest = DataFactory.createContacts(1, accountsTest[0].Id, 'Interlocuteur administratif', true);
            contactsTest[0].Fonction__c ='Gérant / Directeur Général';
            update contactsTest[0];
            
            // CREATE OPPORTUNITIES
            List<Opportunity> oppsTest = DataFactory.createOpportunities(2, accountsTest[0].Id, 'Créé', true);
            
                       
            Test.startTest();
                        
            Opportunity oppTest = LNC01_EnvoyerConventionController.getOppDetails(oppsTest[0].Id);
			String path = LNC01_EnvoyerConventionController.getDocusignUrl(oppTest.Id, Label.LABS_SF_CRL_Attribute_for_Docusign, 'Signataire~Signataire;Synerciel~Synerciel' , 'Signataire~Signer;Synerciel~Signer', '0' , '1');
            
            Test.stopTest();
    
        }
    }
}