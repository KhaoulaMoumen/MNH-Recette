/* 

 * Copyright (C) EuraNov -- All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 * Written by Nathan Martin <nathan@euranov.com>, June 2019
 * Edited by Khaoula MOUMEN <khaoula.moumen@talan.com>, June 2020

 */
@isTest(SeeAllData=true)
private class UnpaidClientWarnerTest {
    static testMethod void testUnpaidClientWarner() {
        // --- Test data setup ---
        Date dateBeforeSevenDays = Date.today().addDays(-7);
        Date dateBeforeFifeteenDays = Date.today().addDays(-15);
        Date beginDate = Date.today().addMonths(-6);
        
       // CREATE USER WITH PROFIL SYSTEM ADMINISTRATOR + bypass to PB Recrutement - Ajout catalogue de prix par défaut
        List<User> usersTest = DataFactory.createUsers(1, Label.Profile_Systeme_Administrateur_Name, false, true, false, true);

        System.runAs(usersTest[0]){ 

        // CREATE ACCOUNTS
        List<Account> accountsTest = DataFactory.createAccounts(3, 'Adhérent', 'Accepté', true);

        // CREATE OPPORTUNITIES FOR EACH ACCOUNT
        List<Opportunity> oppsTest1 = DataFactory.createOpportunities(1, accountsTest[0].Id, 'Créé', true);
        List<Opportunity> oppsTest2 = DataFactory.createOpportunities(1, accountsTest[1].Id, 'Créé', true);
        List<Opportunity> oppsTest3 = DataFactory.createOpportunities(1, accountsTest[2].Id, 'Créé', true);

        //oppsTest[0].R_sultat_Comit__c='Accepté';
        //update oppsTest[0];

        //PriceBook2 priceBook2 = [SELECT ID FROM PriceBook2 LIMIT 1];
        //PricebookEntry priceBookEntry = [SELECT ID, Product2Id FROM PricebookEntry WHERE PriceBook2Id=:priceBook2.id LIMIT 1];
        //Quote  myVente = new Quote (Name='Test quote', OpportunityId=op.id, Mode_de_r_glement__c='Virement', Conditions_de_paiement__c='7 jours', PriceBook2Id=priceBook2.Id);
        //Quote  myVente = new Quote (Name='Test quote', OpportunityId=op.id, Mode_de_r_glement__c='Virement', Conditions_de_paiement__c='7 jours', PriceBook2Id=op.priceBook2Id);
        //insert myVente;
        //QuoteLineItem quoteLineItem = new QuoteLineItem(Product2Id=priceBookEntry.Product2Id, unitPrice=1000, Quantity=1, QuoteId=myVente.id, PricebookEntryId=priceBookEntry.id);
        //insert quoteLineItem;

         // GET STANDARD PRICEBOOK
         Id pbId = Test.getStandardPricebookId();

        //CREATE QUOTES FOR EACH OPPORTUNITY
        List<Quote> quotesTest = DataFactory.createQuotes(1, oppsTest1[0].Id, pbId, true);

        
        // CREATE PRODUCTS
        List<Product2> productsTest = DataFactory.createProducts(1, true);

        // CREATE PRICEBOOK ENTRY
        List<PricebookEntry> pbEnteriesTest = DataFactory.createPriceBookEntries(1, pbId, productsTest[0].Id, 100, true);

        // CREATE QUOTE LINE ITEMS
        List<QuoteLineItem> quotesItemsTest = DataFactory.createQuotesLineItems(3, quotesTest[0].Id, pbEnteriesTest[0].Id, 5, 200, true); 

        //QuoteLineItem quoteLineItem = [Select Id from QuoteLineItem where Opportunity.Id =: op.Id LIMIT 1];
        
        
        //Opportunity op = new Opportunity(AccountId=compte1.id, Name='op test', StageName='stage test name', CloseDate=Date.today());
        //insert op;
        //PriceBook2 priceBook2 = [SELECT ID FROM PriceBook2 LIMIT 1];
        //PricebookEntry priceBookEntry = [SELECT ID, Product2Id FROM PricebookEntry WHERE PriceBook2Id=:priceBook2.id LIMIT 1];
        //Quote  myVente = new Quote (Name='Test quote', OpportunityId=op.id, Mode_de_r_glement__c='Virement', Conditions_de_paiement__c='7 jours', PriceBook2Id=priceBook2.Id);
        //insert myVente;
       // QuoteLineItem quoteLineItem = new QuoteLineItem(Product2Id=priceBookEntry.Product2Id, unitPrice=1000, Quantity=1, QuoteId=myVente.id, PricebookEntryId=priceBookEntry.id);
        //insert quoteLineItem;

        // CREATE COMMANDES FACTURES  
        List<Facture__c> expiredFactureInSevenDays = DataFactory.createFActures(1, accountsTest[0].Id, 'Impayée', quotesTest[0].Id, dateBeforeSevenDays, dateBeforeSevenDays, true);
        List<Facture__c> expiredFactureInFifeteenDays = DataFactory.createFActures(1, accountsTest[0].Id, 'Impayée', quotesTest[0].Id, dateBeforeFifeteenDays, dateBeforeFifeteenDays, true);
        List<Facture__c> expiredFactureInFifeteenDaysDuplicateCompte1 = DataFactory.createFActures(1, accountsTest[1].Id, 'Impayée', quotesTest[0].Id, dateBeforeFifeteenDays, dateBeforeFifeteenDays, true);
        List<Facture__c> expiredFactureInFifeteenDaysDuplicateCompte2 = DataFactory.createFActures(1, accountsTest[1].Id, 'Impayée', quotesTest[0].Id, dateBeforeFifeteenDays, dateBeforeFifeteenDays, true);

        // --- Testing ---
        Test.startTest();
        String CRON_EXP = '0 0 0 3 9 ? 2022';
        // Schedule the test job
        String jobId = System.schedule('SchedulerTE', CRON_EXP, new UnpaidClientWarner());
        // Get the information from the CronTrigger API object 
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId]; 
        // Verify the expressions are the same System.assertEquals(CRON_EXP, ct.CronExpression); 
        // Verify the job has not run 
        System.assertEquals(0, ct.TimesTriggered); 
        // Verify the next time the job will run 
        System.assertEquals('2022-09-03 00:00:00', String.valueOf(ct.NextFireTime));  
        Test.stopTest();

        // --- Verify ---
        // Now that the scheduled job has executed after Test.stopTest(),
        Account accountOfExpiredFactureInSevenDaysResult = [SELECT Id, dernier_niveau_de_relance__c, relanceDate__c, situation_financiere__c FROM Account WHERE id =:accountsTest[0].id];
        //QuoteLineItem quoteLineItemResult = [SELECT Id, unitPrice FROM QuoteLineItem WHERE id = :quoteLineItem.id];
        System.debug('Compte1.id :' + accountsTest[0].id);
        System.debug('expiredFactureInSevenDays :' + accountOfExpiredFactureInSevenDaysResult);
        System.debug('expiredFactureInSevenDaysResult Dernier niveau de relance :' + accountOfExpiredFactureInSevenDaysResult.Dernier_niveau_de_relance__c);
        System.debug('expiredFactureInSevenDaysResult Date_de_derniere_relance__c :' + accountOfExpiredFactureInSevenDaysResult.relanceDate__c);
        //System.debug('quoteLineItem unitPrice :' + quoteLineItemResult.unitPrice);
        Date expectedDateDeDerniereRelance = Date.today();
        String expectedSituationFinanciere = 'En impayé';
        String expectedDernieriveauDeRelance1 = 'Relance niveau 1';
        //System.assertEquals(expectedDernieriveauDeRelance1, accountOfExpiredFactureInSevenDaysResult.dernier_niveau_de_relance__c);
        //System.assertEquals(expectedDateDeDerniereRelance, accountOfExpiredFactureInSevenDaysResult.relanceDate__c);
        //System.assertEquals(expectedSituationFinanciere, accountOfExpiredFactureInSevenDaysResult.situation_financiere__c);
        
        Account accountExpiredFactureInFifeteenDaysResult = [SELECT Id, dernier_niveau_de_relance__c, relanceDate__c, situation_financiere__c FROM Account WHERE Id = :accountsTest[1].id];
        String expectedDernieriveauDeRelance2 = 'Relance niveau 2';
        //System.assertEquals(expectedDernieriveauDeRelance2, accountExpiredFactureInFifeteenDaysResult.dernier_niveau_de_relance__c);
        //System.assertEquals(expectedDateDeDerniereRelance, accountExpiredFactureInFifeteenDaysResult.relanceDate__c);
        //System.assertEquals(expectedSituationFinanciere, accountExpiredFactureInFifeteenDaysResult.situation_financiere__c);
            //
        }
    }
}