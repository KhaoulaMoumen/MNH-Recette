/* 

 * Copyright (C) EuraNov -- All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 * Written by Nathan Martin <nathan@euranov.com>, May 2019
 * Edited by Khaoula MOUMEN <khaoula.moumen@talan.com>, June 2020

 */
@isTest
private class DeleteLotTravauxTest {
    static testMethod void testDeleteLotTravaux() {
        
        // --- Test data setup ---
        Date dateDebutTest = Date.newInstance(2018, 2, 17);        
        Date dateFinTest = Date.newInstance(2019, 2, 17);
        Date dateTest = Date.newInstance(2018, 2, 20);

        // CREATE ACCOUNTS
        List<Account> accountsTest = DataFactory.createAccounts(1, 'Adhérent', 'Accepté', true);

        // CREATE LEAD
        List<Lead> leadsTest = DataFactory.createLeads(1, true);

        // CREATE QUALIFICATION
        List<Qualifications__c> qualificationsTest = DataFactory.createQualifications(1, true);

        // CREATE QUALIFICATION PROSPECT ADHERENT
        List<Qualification_prospect_adherent__c> qpaWithProspect = DataFactory.createQualificationsPH(1, NULL, leadsTest[0].Id, dateDebutTest, dateFinTest, true);
        List<Qualification_prospect_adherent__c> qpaWithAdherent = DataFactory.createQualificationsPH(1, accountsTest[0].Id, NULL, dateDebutTest, dateFinTest, true);
        
        // --- Testing ---
        Test.startTest();
        delete qpaWithAdherent[0];
        List<Lots_Travaux__c> resultForLotsTravauxFromAdherents = [SELECT Id FROM Lots_Travaux__c WHERE Qualification_prospect_adh_rent__c=:qpaWithAdherent[0].Id];
        
        delete qpaWithProspect;
        List<Lots_Travaux__c> resultForLotsTravauxFromProspects = [SELECT Id FROM Lots_Travaux__c WHERE Qualification_prospect_adh_rent__c=:qpaWithProspect[0].Id];
        Test.stopTest();
        
        // --- Verify --- 
        System.assert(resultForLotsTravauxFromProspects.isEmpty());
        System.assert(resultForLotsTravauxFromAdherents.isEmpty());
    }
}