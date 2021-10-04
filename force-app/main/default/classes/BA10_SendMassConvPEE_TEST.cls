@isTest(SeeAllData=false)
public class BA10_SendMassConvPEE_TEST {

    static testMethod void testBA05Class(){
        
        List<User> usersTest = DataFactory.createUsers(1, Label.Profile_Systeme_Administrateur_Name, true, true, true, true);
        
        System.runAs(usersTest[0]){
            
            // CREATE ACCOUNTS
            List<Account> accountsTest = DataFactory.createAccounts(1, 'Adhérent', 'Accepté', true);
            
            // CREATE CONTACTS
            List<Contact> contactsTest = DataFactory.createContacts(1, accountsTest[0].Id, 'Interlocuteur administratif', true);
            contactsTest[0].Fonction__c ='Gérant / Directeur Général';
            update contactsTest[0];
            
            // CREATE OFFRES PSH
      		List<Offre_PSH__c> offresPSHTest1 = DataFactory.createOffresPSH(2, accountsTest[0].Id, '2021', 'Offre PEE', Date.Today().addMonths(1), true);
            for(Offre_PSH__c offre : offresPSHTest1) offre.TECH_Envoi_en_masse__c = true;
            update offresPSHTest1;
            
            // CREATE CONTENT VERSION
            List<ContentVersion> CvTest = DataFactory.createContentVersion(2, true);
            
            ContentVersion contentVersion_1 = [SELECT Id, Title, ContentDocumentId FROM ContentVersion WHERE Id = :CvTest[0].Id LIMIT 1];
            ContentVersion contentVersion_2 = [SELECT Id, Title, ContentDocumentId FROM ContentVersion WHERE Id = :CvTest[1].Id LIMIT 1];
            
            // CREATE CONTENT DOCUMENT LINKS
            List<ContentDocumentLink> cdlTest1 = DataFactory.createContentDocLinks(1, contentVersion_1, offresPSHTest1[0].Id, true);
            List<ContentDocumentLink> cdlTest2 = DataFactory.createContentDocLinks(1, contentVersion_2, offresPSHTest1[1].Id, true);
            
            dsfs__DocuSign_Envelope__c env = new dsfs__DocuSign_Envelope__c(dsfs__DocuSign_Email_Subject__c='test');
            
            Test.startTest();
            BA10_SendMassConvPEE obj = new BA10_SendMassConvPEE();
            Id batchJobId = DataBase.executeBatch(obj,10); 
            
            LNC12_EnvoiConventionEnMasseController.getBatchJobStatus(batchJobId) ; 
            LNC12_EnvoiConventionEnMasseController.executeBatchJob2();
                        
            Test.stopTest();
        
        }
    }
    
}