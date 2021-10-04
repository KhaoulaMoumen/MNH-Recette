/* 

 * Copyright (C) EuraNov -- All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 * Written by Catherine DELEGLISE <catherine@euranov.com>, July 2019
 * Edited by Khaoula MOUMEN <khaoula.moumen@talan.com>, June 2020

 */

@isTest
private class EUR12_MetierReferenceTriggerTest {
    static testmethod void testMetierReferenceTrigger(){

    // CREATE ACCOUNTS
    List<Account> accountsTest = DataFactory.createAccounts(1, 'Adhérent', 'Accepté', true);

    // CREATE LEADS
    List<Lead> leadsTest = DataFactory.createLeads(1, true);


    Test.startTest();

    // CREATE METIERS DE REFERENCE ACCESSIBILITE RELATED TO ACCOUNT - PRINCIPAL
    List<Metier_de_reference__c> metierRefTest1 = DataFactory.createMetiersRef(1, accountsTest[0].Id, NULL, 'Accessibilité', true,  true);

    // CATCH EXCEPTION - Il existe déjà un métier de référence principal
    try{
        // INSERT AN ANOTHER METIERS DE REFERENCE CLIMATICIEN RELATED TO ACCOUNT - PRINCIPAL
        List<Metier_de_reference__c> metierRefTest2 = DataFactory.createMetiersRef(1, accountsTest[0].Id, NULL, 'Climaticien', true,  true); 
    }
    catch(Exception e)
    {
        Boolean expectedExceptionThrown =  e.getMessage().contains('Il existe déjà un métier de référence principal') ? true : false;
        System.AssertEquals(expectedExceptionThrown, true);
    } 

    // CREATE METIERS DE REFERENCE ACCESSIBILITE RELATED TO LEAD - PRINCIPAL
    List<Metier_de_reference__c> metierRefTest3 = DataFactory.createMetiersRef(1, NULL, leadsTest[0].Id, 'Accessibilité', true,  true);
   
    // CATCH EXCEPTION - Il existe déjà un métier de référence principal
    try{
        // INSERT AN ANOTHER METIERS DE REFERENCE CLIMATICIEN RELATED TO LEAD - PRINCIPAL
        List<Metier_de_reference__c> metierRefTest4 = DataFactory.createMetiersRef(1, NULL, leadsTest[0].Id, 'Climaticien', true,  true);  
    }
    catch(Exception e)
    {
        Boolean expectedExceptionThrown =  e.getMessage().contains('Il existe déjà un métier de référence principal') ? true : false;
        System.AssertEquals(expectedExceptionThrown, true);
    } 
        Test.stopTest();
    }
}