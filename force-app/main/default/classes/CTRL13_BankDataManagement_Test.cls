@isTest(SeeAllData=false)
public class CTRL13_BankDataManagement_Test {
    
    @isTest static void testValidIban() {
        
        Test.startTest();
        // Set mock callout class 
        IBANHttpCalloutMock mock = new IBANHttpCalloutMock();
        HttpResponse res1 = new HttpResponse();
        res1.setHeader('Content-Type', 'application/json');
        res1.setBody('{"bank_data":{"bic":"CMCIFRPPXXX","branch":null,"bank":"CREDIT INDUSTRIEL ET COMMERCIAL CIC","address":"95 AV DU BAC","city":"LA VARENNE ST HILAIRE","state":null,"zip":"94210","phone":null,"fax":null,"www":null,"email":null,"country":"FRANCE","country_iso":"FR","account":"00020063801","bank_code":"30066","branch_code":"10866"},"sepa_data":{"SCT":"YES","SDD":"YES","COR1":"YES","B2B":"YES","SCC":"NO"},"validations":{"chars":{"code":"006","message":"IBAN does not contain illegal characters"},"account":{"code":"002","message":"Account Number check digit is correct"},"iban":{"code":"001","message":"IBAN Check digit is correct"},"structure":{"code":"005","message":"IBAN structure is correct"},"length":{"code":"003","message":"IBAN Length is correct"},"country_support":{"code":"007","message":"Country supports IBAN standard"}},"errors":[]}');
        res1.setStatusCode(200);
        mock.addResponse(res1);
        Test.setMock(HttpCalloutMock.class, mock);
        
        list<Account> accs1 = Datafactory.createAccounts(1, 'Adhérent', 'Accepté', false);
        accs1[0].was_created_from_lead__c = true;
        accs1[0].IBAN__c = 'FR7630066108660002006380142';
        accs1[0].Code_BIC__c = 'SOGEFRPP';
        accs1[0].Domiciliation__c = 'None';
        insert accs1;
        
        Test.stopTest();
        
        // Verify response received contains fake values
        Account acc = [SELECT Id, IBAN__c, Code_BIC__c, Domiciliation__c FROM Account WHERE Id =:accs1[0].Id LIMIT 1];
        System.assertNotEquals(accs1[0].Code_BIC__c, acc.Code_BIC__c);
    }
    
    @isTest static void testInvalidIban() {
        
        Test.startTest();
        // Set mock callout class 
        IBANHttpCalloutMock mock = new IBANHttpCalloutMock();
        HttpResponse res1 = new HttpResponse();
        res1.setHeader('Content-Type', 'application/json');
        res1.setBody('{"bank_data":{"bic":"","branch":"","bank":"","address":"","city":"","state":"","zip":"","phone":"","fax":"","www":"","email":"","country":"France","country_iso":"FR","account":"00617968040","bank_code":"15569","branch_code":"22870"},"sepa_data":{"SCT":"NO","SDD":"NO","COR1":"NO","B2B":"NO","SCC":"NO"},"validations":{"chars":{"code":"006","message":"IBAN does not contain illegal characters"},"account":{"code":"201","message":"Account Number check digit not correct"},"iban":{"code":"202","message":"IBAN Check digit not correct"},"structure":{"code":"005","message":"IBAN structure is correct"},"length":{"code":"003","message":"IBAN Length is correct"},"country_support":{"code":"007","message":"Country supports IBAN standard"}},"errors":[]}');
        res1.setStatusCode(200);
        mock.addResponse(res1);
        Test.setMock(HttpCalloutMock.class, mock);
        
        list<Account> accs1 = Datafactory.createAccounts(1, 'Adhérent', 'Accepté', false);
        accs1[0].IBAN__c = 'FR7630066108660002006380142';
        accs1[0].Code_BIC__c = 'SOGEFRPP';
        accs1[0].Domiciliation__c = 'None';
        insert accs1;
        
        // Update with invalid iban
		accs1[0].IBAN__c = 'FR7615569228700061796804047';
		update accs1[0];
        
        Test.stopTest();
        
        // Verify response received contains fake values
        Account acc = [SELECT Id, IBAN__c, Code_BIC__c, Domiciliation__c FROM Account WHERE Id =:accs1[0].Id LIMIT 1];
        System.assertEquals(acc.Code_BIC__c, null);
    }
    
    @isTest static void testIbanAutre() {
        
        Test.startTest();
        // Set mock callout class 
        IBANHttpCalloutMock mock = new IBANHttpCalloutMock();
        HttpResponse res1 = new HttpResponse();
        res1.setHeader('Content-Type', 'application/json');
        res1.setBody('{"bank_data":{"bic":"","branch":"","bank":"","address":"","city":"","state":"","zip":"","phone":"","fax":"","www":"","email":"","country":"France","country_iso":"FR","account":"00617968040","bank_code":"15569","branch_code":"22870"},"sepa_data":{"SCT":"NO","SDD":"NO","COR1":"NO","B2B":"NO","SCC":"NO"},"validations":{"chars":{"code":"302","message":"IBAN does not contain illegal characters"},"account":{"code":"301","message":"Account Number check digit not correct"},"iban":{"code":"303","message":"IBAN Check digit not correct"},"structure":{"code":"304","message":"IBAN structure is correct"},"length":{"code":"305","message":"IBAN Length is correct"},"country_support":{"code":"007","message":"Country supports IBAN standard"}},"errors":[]}');
        res1.setStatusCode(200);
        mock.addResponse(res1);
        Test.setMock(HttpCalloutMock.class, mock);
        
        list<Account> accs1 = Datafactory.createAccounts(1, 'Adhérent', 'Accepté', false);
        accs1[0].was_created_from_lead__c = true;
        accs1[0].IBAN__c = 'FR7630066108660002006380142';
        accs1[0].Code_BIC__c = 'SOGEFRPP';
        accs1[0].Domiciliation__c = 'None';
        insert accs1;
        
        Test.stopTest();
        
        // Verify response received contains fake values
        Account acc = [SELECT Id, IBAN__c, Code_BIC__c, Domiciliation__c FROM Account WHERE Id =:accs1[0].Id LIMIT 1];
        System.assertEquals(acc.Code_BIC__c, null);
    }
}