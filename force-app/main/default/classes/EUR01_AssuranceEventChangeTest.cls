/* 

* Copyright (C) EuraNov -- All Rights Reserved
* Unauthorized copying of this file, via any medium is strictly prohibited
* Proprietary and confidential
* Written by Paul Mantez <paul@euranov.com>, July 2019
 * Edited by Khaoula MOUMEN <khaoula.moumen@talan.com>, June 2020

*/
@isTest
private class EUR01_AssuranceEventChangeTest {
    
    static testMethod void EUR01_AssuranceEventChangeTest() {

        // CREATE ACCOUNTS
        List<Account> accountsTest = DataFactory.createAccounts(1, 'Adhérent', 'Accepté', true);

        // CREATE CONTACTS
        List<Contact> contactsTest1 = DataFactory.createContacts(1, accountsTest[0].Id, 'Interlocuteur administratif', true);
       
        // CREATE CONVENTIONS ANNUELLES
        List<Convention_annuelle__c> convAnnuel1 = DataFactory.createConventionsAnnuelles(1, accountsTest[0].Id, 2019, Date.newInstance(2019,01,01), Date.newInstance(2019,12,22), Label.Contract_Pack_RecordTypeId, true);
     
        // CREATE ASSURANCES
        List<Assurance__c> assuranceToleree = DataFactory.createAssurances(1, 'Autorisée', true);
        List<Assurance__c> assuranceInterdite = DataFactory.createAssurances(1, 'Autorisée', true);
        
        // CREATE ASSURANCES PROSPECT ADHERENT
        List<Assurances__c> assurancesToleree = DataFactory.createAssurancesPH(1, assuranceToleree[0].Id, accountsTest[0].Id, NULL, Date.today().addMonths(-6), Date.today().addMonths(9), 'Responsabilité civile', true);
        List<Assurances__c> assurancesInterdite = DataFactory.createAssurancesPH(1, assuranceInterdite[0].Id, accountsTest[0].Id, NULL, Date.today().addMonths(-6), Date.today().addMonths(9), 'Responsabilité civile', true);
   
    
        Test.startTest();
        
        // UPDATE THE STATUS OF ASSURANCE TO TOLEREE
        assuranceToleree[0].Statut_Assurance__c='Tolérée';
        update assuranceToleree[0];
        
        // UPDATE THE STATUS OF ASSURANCE TO INTERDIRE
        assuranceInterdite[0].Statut_Assurance__c='Interdite';
        update assuranceInterdite[0];
        
        Test.stopTest();
        
        Account AccountVerify = [SELECT Id, Name, Type, email__c FROM Account WHERE Id = :accountsTest[0].Id];
        System.debug('AccountVerify :' + AccountVerify);
        
        Assurance__c AssuranceVerify = [SELECT Id, Name FROM Assurance__c WHERE Id = :assuranceToleree[0].Id];
        System.debug('AssuranceVerify 1:' + AssuranceVerify);
        
        Assurances__c AssurancesVerify = [SELECT ID, Assurance__r.Name, Date_de_debut__c, Date_de_fin__c, Compte__c, Compte__r.Type, Compte__r.email__c FROM Assurances__c WHERE Id = :assurancesToleree[0].Id];
        System.debug('AssurancesVerify 2:' + AssurancesVerify);
    }
}