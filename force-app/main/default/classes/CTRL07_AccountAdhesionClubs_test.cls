@isTest(SeeAllData = false)
public class CTRL07_AccountAdhesionClubs_test {
    @testSetup 
    static void setup() {
        user myUser = [select id from user where profile.name like '%Admin%' and isActive = true limit 1];
        list<Account> accs=DataFactory.createAccounts(1, 'Adhérent', 'Accepté', true);
        list<Cercle_Confort_Habitat__c>CCH =DataFactory.createCCHs(1, myUser.id, 'test', true);
        accs[0].Pack_signe__c='INTEGRAL';
        accs[0].ownership='LIMITED';
        update accs[0];
        list<Cercle_confort_habitat_adh_rent__c>CCHs = DataFactory.createCCHAdhrents(2, accs[0].id, CCH[0].id,myUser.id,false);
        CCHs[0].Date_d_entree__c=Date.today();
        CCHs[0].Date_sortie_CCH__c=Date.today().addDays(2);
        insert CCHs[0];
        CCHs[0].Date_d_entree__c=Date.today().addDays(-2);
        update CCHs[0];
        insert CCHs[1];
        delete CCHs[1];
        
        
        Club_Mobilite_Electrique__c myCME = new Club_Mobilite_Electrique__c(name = 'test',Account__c=accs[0].id,
                                                                            Date_entree_CME__c=Date.today(),
                                                                            Date_sortie_CME__c=Date.today().addDays(2));
        insert myCME;
        Club_Mobilite_Electrique__c myCME1 = new Club_Mobilite_Electrique__c(name = 'test',Account__c=accs[0].id,
                                                                            Date_entree_CME__c=Date.today(),
                                                                            Date_sortie_CME__c=Date.today().addDays(2));
        insert myCME1;
        delete myCME1;
        myCME.Date_entree_CME__c=Date.today().addDays(-2);
        update myCME;
        Offre_PSH__c myPEE = new Offre_PSH__c(name = 'test',Compte__c=accs[0].id,Annee__c='2020',
                                              Date_de_signature_Recrutement_Synerciel__c=Date.today(),
                                              Date_de_fin_contrat__c=Date.today().addDays(2));
        insert myPEE;
        Offre_PSH__c myPEE1 = new Offre_PSH__c(name = 'test',Compte__c=accs[0].id,Annee__c='2020',
                                              Date_de_signature_Recrutement_Synerciel__c=Date.today(),
                                              Date_de_fin_contrat__c=Date.today().addDays(2));
        insert myPEE1;
        delete myPEE1;
        myPEE.Date_de_signature_Recrutement_Synerciel__c=Date.today().addDays(-2);
        update myPEE;
    }
    static testmethod void test1() {
        
        Test.startTest();
        Account adherent = [SELECT Id, Club_CCH__c, ClubPEE__c, ClubCME__c FROM Account LIMIT 1];
        adherent.Club_CCH__c = false;
        adherent.ClubPEE__c = false;
        adherent.ClubCME__c = false;
        update adherent; 
        
        Database.executeBatch(new BA18_GestionClubs());
        SchBT13_AccountGestionClubs myClass = new SchBT13_AccountGestionClubs ();   
         String chron = '0 0 23 * * ?';        
         system.schedule('Test Schedulable', chron, myClass);
        Test.stopTest();
    }
        
     static testmethod void test2() {
        Date todaysDate = system.today();
         
        Test.startTest();
           list<Cercle_confort_habitat_adh_rent__c> listCCHs = [SELECT id, Date_d_entree__c,Date_sortie_CCH__c FROM Cercle_confort_habitat_adh_rent__c WHERE Date_d_entree__c <= :todaysDate AND (Date_sortie_CCH__c >= :todaysDate OR Date_sortie_CCH__c = null)];
        if(listCCHs.size() > 0) {
        for(Cercle_confort_habitat_adh_rent__c cch : listCCHs) {
            cch.Date_d_entree__c = Date.today().addDays(2);
            cch.Date_sortie_CCH__c = Date.today().addDays(30);
        } 
            update listCCHs;
        }
            
        list<Club_Mobilite_Electrique__c> listCMEs = [SELECT Id, Date_entree_CME__c,Date_sortie_CME__c FROM Club_Mobilite_Electrique__c WHERE Date_entree_CME__c <= :todaysDate AND (Date_sortie_CME__c >= :todaysDate OR Date_sortie_CME__c = null)];
        if(listCMEs.size() > 0) {
        for(Club_Mobilite_Electrique__c cme : listCMEs) {
            cme.Date_entree_CME__c = Date.today().addDays(2);
            cme.Date_sortie_CME__c = Date.today().addDays(30);
        } 
            update listCMEs;   
        }
         
        list<Offre_PSH__c> listPEEs = [SELECT id,Date_de_signature_Recrutement_Synerciel__c,Date_de_fin_contrat__c FROM Offre_PSH__c WHERE Date_de_signature_Recrutement_Synerciel__c <= :todaysDate AND (Date_de_fin_contrat__c >= :todaysDate OR Date_de_fin_contrat__c = null)];
        if(listPEEs.size() > 0) {
        for(Offre_PSH__c pee : listPEEs) {
            pee.Date_de_signature_Recrutement_Synerciel__c = Date.today().addDays(2);
            pee.Date_de_fin_contrat__c = Date.today().addDays(30);
        } 
        update listPEEs;   
        }
           
        Account adherent = [SELECT Id, Club_CCH__c, ClubPEE__c, ClubCME__c FROM Account LIMIT 1];
        adherent.Club_CCH__c = true;
        adherent.ClubPEE__c = true;
        adherent.ClubCME__c = true;
        update adherent; 
        
        Database.executeBatch(new BA18_GestionClubs());
        SchBT13_AccountGestionClubs myClass = new SchBT13_AccountGestionClubs ();   
         String chron = '0 0 23 * * ?';        
         system.schedule('Test Schedulable', chron, myClass);
        Test.stopTest();
    }

}