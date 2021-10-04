@isTest(SeeAllData=false)
global class LNC13_GeneratePEE_TEST {

     static testMethod void testNewClass() {

        // CREATE USER WITH PROFIL SYSTEM ADMINISTRATOR = OWNER With bypass on pb to bypass process builder creation tache mise en demeure (probleme recurrent de post chatter dans le pb sur les sbx)
        List<User> usersTest = DataFactory.createUsers(1, Label.Profile_Systeme_Administrateur_Name, true, true, true, true);

          System.runAs(usersTest[0]) {
        // CREATE ACCOUNTS
        List<Account> accountsTest = DataFactory.createAccounts(1, 'Adhérent', 'Accepté', true);
        
        accountsTest[0].Ownership = usersTest[0].Id;
        update accountsTest[0];

        // CREATE CONTACTS
        List<Contact> contactsTest = DataFactory.createContacts(1, accountsTest[0].Id, 'Interlocuteur administratif', true);

        // CREATE OFFRES PSH
        List<Offre_PSH__c> offresPSHTest1 = DataFactory.createOffresPSH(1, accountsTest[0].Id, '2021', 'Offre PEE', Date.Today().addMonths(1), true);
        List<Offre_PSH__c> offresPSHTest2 = DataFactory.createOffresPSH(1, accountsTest[0].Id, '2020', 'Offre PEE', Date.Today().addMonths(1), true);
   
        List<Offre_PSH__c> offres = new List<Offre_PSH__c>();
        offres.add(offresPSHTest1[0]);
        offres.add(offresPSHTest2[0]);
         
         LNC13_GenerateContractPEE_Controller.getOffreDetails(offresPSHTest1[0].Id);
         LNC13_GenerateContractPEE_Controller.generateContract(offresPSHTest1[0].Id, 'Contrat Membre M1 Mandat PEE 2020');
          }
     }
}