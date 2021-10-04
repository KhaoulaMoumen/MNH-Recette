/* 

 * Copyright (C) EuraNov -- All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 * Written by Nathan Martin <nathan@euranov.com>, June 2019

EditedBy : MOUMEN Khaoula
@Email : khaoula.moumen@talan.com
Date : 08/06/2020

 */
@isTest
private class BatchAndTriggerAssurQualifUnpaidTest {
    static testMethod void testExpiredAssuranceWarner() {
        // --- Test data setup ---
        Date dateBeforeOneMonth = Date.today().addMonths(+1);
        Date dateAfterOneDay = Date.today().addDays(-1);
        Date dateAfterSevenDays = Date.today().addDays(-7);
        Date beginDate = Date.today().addMonths(-6);
                    
            // CREATE ACCOUNTS
            List<Account> accountsTest = DataFactory.createAccounts(4, 'Adhérent', 'Accepté', true);

            // CREATE ASSURANCES
            List<Assurance__c> assurancesTest = DataFactory.createAssurances(2, 'Autorisée', true);

            // CREATE ASSURANCES PROSPECT ADHERENT
            List<Assurances__c> expiredAssuranceInOneMonth = DataFactory.createAssurancesPH(1, assurancesTest[0].Id, accountsTest[0].Id, NULL, beginDate, dateBeforeOneMonth, 'Responsabilité civile', true);
            List<Assurances__c> expiredAssuranceForOneDay = DataFactory.createAssurancesPH(1, assurancesTest[0].Id, accountsTest[1].Id, NULL, beginDate, dateAfterOneDay, 'Responsabilité civile', true);
            List<Assurances__c> expiredAssuranceForSevenDays = DataFactory.createAssurancesPH(1, assurancesTest[0].Id, accountsTest[2].Id, NULL, beginDate, dateAfterSevenDays, 'Responsabilité civile', true);
            List<Assurances__c> expiredDuplicateAssurance1 = DataFactory.createAssurancesPH(1, assurancesTest[1].Id, accountsTest[3].Id, NULL, beginDate, dateAfterSevenDays, 'Responsabilité civile', true);
            List<Assurances__c> expiredDuplicateAssurance2 = DataFactory.createAssurancesPH(1, assurancesTest[1].Id, accountsTest[3].Id, NULL, beginDate, dateAfterSevenDays, 'Responsabilité civile', true);
         
            // --- Testing ---
            Test.startTest();

// todo : test territory

        // Id ACCOUNT_BROKER_RECORDTYPE = [Select Id, DeveloperName from RecordType where sObjectType='Account' LIMIT 1].Id;
        // Account objAccount = new Account(RecordTypeId = ACCOUNT_BROKER_RECORDTYPE, Name = 'Test Acc - 01', ShippingState = 'USA');
        // insert objAccount;
        // insertTestTerritory(objAccount.Id);

        String CRON_EXP = '0 0 0 3 9 ? 2022';
        // Schedule the test job
        String jobId = System.schedule('SchedulerTE', CRON_EXP, new ExpiredAssuranceWarner());
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
        Assurances__c expiredAssuranceInOneMonthResult = [SELECT Id, Dernier_niveau_de_relance__c, Date_de_derniere_relance__c FROM Assurances__c WHERE Id = :expiredAssuranceInOneMonth[0].Id];
        System.debug('expiredAssuranceInOneMonthResult :' + expiredAssuranceInOneMonthResult);
        System.debug('expiredAssuranceInOneMonthResult Dernier niveau de relance :' + expiredAssuranceInOneMonthResult.Dernier_niveau_de_relance__c);
        System.debug('expiredAssuranceInOneMonthResult Date_de_derniere_relance__c :' + expiredAssuranceInOneMonthResult.Date_de_derniere_relance__c);
        String expectedDernieriveauDeRelance = 'Relance préventive';
        Date expectedDateDeDerniereRelance = Date.today();
        //System.assertEquals(expectedDernieriveauDeRelance, expiredAssuranceInOneMonthResult.Dernier_niveau_de_relance__c);
        //System.assertEquals(expectedDateDeDerniereRelance, expiredAssuranceInOneMonthResult.Date_de_derniere_relance__c);
        
        Assurances__c expiredAssuranceForOneDayResult = [SELECT Id, Dernier_niveau_de_relance__c, Date_de_derniere_relance__c FROM Assurances__c WHERE Id = :expiredAssuranceForOneDay[0].Id];
        String expectedDernieriveauDeRelance2 = 'Relance niveau 1';
        Date expectedDateDeDerniereRelance2 = Date.today();
        //System.assertEquals(expectedDernieriveauDeRelance2, expiredAssuranceForOneDayResult.Dernier_niveau_de_relance__c);
        //System.assertEquals(expectedDateDeDerniereRelance2, expiredAssuranceForOneDayResult.Date_de_derniere_relance__c);

        Assurances__c expiredAssuranceForSevenDaysResult = [SELECT Id, Dernier_niveau_de_relance__c, Date_de_derniere_relance__c FROM Assurances__c WHERE Id = :expiredAssuranceForSevenDays[0].Id];
        String expectedDernieriveauDeRelance3 = 'Relance niveau 2';
        Date expectedDateDeDerniereRelance3 = Date.today();
        //System.assertEquals(expectedDernieriveauDeRelance3, expiredAssuranceForSevenDaysResult.Dernier_niveau_de_relance__c);
        //System.assertEquals(expectedDateDeDerniereRelance3, expiredAssuranceForSevenDaysResult.Date_de_derniere_relance__c);

// todo : test territory
        // UserTerritory2Association TerritoryUsers = [SELECT UserId, User.Name, User.Email, RoleInTerritory2, User.FirstName, User.LastName FROM UserTerritory2Association WHERE RoleInTerritory2='Assistant(e) Commercial(e)'];
        // String expectedRSRole = 'Responsable de Secteur';
        // String expectedAsscoRole = 'Assistant(e) Commercial(e)';
        // System.assertEquals(expectedRSRole, TerritoryUsers.RoleInTerritory2);
        // System.assertEquals(expectedAsscoRole, TerritoryUsers.RoleInTerritory2);
    }

// todo : test territory
    // @future
    // private static void insertTestTerritory(Id AccId)
    // {
    //     List<Territory2Type> terriType   = [SELECT id, DeveloperName from Territory2Type LIMIT 1];
    //     List<Profile> adminProfile = [select id, name from Profile where  name = 'System Administrator'];

    //     Territory2Model terrModel = new Territory2Model();
    //     terrModel .DeveloperName='ModelName'; // required field
    //     terrModel.Name = 'Name'; // required field
    //     insert terrModel ;

    //     Territory2 objTerr = new Territory2(DeveloperName = 'TestTerritory', Territory2ModelId=terrModel.Id, Name='TestTerritory', Territory2TypeId=terriType[0].Id);
    //     insert objTerr;

    //     ObjectTerritory2Association objObjectTerritory2Association = new ObjectTerritory2Association(ObjectId = AccId, Territory2Id =objTerr.Id, AssociationCause='Territory2Manual' );
    //     insert objObjectTerritory2Association;

    //     UserTerritory2Association Assco = new UserTerritory2Association(RoleInTerritory2='Assistant(e) Commercial(e)', Territory2Id=objObjectTerritory2Association.id);
    //     UserTerritory2Association RS = new UserTerritory2Association(RoleInTerritory2='Responsable de Secteur', Territory2Id=objObjectTerritory2Association.id);
    //     insert objObjectTerritory2Association;
    //     insert Assco;
    //     insert RS;
    // }
    
}