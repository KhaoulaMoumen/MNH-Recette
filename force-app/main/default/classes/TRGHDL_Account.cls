public with sharing class TRGHDL_Account {

    public void beforeInsert(List < Account > accounts) {
        List<Account> accountsDataxessToSynerciel = new List<Account> ();
        for(Account acc : accounts){
            if (acc.Derniere_mise_jour_Altares__c != null)
            {
                accountsDataxessToSynerciel.add(acc);
            }

        }    
        if(accountsDataxessToSynerciel.size() > 0) {
            CTRL02_AccountDataxess.replicateDataxessToSynercielFields(accountsDataxessToSynerciel); 
        } 



    }
    public void beforeUpdate(List < Account > lstAccNew , Map<Id,Account> mapAccOld) {

        List<Account> accountsDataxessToSynerciel = new List<Account> ();

        for(Account acc : lstAccNew){
            if ( acc.Derniere_mise_jour_Altares__c != null && acc.Derniere_mise_jour_Altares__c != mapAccOld.get(acc.Id).Derniere_mise_jour_Altares__c && acc.Profil__c=='Adhérent'){
                accountsDataxessToSynerciel.add(acc);
            }
        }   
        if(accountsDataxessToSynerciel.size() > 0) {
            CTRL02_AccountDataxess.replicateDataxessToSynercielFields(accountsDataxessToSynerciel); 
        }     
    }

    public void afterUpdate(List < Account > lstAccNew , Map<Id,Account> mapAccOld){
      
   
        List<Account> accountsToNotify= new List<Account> ();

        for(Account acc : lstAccNew){
            if ( acc.Entreprise_active__c != null && acc.Entreprise_active__c != mapAccOld.get(acc.Id).Entreprise_active__c){
                accountsToNotify.add(acc);
                
            }
        }   
        if (accountsToNotify.size() > 0){
            CTRL02_AccountDataxess.notifyOwnerChangeStateByMail(accountsToNotify);
            CTRL02_AccountDataxess.notifyOwnerChangeStateByBell(accountsToNotify);
        }
    }

}