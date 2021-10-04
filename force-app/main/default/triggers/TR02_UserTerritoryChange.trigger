/*
Trigger that updates technical fields on account when territoryModel changes user assignment
CreatedBy : MOUMEN Khaoula
@Email : khaoula.moumen@talan.com
CreateDate : 10/02/2020
*/
trigger TR02_UserTerritoryChange on UserTerritory2Association (after insert, after update) {
    
    Set<Id> territoryIds = new Set<Id>();
    Set<Id> accountIds = new Set<Id>();
    List<ObjectTerritory2Association> objAssociations = new List<ObjectTerritory2Association>();
    List<Account> accounts = new List<Account>();
    List<Account> accountsUpdate = new List<Account>();
    
    if(Trigger.isAfter && (Trigger.isInsert || Trigger.isUpdate)) {
        
        for(UserTerritory2Association userTA : Trigger.New) {
            territoryIds.add(userTA.Territory2Id);
        }
        
        if(!territoryIds.isEmpty()) {
            objAssociations = [SELECT Id, ObjectId 
                               FROM ObjectTerritory2Association 
                               WHERE Territory2Id IN :territoryIds
                              ];
            
            for(ObjectTerritory2Association objAsso : objAssociations) {
                accountIds.add(objAsso.ObjectId);
            }
            
            if(!accountIds.isEmpty()) {
                
                // re-assign salesperson and assistant commercial and groupRegion to accounts 
                CTRL01_AccountTerritorySettings.manageAccTerritories(accountIds);
            }
        } 
    }
}