/*
Trigger that calculate nbr of contacts after delete on related account
CreatedBy : MOUMEN Khaoula
@Email : khaoula.moumen@talan.com
CreateDate : 16/03/2020
*/
trigger TR04_Contact on Contact (after delete) {
    List<Account> accoutToUpdate = new List<Account>();
    Map<Id,Integer> mapAccountIds = new Map<Id,Integer>();
    Set<Id> accIds = new Set<Id>();   
    
    if(Trigger.isAfter && Trigger.isDelete) {
        for(Contact con : Trigger.old){
            accIds.add(con.AccountId);
            Integer nbr = mapAccountIds.get(con.AccountId);
            if(nbr != NULL) mapAccountIds.put(con.AccountId,nbr++);
            else mapAccountIds.put(con.AccountId,1);
        }
        List<Account> accounts = [SELECT Id,Nbr_contacts__c FROM Account WHERE Id IN :accIds];
        for(Account acc : accounts){
            if(acc.Nbr_contacts__c==NULL){
              acc.Nbr_contacts__c=1;  
            }
            acc.Nbr_contacts__c = acc.Nbr_contacts__c - mapAccountIds.get(acc.Id); 
            //acc.Nbr_contacts__c--;
            system.debug('nbr con'+acc.Nbr_contacts__c);
            accoutToUpdate.add(acc);
               
        }
        if(accoutToUpdate.size() > 0){
            update accoutToUpdate;
        }
    }
}