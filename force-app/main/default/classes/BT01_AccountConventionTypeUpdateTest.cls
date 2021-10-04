/*
EditedBy : MOUMEN Khaoula
@Email : khaoula.moumen@talan.com
Date : 08/06/2020
 */
@isTest(seeAllData=false)
public class BT01_AccountConventionTypeUpdateTest {
    @isTest
    static void testAccountConventionTypeUpdate() {
        
        // CREATE USER WITH PROFIL SYSTEM ADMINISTRATOR
        List<User> usersTest = DataFactory.createUsers(1, Label.Profile_Systeme_Administrateur_Name, true, true, false, true);
        
        System.runAs(usersTest[0]){

            Test.startTest();

        // CREATE ACCOUNTS
        List<Account> accountsTest = DataFactory.createAccounts(4, 'Adhérent', 'Accepté', true); 
        accountsTest[0].Ownership = 'COOP';
        accountsTest[1].Ownership = 'COOP';
       	accountsTest[2].Ownership = 'COOP';
        accountsTest[3].Ownership = 'COOP';
        update accountsTest[0];
        update accountsTest[1];
        update accountsTest[2];
        update accountsTest[3];

        // CREATE OFFRES PSH
        List<Offre_PSH__c> offrePSH1 = DataFactory.createOffresPSH(1, accountsTest[0].Id, '2020', 'Offre PEE', Date.newInstance(2020,12,20), true);
        
        offrePSH1[0].Avancement_du_dossier__c = 'Terminé';
        update offrePSH1[0];

        List<Offre_PSH__c> offrePSH2 = DataFactory.createOffresPSH(1, accountsTest[1].Id, '2020', 'Offre PEE', Date.newInstance(2020,12,20), true);
        
        offrePSH2[0].Avancement_du_dossier__c = 'Terminé';
        update offrePSH2[0];

        List<Offre_PSH__c> offrePSH3 = DataFactory.createOffresPSH(1, accountsTest[2].Id, '2019', 'Offre PEE', Date.newInstance(2019,11,10), true);

        List<Offre_PSH__c> offrePSH4 = DataFactory.createOffresPSH(1, accountsTest[3].Id, '2019', 'Offre PEE', Date.newInstance(2019,11,10), true);

        // CREATE CONVENTIONS ANNUELLES
        List<Convention_annuelle__c> convAnnuel1 = DataFactory.createConventionsAnnuelles(1, accountsTest[0].Id, 2020, Date.newInstance(2020,01,01), Date.newInstance(2020,12,22), Label.Contract_Pack_RecordTypeId, true);
        List<Convention_annuelle__c> convAnnuel2 = DataFactory.createConventionsAnnuelles(1, accountsTest[1].Id, 2019, Date.newInstance(2019,01,01), Date.newInstance(2019,12,10), Label.Contract_Pack_RecordTypeId, true);
        List<Convention_annuelle__c> convAnnuel3 = DataFactory.createConventionsAnnuelles(1, accountsTest[1].Id, 2020, Date.newInstance(2020,01,01), Date.newInstance(2020,12,10), Label.Contract_Pack_RecordTypeId, true);
        
        
        BT01_AccountConventionTypeUpdate batch = new BT01_AccountConventionTypeUpdate();
        Database.executeBatch(batch);
        
        Account ACCtotest1 = [SELECT Id, Name, Type_de_Convention_new__c FROM Account WHERE Id = :accountsTest[0].Id];
        Account ACCtotest2 = [SELECT Id, Name, Type_de_Convention_new__c FROM Account WHERE Id = :accountsTest[1].Id];
        Account ACCtotest3 = [SELECT Id, Name, Type_de_Convention_new__c FROM Account WHERE Id = :accountsTest[2].Id];
        Account ACCtotest4 = [SELECT Id, Name, Type_de_Convention_new__c FROM Account WHERE Id = :accountsTest[3].Id];
        
        /*system.debug('acc1 '+ACCtotest1.Type_de_Convention_new__c);
        system.debug('acc2 '+ACCtotest2.Type_de_Convention_new__c);
        system.debug('acc3 '+ACCtotest3.Type_de_Convention_new__c);
        System.assertEquals('SYNERCIEL + PEE', ACCtotest1.Type_de_Convention_new__c);
        System.assertEquals('PEE', ACCtotest2.Type_de_Convention_new__c);
        System.assertEquals('SYNERCIEL', ACCtotest3.Type_de_Convention_new__c);
        System.assertEquals('', ACCtotest4.Type_de_Convention_new__c);*/
       
        Test.stopTest();

        }        
    }
    
    
    
    
}