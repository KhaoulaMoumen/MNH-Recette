@isTest(seeAllData = false)
public class BA17_ReconductionOffre_Relance2_Test {
    
    static testmethod void testReconduction() {
        // --- Test data setup ---
        Date endDate=Date.today().addMonths(1);
        Date beginDate = Date.today().addMonths(-11);
        Integer thisYear = Date.today().year();
        
        // CREATE USER
        List<User> usersTest = DataFactory.createUsers(1, Label.Profile_Systeme_Administrateur_Name, true, true, true, true);
        
        // CREATE CLIENTS
        List<Account> accountsTest = Datafactory.createAccountsClient(1, 'Client', 'Non applicable', true);
        accountsTest[0].Categorie_de_metier__c = 'Hors secteur du bâtiment';
        accountsTest[0].OwnerId = UserInfo.getUserId();
        update accountsTest[0];
        
        
        // CREATE CONVENTIONS ANNUELLES 
        List<Convention_annuelle__c> convAnnuel1 = DataFactory.createConventionsAnnuelles(1, accountsTest[0].Id, endDate.year(), beginDate, endDate, Label.LABS_SF_Contract_OffreId, true);
        convAnnuel1[0].Date_de_reconduction__c = endDate;
        convAnnuel1[0].Reconduction_non_souhaitee__c = false;
        update convAnnuel1;
        
        // --- Testing ---
        Test.startTest();
        
        System.runAs(usersTest[0]){ 
            String CRON_EXP2 = '0 0 0 3 9 ? 2022';
            String job2Id = System.schedule('SchedulerTE2', CRON_EXP2, new SchBT11_ScheducleReconductionRelance2());
            CronTrigger ct2 = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :job2Id]; 
            System.assertEquals(0, ct2.TimesTriggered);
            Test.stopTest();
        }
    }
    
}