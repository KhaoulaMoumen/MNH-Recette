/*----------------------------------------------------------------------
-- - Name          : BA18_GestionClubs
-- - Author        : Khaoula MOUMEN
-- - Description   : Gestion des Clubs (Club_CCH__c, ClubPEE__c et ClubCME__c).
--   
-- Maintenance History:
--
-- Date         Name                Version     Remarks 
-- -----------  -----------         --------    ---------------------------------------
-- 04-05-2021   KM                    1.0         Init
---------------------------------------------------------------------------------------
*/
global class BA18_GestionClubs implements Database.Batchable<sObject>, Database.Stateful {
    
    Date todaysDate = system.today();

    // QUERY ONLY THE CME AND CCH AND PEE THAT MATCHES THE CONDITIONS
    private String query = 'SELECT Id, Club_CCH__c, ClubPEE__c, ClubCME__c, (SELECT Id FROM Clubs_Mobilite_Electrique__r WHERE Date_entree_CME__c <= :todaysDate AND (Date_sortie_CME__c >= :todaysDate OR Date_sortie_CME__c = null)), (SELECT id FROM Offres_PSH__r WHERE Date_de_signature_Recrutement_Synerciel__c <= :todaysDate AND (Date_de_fin_contrat__c >= :todaysDate OR Date_de_fin_contrat__c = null)), (SELECT id FROM Cercles_Confort_Habitat__r WHERE Date_d_entree__c <= :todaysDate AND (Date_sortie_CCH__c >= :todaysDate OR Date_sortie_CCH__c = null)) FROM Account';    
 
    global Database.QueryLocator start(Database.BatchableContext bc) {
        System.debug('[BA18_GestionClubs][start] start');
        return Database.getQueryLocator(query);
    }
	/*
	 * 
	 * 
	 */
    global void execute(Database.BatchableContext BC, List<Account> scope) {
        List<Account> accToUpdate = new List<Account>();
       
        for(Account acc : scope) {
            Boolean exist = false;
            // CHECK CLUB CCH
            if((acc.Cercles_Confort_Habitat__r).size() > 0 && acc.Cercles_Confort_Habitat__r != NULL){
                if(!acc.Club_CCH__c) {
                    acc.Club_CCH__c = true;
                    exist = true;
                }
            } else {
                if(acc.Club_CCH__c) {
                    acc.Club_CCH__c = false;
                    exist = true;
                }
            }
            // CHECK CLUB PME 
            if((acc.Clubs_Mobilite_Electrique__r).size() > 0 && acc.Clubs_Mobilite_Electrique__r != NULL){
                if(!acc.ClubCME__c) {
                    acc.ClubCME__c = true;
                    exist = true;
                }
            } else {
                if(acc.ClubCME__c) {
                    acc.ClubCME__c = false;
                    exist = true;
                }
            }
            // CHECK CLUB PEE
            if((acc.Offres_PSH__r).size() > 0 && acc.Offres_PSH__r != NULL){
                if(!acc.ClubPEE__c) {
                    acc.ClubPEE__c = true;
                    exist = true;
                }
            } else {
                if(acc.ClubPEE__c) {
                    acc.ClubPEE__c = false;
                    exist = true;
                }
            }
            if(exist) accToUpdate.add(acc);
        }
        // UPDATE ACCOUNTS
        if(accToUpdate.size()>0 && accToUpdate != NULL) update accToUpdate;
    }
    /*
     *
	 * 
	 */  
    global void finish(Database.BatchableContext BC){  
        System.debug('[BA18_GestionClubs][finish] finish');
    }
    
   
}