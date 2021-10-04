/*
------------------------------------------------------------------------------------
-- - Name          : TR01_Account
-- - Author        : Khaoula MOUMEN
-- - Description   : Trigger Account - Before insert/update
--    
-- Maintenance History:
--
-- Date         Name                Version     Remarks 
-- -----------  -----------         --------    ---------------------------------------
-- 26-06-2021   K.M                 1.0         Init
---------------------------------------------------------------------------------------
*/
trigger TR01_Account on Account (before insert, before update) {
    List<Account> accountsToUpdate = new List<Account>();
    
    if(Trigger.isBefore && Trigger.isInsert) {
        for(Account acc : Trigger.new){
            // Execute for all person accounts
            if(acc.isPersonAccount) accountsToUpdate.add(acc);
        }
    } 
    if(Trigger.isBefore && Trigger.isUpdate) {
        for(Account acc : Trigger.new){
            //Get only person accounts who's billing postal code OR the professional situation OR Establishment value has changed
            if(acc.isPersonAccount && 
               ((acc.Situation_professionnelle__c != Trigger.oldMap.get(acc.Id).Situation_professionnelle__c && acc.Situation_professionnelle__c == 'Actif dans le secteur de la santé' && acc.Etablissement__c != NULL && acc.Etablissement__c !='')
                || (acc.Etablissement__c != Trigger.oldMap.get(acc.Id).Etablissement__c && acc.Situation_professionnelle__c == 'Actif dans le secteur de la santé') 
                || acc.PersonMailingPostalCode != Trigger.oldMap.get(acc.Id).PersonMailingPostalCode)) accountsToUpdate.add(acc);
            
        }
    }
    
    // Attribute Zones de chalandises to Users 
    if(PAD.canTrigger('AP01')) {
        if(accountsToUpdate.size() > 0 && accountsToUpdate != NULL) {
            system.debug('Trigger accountsToUpdate '+accountsToUpdate);
            PAD01_GestionTerritoiresAcc.affecterTerritoire(accountsToUpdate);
        }
    }
}