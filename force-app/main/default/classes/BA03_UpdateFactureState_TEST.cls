/*
TEST CLASS

CreatedBy : MOUMEN Khaoula
@Email : khaoula.moumen@talan.com
CreateDate : 15/05/2020

EditedBy : MOUMEN Khaoula
@Email : khaoula.moumen@talan.com
Date : 05/06/2020

*/
@isTest(SeeAllData=false)
public class BA03_UpdateFactureState_TEST {
    static testMethod void UpdateFactureState() {
        
        Date dateBeforeSevenDays = Date.today().addDays(-7);
        Date dateBeforeFifeteenDays = Date.today().addDays(-15);
        Date beginDate = Date.today().addMonths(-6);
        Date TODAY = Date.today();

        // CREATE USER WITH PROFIL SYSTEM ADMINISTRATOR WITH BYPASS PB 'Recrutement - Ajout catalogue de prix par défaut'
        List<User> usersTest = DataFactory.createUsers(1, Label.Profile_Systeme_Administrateur_Name, false, true, false, true);
        
        System.runAs(usersTest[0]){ 
            
            // CREATE ACCOUNTS
            List<Account> accountsTest = DataFactory.createAccounts(2, 'Adhérent', 'Accepté', true);

            // CREATE ZONES DE CHALANDISE RELATED TO FIRST ACCOUNT
            List<Zone_de_chalandise__c> zonesTest1 = DataFactory.createZonesChalandise(3, accountsTest[0].Id, '75 Paris', true);
            
            // CREATE OPPORTUNITY
            List<Opportunity> opportunitiesTest = DataFactory.createOpportunities(1, accountsTest[0].Id, 'Créé', true);
           

            // GET STANDARD PRICEBOOK
         Id pbId = Test.getStandardPricebookId();

        //CREATE QUOTES FOR EACH OPPORTUNITY
        List<Quote> quotesTest = DataFactory.createQuotes(1, opportunitiesTest[0].Id, pbId, true);
                        
            // CREATE COMMANDES FACTURES  
            List<Facture__c> expiredFactureInSevenDays = DataFactory.createFActures(1, accountsTest[0].Id, 'En attente de paiement', quotesTest[0].Id, dateBeforeSevenDays, dateBeforeSevenDays, true);
            
            expiredFactureInSevenDays[0].Montant_TTC_facture__c=100;
            expiredFactureInSevenDays[0].Montant_TTC_r_gl__c=0;
            update expiredFactureInSevenDays[0];

            List<Facture__c> awaitingFacture = DataFactory.createFActures(1, accountsTest[1].Id, 'Impayée', quotesTest[0].Id, dateBeforeSevenDays, TODAY, true);
            
            awaitingFacture[0].Montant_TTC_facture__c=100;
            awaitingFacture[0].Montant_TTC_r_gl__c=0;
            update awaitingFacture[0];
            
            List<Facture__c> expiredFactureInFifeteenDaysCompte1 = DataFactory.createFActures(1, accountsTest[0].Id, 'Impayée', quotesTest[0].Id, dateBeforeFifeteenDays, dateBeforeFifeteenDays, true);
            
            List<Facture__c> expiredFactureInFifeteenDaysCompte2 = DataFactory.createFActures(1, accountsTest[1].Id, 'Impayée', quotesTest[0].Id, dateBeforeFifeteenDays, dateBeforeFifeteenDays, true);
            
            // --- Testing ---
            Test.startTest();
            String CRON_EXP = '0 0 0 3 9 ? 2022';
            // Schedule the test job
            String jobId = System.schedule('SchedulerTE', CRON_EXP, new SchBT05_UpdateFactureState());
            // Get the information from the CronTrigger API object 
            CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId]; 
            // Verify the expressions are the same System.assertEquals(CRON_EXP, ct.CronExpression); 
            // Verify the job has not run 
            System.assertEquals(0, ct.TimesTriggered); 
            // Verify the next time the job will run 
            System.assertEquals('2022-09-03 00:00:00', String.valueOf(ct.NextFireTime));  
            
            // --- Testing BATCH RDD ---
            String CRON_EXP2 = '0 0 0 3 9 ? 2022';
            // Schedule the test job
            String job2Id = System.schedule('SchedulerTE2', CRON_EXP2, new SchBT_TEST());
            // Get the information from the CronTrigger API object 
            CronTrigger ct2 = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :job2Id]; 
            // Verify the expressions are the same System.assertEquals(CRON_EXP, ct.CronExpression); 
            // Verify the job has not run 
            System.assertEquals(0, ct2.TimesTriggered); 
            // Verify the next time the job will run 
            System.assertEquals('2022-09-03 00:00:00', String.valueOf(ct2.NextFireTime));  
            Test.stopTest();
        }
    }
    }