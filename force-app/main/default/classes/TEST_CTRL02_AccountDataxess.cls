@isTest
private with sharing class TEST_CTRL02_AccountDataxess {
	
	@testSetup static void setup_testSetup() {
		setup_CreateConfiguration();
	}

	@isTest static void setup_CreateConfiguration() {
		Altares_Configuration__c config = Util_Test.CustomSetting.createConfiguration();
		System.assertEquals('Login__c', config.Login__c);
		System.assertEquals('Mot_de_passe__c', config.Mot_de_passe__c);
		System.assertEquals('Reference_client__c', config.Reference_client__c);
	}

	@isTest static void test_updateRecord() {
		
        List<Account> listAccount = new List<Account> ();
        List<Account> listAccountToUpdt = new List<Account> ();
        
        Code_APE__c codeAPE = new code_APE__c(
                            Code__c = 'APE15',
                            Name    = 'APE15' + '-' + '123456',
                            CompleteNameCodeAPE__c = 'APE15' + '-' + '123456'
                        );
        insert codeAPE;
        
        Code_APE__c codeAPE2 = new code_APE__c(
                            Code__c = 'APE16',
                            Name    = 'APE16' + '-' + '123456',
                            CompleteNameCodeAPE__c = 'APE16' + '-' + '123456'
                        );
        insert codeAPE2;
        
		Account a = new Account();
		a.name='TEST CODE APE NORMAL';
		a.sirenSiret__c = '44059015600053';
		a.administrativeStatus__c='Accepté';
        a.Profil__c ='Adhérent';
	
        Account b = new Account();
		b.name='TEST CODE APE TROP LONG';
		b.sirenSiret__c = '52246657200040';
		b.administrativeStatus__c='Accepté';
        b.Profil__c ='Adhérent';
	
        Account c = new Account();
		c.name='TEST CODE APE EXISTANT NORMAL';
		c.sirenSiret__c = '81042446500013';
		c.administrativeStatus__c='Accepté';
        c.Profil__c ='Adhérent';
	
        Account d = new Account();
		d.name='TEST CODE APE EXISTANT TROP LONG';
		d.sirenSiret__c = '51352240900038';
		d.administrativeStatus__c='Accepté';
        d.Profil__c ='Adhérent';

        
        listAccount.add(a);
        listAccount.add(b);
        listAccount.add(c);
        listAccount.add(d);
        
        insert listAccount; 
        
		API_serviceCallistoAltaresCustomMockImpl mock = new API_serviceCallistoAltaresCustomMockImpl(null);

		Test.startTest();
		Test.setMock(WebServiceMock.class,mock);
            
        a = listAccount[0];
            
        Datetime myDateTime = Datetime.now();
        a.Derniere_mise_jour_Altares__c = myDateTime;   
		a.Entreprise_active__c = 'Oui';
        a.Code_NAF_entreprise__c = 'APE12';
        a.Libelle_code_NAF_entreprise__c = 'TESTAPE1';
        listAccountToUpdt.add(a);
       
        b = listAccount[1];
        b.Derniere_mise_jour_Altares__c = myDateTime;   
		b.Entreprise_active__c = 'Oui';
        b.Code_NAF_entreprise__c = 'APE13';
        b.Libelle_code_NAF_entreprise__c = 'TESTAPE1121212121212121215151151515515515445848787854845455154548454851454754158425458145';
        listAccountToUpdt.add(b);
        
        c = listAccount[2];
        c.Derniere_mise_jour_Altares__c = myDateTime;   
		c.Entreprise_active__c = 'Oui';
        c.Code_NAF_entreprise__c = 'APE15';
        c.Libelle_code_NAF_entreprise__c = 'TESTAPE11';
        listAccountToUpdt.add(c);
       
        d = listAccount[3];
        d.Derniere_mise_jour_Altares__c = myDateTime;   
		d.Entreprise_active__c = 'Oui';
        d.Code_NAF_entreprise__c = 'APE16';
        d.Libelle_code_NAF_entreprise__c = 'TESTAPE1121212121212121215151151515515515445848787854845455154548454851454754158425458145';
        listAccountToUpdt.add(d);
       
        
        update listAccountToUpdt;
        
        
        Integer invocations = Limits.getEmailInvocations();
		Test.stopTest();
		
        List<String> AccountIds = new List<String>{a.Id,b.Id,c.Id,d.Id};
		
        system.assertNotEquals(0, invocations,  ' An email should be sent');
        
        Account newAccountToCheck = [SELECT Id, Code_APE__c , Code_APE__r.Code__c FROM Account WHERE Id = :a.Id];
        System.assertEquals('APE12',newAccountToCheck.Code_APE__r.Code__c);
        
        List<Account> verifAPECode = [SELECT ID, Code_APE__r.Name FROM Account WHERE  Id in :AccountIds];
        System.assertEquals('APE12-TESTAPE1',verifAPECode[0].Code_APE__r.Name);
		System.assertEquals('APE13-TESTAPE112121212121212121515115151551551544584878785484545515454845485145',verifAPECode[1].Code_APE__r.Name);
        System.assertEquals('APE15-TESTAPE11',verifAPECode[2].Code_APE__r.Name);
        System.assertEquals('APE16-123456',verifAPECode[3].Code_APE__r.Name);
        
	}
	
}