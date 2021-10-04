/*
Method that handles Trigger TR02_UserTerritoryChange Logic
CreatedBy : MOUMEN Khaoula
@Email : khaoula.moumen@talan.com
CreateDate : 10/02/2020
*/
public class CTRL01_AccountTerritorySettings {
    
    @future
    public static void manageAccTerritories(Set<Id> accountIds) {
        Integer i = 0;
        
        Map<Id,String> rs = new Map<Id,String>();
        Map<Id,Id> assco = new Map<Id,Id>();
        Map<Id,String> terr = new Map<Id,String>();
        Map<Id,Id> rsId = new Map<Id,Id>();
        
        List<Account> AccountsToUpdate = new List<Account>();
        
        String get_rs;
        String get_assco;
        String get_terr;
        Id get_rsId;
        
        List<Account> accounts = [SELECT Id, salespersonCode__c, assistanteCommerciale__c, groupRegion__c,BillingPostalCode,Responsable_secteur__c
                                  FROM Account 
                                  WHERE Id IN :accountIds
                                 ];
                
        
        List<AccountUserTerritory2View> aut_rs = [SELECT AccountId, User.Email, UserId
                                                  FROM AccountUserTerritory2View 
                                                  WHERE AccountId IN :accounts AND RoleInTerritory2 = :System.Label.Responsable_Secteur
                                                 ];
        List<AccountUserTerritory2View> aut_assco = [SELECT AccountId, UserId 
                                                     FROM AccountUserTerritory2View 
                                                     WHERE AccountId IN :accounts AND RoleInTerritory2 = :System.Label.Assistant_e_Commercial_e
                                                    ];
        List<AccountUserTerritory2View> aut_terr = [SELECT AccountId, Territory2.ParentTerritory2.Name 
                                                    FROM AccountUserTerritory2View 
                                                    WHERE AccountId IN :accounts
                                                   ];
        
        for(AccountUserTerritory2View aut : aut_rs) {
            rs.put(aut.AccountId, aut.User.Email);
            rsId.put(aut.AccountId, aut.UserId);
        }
        
        for(AccountUserTerritory2View aut : aut_assco) {
            assco.put(aut.AccountId, aut.UserId);
        }
        
        for(AccountUserTerritory2View aut : aut_terr) {
            terr.put(aut.AccountId, aut.Territory2.ParentTerritory2.Name);
        }
        
        for(Account acc : accounts) 
        {
            i = 0;
            get_rs = rs.get(acc.Id);
            get_rsId = rsId.get(acc.Id);
            get_assco = assco.get(acc.Id);
            get_terr = terr.get(acc.Id);

            system.debug('SalesPerson :'+get_rs);
            system.debug('Assistante :'+get_assco);
            system.debug('GroupRegion :'+get_terr);

            if (get_rs != null) 
            {
                acc.salespersonCode__c = get_rs;
                acc.Responsable_secteur__c = get_rsId;
                i = 1;
            }
            if (get_assco != null)
            {
                acc.assistanteCommerciale__c = get_assco;
                i = 1;
            }
            if (get_terr != null) 
            {
                acc.groupRegion__c = get_terr;
                i = 1;
            }
            
            if (i == 1) 
            {
                AccountsToUpdate.add(acc);
            }
        }
        
        if (!AccountsToUpdate.isEmpty()){
            try {
                System.debug('comptesToUpdate RS, Assco and territory :' + AccountsToUpdate);
                TriggerExecuted.setExecuted();
                update AccountsToUpdate;
                TriggerExecuted.reset();
            } catch (Exception e) {
                System.debug('Error update RS, Assco and territory :' + e );
            }
            
        }
    }
    
}