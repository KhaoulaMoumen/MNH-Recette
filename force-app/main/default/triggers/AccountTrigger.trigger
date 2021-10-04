/*
------------------------------------------------------------------------------------
-- - Name          : AccountTrigger
-- - Author        : Khaoula MOUMEN
-- - Description   : Account trigger logic
--   
-- Maintenance History:
--
-- Date           Name                Version     Remarks 
-- -----------    -----------         --------    ---------------------------------------
-- ***            K.M                 1.0         Init
-- 03/05/2021     K.M                 1.1         IBAN Verification Logic
-- 04/06/2021     D.A                 1.2         Connecteur INTUIZ
---------------------------------------------------------------------------------------
*/
trigger AccountTrigger on Account (before insert, after insert, before update, after update) {
    
    TRGHDL_Account handler = new TRGHDL_Account();
    
    if(Trigger.isBefore) {

        
        if(Trigger.isInsert) {
            handler.beforeInsert( Trigger.new);
        }

        if(Trigger.isUpdate) {

            handler.beforeUpdate(Trigger.new, Trigger.oldMap );
        }
    }


    else if(Trigger.isAfter) {
        
        Integer i = 0;
        if (TriggerExecuted.getExecuted() == 0) {
            
            List<Account> accounts = Trigger.New;
            Map<Id, Account> oldAccounts = Trigger.oldMap;
            
            Set<Id> accUpdateIds = new Set<Id>();
            Set<Id> adherentIds = new Set<Id>();
            Set<Id> clientIds = new Set<Id>();
            Set<Id> desactivateAcc = new Set<Id>();
            Set<Id> verifyIbanAcc = new Set<Id>();
            
            Set<Id> accountIds = new Set<Id>();
            for(Account a: accounts) accountIds.add(a.Id);
            
            if(Trigger.isInsert) {
                // Assign salesperson and assistant commercial and groupRegion to accounts 
                CTRL01_AccountTerritorySettings.manageAccTerritories(accountIds);
                
                // Verify bank data
/*
=================================== CODE A ACTIVER AVANT DE DEPLOYER ============================================
                for(Account acc : accounts){
                    if(acc.IBAN__c != NULL && acc.IBAN__c != '' && acc.was_created_from_lead__c == true) verifyIbanAcc.add(acc.Id);
                }
                
                if(verifyIbanAcc.size() > 0 && verifyIbanAcc != NULL) {
                    CTRL13_BankDataManagement.checkBankData(verifyIbanAcc);
                }
*/
            }
            
            if(Trigger.isUpdate) {
                
                for(Account acc : accounts) {
                    // Re-assign salesperson and assistant commercial and groupRegion to accounts 
                    if(acc.BillingPostalCode != oldAccounts.get(acc.Id).BillingPostalCode) {
                        accUpdateIds.add(acc.Id);
                    }
                    
                    /***** DEBUG ****
                    System.debug('Acc Profile '+acc.Profil__c);
                    System.debug('Acc RecordTypeId '+acc.RecordTypeId);
                    System.debug('Acc old TECH_isAccClient__c '+Trigger.oldMap.get(acc.Id).TECH_isAccClient__c);
                    System.debug('Acc new TECH_isAccClient__c '+acc.TECH_isAccClient__c);
                    ***** END DEBUG ****/
                    
                    // le profil est Client, on crée/active un User community pour cet client
                    //if(acc.Profil__c == 'Client' && acc.RecordTypeId == System.Label.LABS_SF_ACC_RT_ClientId && acc.TECH_isAccClient__c != Trigger.oldMap.get(acc.Id).TECH_isAccClient__c && Trigger.oldMap.get(acc.Id).TECH_isAccClient__c == true) 
                   if(acc.Profil__c == 'Client' && acc.RecordTypeId == System.Label.LABS_SF_ACC_RT_ClientId && Trigger.oldMap.get(acc.Id).Profil__c != 'Client') {
                        clientIds.add(acc.Id);
                    }
                    
                    // le profil vient de passer à Adhérent, on crée/active un User pour cet adhérent
                    //if((acc.Profil__c == 'Adhérent' && Trigger.oldMap.get(acc.Id).Profil__c != 'Adhérent' && acc.RecordTypeId == System.Label.Account_Adherent_RT) || (acc.TECH_Creation_Manuelle_User_Adh__c == true && Trigger.oldMap.get(acc.Id).TECH_Creation_Manuelle_User_Adh__c == false) ) {
                    if(acc.Profil__c == 'Adhérent' && Trigger.oldMap.get(acc.Id).Profil__c != 'Adhérent' && acc.RecordTypeId == System.Label.Account_Adherent_RT) {
                        
                        adherentIds.add(acc.Id);
                    }
                    // le profil vient de passer à Adhérent, on crée/active un User pour cet adhérent
                    //if((acc.Profil__c == 'Adhérent' && Trigger.oldMap.get(acc.Id).Profil__c != 'Adhérent' && acc.RecordTypeId == System.Label.Account_Adherent_RT) || (acc.TECH_Creation_Manuelle_User_Adh__c == true && Trigger.oldMap.get(acc.Id).TECH_Creation_Manuelle_User_Adh__c == false) ) {
                    if(acc.Profil__c == 'Adhérent' && Trigger.oldMap.get(acc.Id).Profil__c != 'Adhérent' && acc.RecordTypeId == System.Label.Account_Adherent_RT) {
                        
                        adherentIds.add(acc.Id);
                    }
                    
                    // le profil vient de passer à Ancien adhérent, on désactive son User
                    if(acc.Profil__c == 'Ancien Adhérent' && Trigger.oldMap.get(acc.Id).Profil__c == 'Adhérent' && acc.RecordTypeId == System.Label.Account_Adherent_RT) {
                        desactivateAcc.add(acc.Id); 
                    }
                    
                    // le profil vient de passer à Ancien Partenaire, on désactive son user
                    if(acc.Profil__c == 'Ancien Partenaire' && Trigger.oldMap.get(acc.Id).Profil__c == 'Partenaire' && acc.RecordTypeId == System.Label.Account_Partenaire_RT) {
                        desactivateAcc.add(acc.Id); 
                    }
                    
                    // le profil vient de passer à Ancien client, on désactive son user
                    if(acc.Profil__c == 'Ancien client' && Trigger.oldMap.get(acc.Id).Profil__c == 'Client' && acc.RecordTypeId == System.Label.LABS_SF_ACC_RT_ClientId) {
                        desactivateAcc.add(acc.Id); 
                    }
                    
                    // Verify BANK DATA onchange IBAN or BIC or Domiciliation
/*
=================================== CODE A ACTIVER AVANT DE DEPLOYER ============================================
                    if(acc.IBAN__c != Trigger.oldMap.get(acc.Id).IBAN__c && acc.IBAN__c != '' && acc.IBAN__c != NULL && (acc.RecordTypeId == System.Label.Account_Adherent_RT || acc.RecordTypeId == System.Label.LABS_SF_ACC_RT_ClientId)){
                        verifyIbanAcc.add(acc.Id); 
                    }
*/
                }
                
                if(accUpdateIds.size() > 0) {
                    if(!System.isBatch())CTRL01_AccountTerritorySettings.manageAccTerritories(accUpdateIds); 
                }    
                if(adherentIds.size() > 0) {
                    AP03_GestionCommunityUsers.activerAdherent(adherentIds);
                }
                if(desactivateAcc.size() > 0) {
                    AP03_GestionCommunityUsers.deactivatePortalUser(desactivateAcc);
                }
                if(clientIds.size() > 0) {
                    AP03_GestionCommunityUsers.activerClient(clientIds);
                }
/*
======================= CODE A ACTIVER AVANT DEPLOIEMENT =======================================
                if(verifyIbanAcc.size() > 0 && verifyIbanAcc != NULL) {
                    CTRL13_BankDataManagement.checkBankData(verifyIbanAcc);
                }
*/
                handler.afterUpdate(Trigger.new, Trigger.oldMap );
            }
        }
    }
}