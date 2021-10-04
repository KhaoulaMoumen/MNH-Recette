trigger cchaCheckTrigger on Cercle_confort_habitat_adh_rent__c (after insert, after delete) {
    list <Account> lstAccount = new list <Account>();
    list <Account> lstAccountToupdate = new list <Account>();
    
    list <Cercle_confort_habitat_adh_rent__c> cchalst = new list <Cercle_confort_habitat_adh_rent__c>();
    Set <Id> AccountIds = new Set <Id> ();
   
    if(trigger.isInsert){
        for (Cercle_confort_habitat_adh_rent__c ccha :trigger.new){
            AccountIds.add(ccha.Compte__c);
            system.debug(' compt '+ccha.Compte__c);
        }
        system.debug(' AccountIds : '+AccountIds);
        lstAccount = [select id , Club_CCH__c FROM Account WHERE id IN:AccountIds];
        
        for(Account act :lstAccount){
            account a = New account(id = act.id ,Club_CCH__c=true)   ;
            lstAccountToupdate.add(a);
              update lstAccountToupdate;
        } 
    }
   
    if(trigger.isDelete){
        
        for(Cercle_confort_habitat_adh_rent__c ccha : Trigger.Old){
            AccountIds.add(ccha.Compte__c);   
        }
        lstAccount = [select id , Club_CCH__c FROM Account WHERE id IN:AccountIds and Club_CCH__c=true ];
         cchalst= [select  Compte__c FROM Cercle_confort_habitat_adh_rent__c WHERE Compte__c IN :AccountIds ];
         integer nbr = 0;
      for(Account act :lstAccount){
            for (Cercle_confort_habitat_adh_rent__c c: cchalst){
                if(c.Compte__c == act.id ){
                    nbr++;   
                  system.debug('up :'+lstAccountToupdate);
                }
            }
                Map <id,integer > rslt = new Map<id,integer> ();
                rslt.put(act.id, nbr);
              system.debug('map :'+rslt);  
         for (Id id : rslt.KeySet()){
             if (rslt.get(id)==0){
                account a = New account(id = act.id ,Club_CCH__c=False)   ;
                lstAccountToupdate.add(a); 
             }
            }
          update lstAccountToupdate;
          }        
      
      
         
    
    }}