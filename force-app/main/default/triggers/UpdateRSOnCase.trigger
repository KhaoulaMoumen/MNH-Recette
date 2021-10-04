trigger UpdateRSOnCase on Case (after insert, after update) {
     if (TriggerExecuted.getExecuted() == 0) {
     
         List<Case> c = Trigger.New;
         List<Id> acc = new List<Id>();
         
         for(Case cs : c){
             acc.add(cs.AccountId);
         }
         
         List<AccountUserTerritory2View> aut_rs = [SELECT AccountId,UserId FROM AccountUserTerritory2View WHERE AccountId IN :acc and RoleInTerritory2 = 'Responsable de Secteur'];
         List<AccountUserTerritory2View> aut_rr = [SELECT AccountId,UserId FROM AccountUserTerritory2View WHERE AccountId IN :acc and RoleInTerritory2 = 'Responsable de région'];
         Map<Id,Id> map_rs = new Map<Id,Id>();
         Map<Id,Id> map_rr = new Map<Id,Id>();
         Id get_rs;
         Id get_rr;
         Integer i;
         List<Case> toUpdate = new List<Case>();
         
         for(AccountUserTerritory2View aut : aut_rs) {
            map_rs.put(aut.AccountId,aut.UserId);
         }
        
         for(AccountUserTerritory2View aut : aut_rr) {
             map_rr.put(aut.AccountId,aut.UserId);
         }
         
         List<Case> new_case = [SELECT Id,Nom_du_RS__c,Nom_du_RR__c,AccountId FROM Case WHERE Id IN :c];
         
         for(Case cs : new_case) {
         
            i = 0;
            if (cs.AccountId != null) {
                get_rs = map_rs.get(cs.AccountId);
                get_rr = map_rr.get(cs.AccountId);
            
                if (get_rs != null) {
                    cs.Nom_du_RS__c = get_rs;
                    i = 1;
                }
                
                if (get_rr != null) {
                    cs.Nom_du_RR__c = get_rr;
                    i = 1;
                }
            }
            
            if (i == 1) {
                toUpdate.add(cs);
            }
         }
         
         if (!toUpdate.isEmpty()){
            //to avoid trigger reexecution
            TriggerExecuted.setExecuted();
            try {
                System.debug('reclamationsToUpdate RS and RR :' + toUpdate);
                update toUpdate;
                TriggerExecuted.reset();
            } catch (Exception e) {
                System.debug('Error update RS and RR :' + e );
            }
                
        }
        
     }
}