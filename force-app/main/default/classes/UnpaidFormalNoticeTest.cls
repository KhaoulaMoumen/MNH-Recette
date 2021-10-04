/* 

* Copyright (C) EuraNov -- All Rights Reserved
* Unauthorized copying of this file, via any medium is strictly prohibited
* Proprietary and confidential
* Written by Nathan Martin <nathan@euranov.com>, July 2019
* Edited by Khaoula MOUMEN <khaoula.moumen@talan.com>, June 2020

*/
@isTest(SeeAllData=false)
private class UnpaidFormalNoticeTest {
    static testMethod void UnpaidFormalNoticeTest() {
        // --- Test data setup ---
        Date dateBefore45Days = Date.today().addDays(-46);
        Date dateBefore30Days = Date.today().addDays(-30);
        Date beginDate = Date.today().addMonths(-6);
        
        // CREATE USER WITH PROFIL SYSTEM ADMINISTRATOR WITH BYPASS PB 'Recrutement - Ajout catalogue de prix par défaut'
        List<User> usersTest = DataFactory.createUsers(1,Label.Profile_Systeme_Administrateur_Name, false, true, false, true);
        
        System.runAs(usersTest[0]){ 
            
      // CREATE ACCOUNTS
     List<Account> accountsTest = DataFactory.createAccounts(3, 'Adhérent', 'Accepté', true);
            
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
 
        // CREATE TASK MISE EN DEMEURE
        List<Task> taskTest1 = DataFactory.createTaches(1, 'Mise en demeure – Motif : impayés', accountsTest[0].Id, usersTest[0].Id, Date.today().addDays(-45), true);
        List<Task> taskTest2 = DataFactory.createTaches(1, 'Mise en demeure – Motif : impayés', accountsTest[1].Id, usersTest[0].Id, Date.today().addDays(-30), true);

             // CREATE COMMANDES FACTURES  
             List<Facture__c> expiredFactureSinceMoreThan45Days = DataFactory.createFActures(1, accountsTest[0].Id, 'Impayée', quotesTest[0].Id, dateBefore45Days, dateBefore45Days, true);
             List<Facture__c> expiredFactureSinceMoreThan30Days = DataFactory.createFActures(1, accountsTest[1].Id, 'Impayée', quotesTest[0].Id, dateBefore30Days, dateBefore30Days, true);

            
            // --- Testing ---
            Test.startTest();
            String CRON_EXP = '0 0 0 3 9 ? 2022';
            // Schedule the test job
            String jobId = System.schedule('SchedulerTE', CRON_EXP, new UnpaidFormalNotice());
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
            
            Account accountOfExpiredFactureSinceMoreThan45Result = [SELECT Id, Name, dernier_niveau_de_relance__c, administrativeStatus__c, relanceDate__c, situation_financiere__c FROM Account WHERE id =:accountsTest[0].id];
            //QuoteLineItem quoteLineItemResult = [SELECT Id, unitPrice FROM QuoteLineItem WHERE id = :quoteLineItem.id];
            System.debug('Compte1.Name :' + accountsTest[0].Name);
            System.debug('expiredFactureSinceMoreThan45Days :' + accountOfExpiredFactureSinceMoreThan45Result);
            System.debug('expiredFactureSinceMoreThan45Days Dernier niveau de relance :' + accountOfExpiredFactureSinceMoreThan45Result.Dernier_niveau_de_relance__c);
            System.debug('expiredFactureSinceMoreThan45Days Date_de_derniere_relance__c :' + accountOfExpiredFactureSinceMoreThan45Result.relanceDate__c);
            // System.debug('quoteLineItem unitPrice :' + quoteLineItemResult.unitPrice);
            // Date expectedDateDeDerniereRelance = Date.today();
            // String expectedSituationFinanciere = 'En impayé';
            // String expectedAdministrativeStatus = 'En attente comité risque';
            // String expectedDernieriveauDeRelance1 = 'Relance niveau 1';
            // System.assertEquals(expectedDernieriveauDeRelance1, accountOfExpiredFactureSinceMoreThan45Result.dernier_niveau_de_relance__c);
            // System.assertEquals(expectedAdministrativeStatus, accountOfExpiredFactureSinceMoreThan45Result.administrativeStatus__c);
            // System.assertEquals(expectedDateDeDerniereRelance, accountOfExpiredFactureSinceMoreThan45Result.relanceDate__c);
            // System.assertEquals(expectedSituationFinanciere, accountOfExpiredFactureSinceMoreThan45Result.situation_financiere__c);
            
            Account accountOfExpiredFactureSinceMoreThan30Result = [SELECT Id, administrativeStatus__c, relanceDate__c, situation_financiere__c FROM Account WHERE Id = :accountsTest[1].id];
            
            Date expectedDateDeDerniereRelance = Date.today();
            String expectedSituationFinanciere = 'En impayé';
            String expectedAdministrativeStatus = 'En attente comité risque';
            //System.assertEquals(expectedAdministrativeStatus, accountOfExpiredFactureSinceMoreThan30Result.administrativeStatus__c);
            //System.assertEquals(expectedDateDeDerniereRelance, accountOfExpiredFactureSinceMoreThan30Result.relanceDate__c);
            //System.assertEquals(expectedSituationFinanciere, accountOfExpiredFactureSinceMoreThan30Result.situation_financiere__c);
        }
    }
}