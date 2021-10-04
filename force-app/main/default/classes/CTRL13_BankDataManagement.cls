/*
------------------------------------------------------------------------------------
-- - Name          : CTRL13_BankDataManagement
-- - Author        : Khaoula MOUMEN
-- - Description   : 
--    
-- Maintenance History:
--
-- Date         Name                Version     Remarks 
-- -----------  -----------         --------    ---------------------------------------
-- 30-04-2021   K.M                 1.0         Init
---------------------------------------------------------------------------------------
*/
public class CTRL13_BankDataManagement {
    
    @future(callout=true)
    public static void checkBankData(Set<Id> accountIds) {
        Set<String>  successCodes = new Set<String> {'001', '002', '003', '004', '005', '006', '007'}; 
            Set<String>  errorCodes = new Set<String> {'201', '202', '203', '205', '206', '207'}; 
                Set<String>  otherCodes = new Set<String> {'301', '302', '303', '304', '305'}; 
                    
                    String url = 'https://api.iban.com/clients/api/v4/iban/';
        String api_key = Label.IBAN_API_Key;
        String user_agent = 'API Client/1.0';
        
        List<Account> accountsToVerify = [SELECT Id, IBAN__c, Code_BIC__c, Domiciliation__c, TECH_isIbanValid__c, Tech_IBAN_ValidationMsg__c
                                          FROM Account 
                                          WHERE Id IN :accountIds];
        
        if(accountsToVerify != NULL && accountsToVerify.size() > 0) { 
            for(Account acc : accountsToVerify) {
                String body = '?api_key='+ api_key +'&format=json&iban='+acc.IBAN__c;
                
                Http http = new Http();
                HttpRequest request = new HttpRequest();
                request.setEndpoint(url+body);
                request.setHeader('User-Agent', user_agent);
                request.setHeader('Content-Type','application/json');
                request.setMethod('GET');
                
                //Send the http request
                HttpResponse response = http.send(request);
                
                system.debug('Response body '+response.getBody());
                system.debug('Response Status '+response.getStatusCode());
                
                // Parse the JSON response
                JSON2Apex_IBAN resultWS = JSON2Apex_IBAN.parse(response.getBody());
                
                // If the request is successful
                if (response.getStatusCode() == 200) {
                    if(resultWS != NULL && resultWS.Validations != NULL) {
                        
                        //Get validation message and code
                        JSON2Apex_IBAN.Validations validationResult= resultWS.Validations;
                        
                        if(validationResult != NULL) {
                            // Check success
                            if(resultWS != NULL && resultWS.Bank_data != NULL && resultWS.Bank_data.bic != NULL && resultWS.Bank_data.bic != '') {
                                if(successCodes.contains(validationResult.chars.code) || successCodes.contains(validationResult.account.code) || 
                                   successCodes.contains(validationResult.iban.code) || successCodes.contains(validationResult.structure.code) ||
                                   successCodes.contains(validationResult.length.code) || successCodes.contains(validationResult.country_support.code)) {
                                       JSON2Apex_IBAN.Bank_data returnedData = resultWS.Bank_data;
                                       
                                       if(returnedData.bic != NULL) acc.Code_BIC__c = returnedData.bic;
                                       if(returnedData.bank != NULL) acc.Domiciliation__c = returnedData.bank;
                                       acc.TECH_isIbanValid__c = 'Valide';
                                       acc.Tech_IBAN_ValidationMsg__c = 'Coordonnées bancaire validées';
                                   }
                            } 
                            else if(errorCodes.contains(validationResult.chars.code) || errorCodes.contains(validationResult.account.code) ||
                                    errorCodes.contains(validationResult.iban.code) || errorCodes.contains(validationResult.structure.code) ||
                                    errorCodes.contains(validationResult.length.code) || errorCodes.contains(validationResult.country_support.code)) {
                                        acc.IBAN__c = '';
                                        acc.Code_BIC__c = '';
                                        acc.Domiciliation__c = '';
                                        acc.TECH_isIbanValid__c = 'Non Valide';
                                        if(validationResult.account.code == '201') acc.Tech_IBAN_ValidationMsg__c = 'Validation Failed : Account Number check digit not correct';
                                        if(validationResult.iban.code == '202') acc.Tech_IBAN_ValidationMsg__c = 'Validation Failed	 IBAN Check digit not correct';
                                        if(validationResult.length.code == '203') acc.Tech_IBAN_ValidationMsg__c = 'Validation Failed : IBAN Length is not correct';
                                        if(validationResult.structure.code == '205') acc.Tech_IBAN_ValidationMsg__c = 'Validation Failed : IBAN structure is not correct';
                                        if(validationResult.chars.code == '206') acc.Tech_IBAN_ValidationMsg__c = 'Validation Failed : IBAN contains illegal characters';
                                        if(validationResult.country_support.code == '207') acc.Tech_IBAN_ValidationMsg__c = 'Validation Failed : Country does not support IBAN standard';
                                    }
                            else if(otherCodes.contains(validationResult.chars.code)) {
                                        acc.IBAN__c = '';
                                        acc.Code_BIC__c = '';
                                        acc.Domiciliation__c = '';
                                        acc.TECH_isIbanValid__c = 'Autre';
                                        if(validationResult.account.code == '301') acc.Tech_IBAN_ValidationMsg__c = 'Account Error : API Key is invalid';
                                        if(validationResult.account.code == '302') acc.Tech_IBAN_ValidationMsg__c = 'Account Error : Subscription expired';
                                        if(validationResult.account.code == '303') acc.Tech_IBAN_ValidationMsg__c = 'Account Error : No queries available';
                                        if(validationResult.account.code == '304') acc.Tech_IBAN_ValidationMsg__c = 'Account Error : You have no access to this API';
                                        if(validationResult.account.code == '305') acc.Tech_IBAN_ValidationMsg__c = 'Account Error : IP Address not allowed';
                                    }
                        }
                    }
                }
            }
        }
        if(accountsToVerify != NULL && accountsToVerify.size() > 0) update accountsToVerify;
    }
    
}