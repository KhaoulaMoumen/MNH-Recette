@isTest(SeeAllData=false)
public class BA16_ReconductionOffre_Relance1_test {
    
    static testmethod void testReconduction() {
        // --- Test data setup ---
        Date endDate=Date.today().addMonths(2);
        Date beginDate = Date.today().addMonths(-10);
        Integer thisYear = Date.today().year();
        
        // CREATE USER
        List<User> usersTest = DataFactory.createUsers(1, Label.Profile_Systeme_Administrateur_Name, true, true, true, true);
        
        // CREATE CLIENTS
        List<Account> accountsTest = Datafactory.createAccountsClient(1, 'Client', 'Non applicable', true);
        
        list<Contact> cons2 = Datafactory.createContacts(1, accountsTest[0].id, 'Interlocuteur administratif', false);
        cons2[0].Fonction__c = 'Gérant / Directeur Général';
        insert cons2;
        
        // CREATE MANUALLY USER CLIENT = PROBLEME DE SYNCRO FUTURE METHOD
        User userCommunity = new User(
            UserName = 'testRelance@talan.com', 
            FirstName = cons2[0].FirstName,
            LastName = cons2[0].LastName,
            Alias = String.valueof(cons2[0].FirstName.substring(0,1) + cons2[0].LastName.substring(0,1)),
            Email = 'testRelance@talan.com',
            MobilePhone = cons2[0].MobilePhone,
            ContactId = cons2[0].Id,
            ProfileId = System.Label.ESP_Client_Profil_ID,
            EmailEncodingKey = 'UTF-8',
            CommunityNickname = cons2[0].FirstName + '.' + cons2[0].LastName+'TST',
            TimeZoneSidKey = 'Europe/Paris',
            LocaleSidKey = 'fr',
            LanguageLocaleKey = 'fr'
        );
        insert userCommunity;
        
        // CREATE CONVENTIONS ANNUELLES 
        List<Convention_annuelle__c> convAnnuel1 = DataFactory.createConventionsAnnuelles(1, accountsTest[0].Id, endDate.year(), beginDate, endDate, Label.LABS_SF_Contract_OffreId, true);
        convAnnuel1[0].Date_de_reconduction__c = endDate;
        convAnnuel1[0].Reconduction_non_souhaitee__c = false;
        convAnnuel1[0].Date_de_relance__c = Date.today();
        update convAnnuel1;
        
        // --- Testing ---
        Test.startTest();
        
        System.runAs(usersTest[0]){             
            String CRON_EXP2 = '0 0 0 3 9 ? 2022';
            String job2Id = System.schedule('SchedulerTE2', CRON_EXP2, new SchBT12_ScheducleReconductionRelance1());
            CronTrigger ct2 = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :job2Id]; 
            System.assertEquals(0, ct2.TimesTriggered);
        }
        Test.stopTest();
    }
    
}