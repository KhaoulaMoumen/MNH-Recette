/* 

* Copyright (C) EuraNov -- All Rights Reserved
* Unauthorized copying of this file, via any medium is strictly prohibited
* Proprietary and confidential
* Written by Nathan Martin <nathan@euranov.com>, June 2019

*/
@isTest(SeeAllData=true)
private class UnpaidFormalNoticeTriggeredTest {
    static testMethod void UnpaidFormalNoticeTriggeredTest() {
        // --- Test data setup ---
        Date dateBefore20Days = Date.today().addDays(-20);
        Date dateBefore20Days2 = Date.today().addDays(-20);
        Date beginDate = Date.today().addMonths(-6);
        
        // CREATE USER WITH PROFIL SYSTEM ADMINISTRATOR WITH BYPASS PB 'Recrutement - Ajout catalogue de prix par défaut'
        List<User> usersTest = DataFactory.createUsers(1, Label.Profile_Systeme_Administrateur_Name, false, true, false, true);
        
        System.runAs(usersTest[0]){
            
            
            // CREATE ACCOUNTS
            List<Account> accountsTest = DataFactory.createAccounts(2, 'Adhérent', 'Accepté', true);
            
            // CREATE OPPORTUNITIES FOR EACH ACCOUNT
            List<Opportunity> oppsTest = DataFactory.createOpportunities(1, accountsTest[0].Id, 'Créé', true);
            // GET STANDARD PRICEBOOK
            Id pbId = Test.getStandardPricebookId();
            
            //CREATE QUOTES FOR EACH OPPORTUNITY
            List<Quote> quotesTest = DataFactory.createQuotes(1, oppsTest[0].Id, pbId, true);
            
            // CREATE PRODUCTS
            List<Product2> productsTest = DataFactory.createProducts(1, true);
            
            // CREATE PRICEBOOK ENTRY
            List<PricebookEntry> pbEnteriesTest = DataFactory.createPriceBookEntries(1, pbId, productsTest[0].Id, 100, true);
            
            // CREATE QUOTE LINE ITEMS
            List<QuoteLineItem> quotesItemsTest = DataFactory.createQuotesLineItems(3, quotesTest[0].Id, pbEnteriesTest[0].Id, 1, 1000, true); 

             // CREATE COMMANDES FACTURES  
             List<Facture__c> expiredFactureSinceMoreThan20Days = DataFactory.createFActures(1, accountsTest[0].Id, 'Impayée', quotesTest[0].Id, beginDate, dateBefore20Days, true);
             List<Facture__c> expiredFactureSinceMoreThan20Days2 = DataFactory.createFActures(1, accountsTest[1].Id, 'Impayée', quotesTest[0].Id, beginDate, dateBefore20Days, true);

		// CREATE TASK MISE EN DEMEURE
        List<Task> task1 = DataFactory.createTaches(1, 'Mise en demeure – Motif : impayés', accountsTest[0].Id, usersTest[0].Id, Date.today(), true);
        List<Task> task2 = DataFactory.createTaches(1, 'Mise en demeure – Motif : impayés', accountsTest[1].Id, usersTest[0].Id, Date.today(), true);

            
            // --- Testing ---
            Test.startTest();
            Task task1ToUpdate = [SELECT Id FROM Task WHERE Id = :task1[0].id];
            Task task2ToUpdate = [SELECT Id FROM Task WHERE Id = :task2[0].id];
            task1[0].Status = 'Confirmer';            
            task2[0].Status = 'Confirmer';            
            update task1[0];
            update task2[0];
            Test.stopTest();
        }
    }
}