/*----------------------------------------------------------------------
-- - Name          : BA11_AccountValidAssurQualif
-- - Author        : Khaoula MOUMEN
-- - Description   : 
--   
-- Maintenance History:
--
-- Date         Name                Version     Remarks 
-- -----------  -----------         --------    ---------------------------------------
-- 16-12-2020   KM                    1.0         Init
---------------------------------------------------------------------------------------
*/
global class BA11_AccountValidAssurQualif implements Database.Batchable<sObject>, Database.Stateful {

    private String query = 'SELECT Id,(SELECT Compte__c, Date_de_fin__c, Statut__c FROM Account.Assurance__r),(SELECT Compte__c, Date_de_fin__c FROM Account.Qualifications_prospect_adh_rent__r) FROM Account';    
 
    global Database.QueryLocator start(Database.BatchableContext bc) {
        System.debug('[BA11_AccountValidAssurQualif][start] start');
        return Database.getQueryLocator(query);
    }
	/**
	* 
	*/
    global void execute(Database.BatchableContext BC, List<Account> scope) {
       
        for(Account acc : scope) {
            // GET ALL ACCOUNT RELATED ASSURANCES PA
            List<Assurances__c> assurancesPA = acc.Assurance__r;
            // CALCULATE NUMBER OF VALID ASSURANCES PA
            if(assurancesPA.size() > 0) CTRL08_AssurancesPAHandler.calculateNbrAssurancesPA(assurancesPA, true);
            
            // GET ALL ACCOUNT RELATED QUALIFICATIONS PA
            List<Qualification_prospect_adherent__c> qualificationsPA = acc.Qualifications_prospect_adh_rent__r;
            // CALCULATE NUMBER OF VALID QUALIFICATIONS PA
            if(qualificationsPA.size() > 0) CTRL09_QualificationTriggerHandler.calculateNbrQualifications(qualificationsPA, true);
        }
       
    }
    /**
	* 
	*/
    global void finish(Database.BatchableContext BC){       
    }
    
   
}