global class BATCH_TEST implements Database.Batchable<sObject>, Database.Stateful {
    public String query;
    global Database.QueryLocator start(Database.BatchableContext bc){
        
        this.query = 'SELECT Id, email FROM Lead WHERE NOT(email LIKE \'%invalid\')';
        
        return Database.getQueryLocator(this.query);
    }
    
    global void execute(Database.BatchableContext BC, List<Lead> scope){

        for(Lead l : scope) {
			if(l.email != null) l.email = l.email+'.invalid';       
        }
        update scope;
    }
/*  REFRESH CONTACT EMAIL
global class BATCH_TEST implements Database.Batchable<sObject>, Database.Stateful {
    public String query;
    global Database.QueryLocator start(Database.BatchableContext bc){
        
        this.query = 'SELECT Id, email FROM Contact WHERE NOT(email LIKE \'%invalid\')';
        
        return Database.getQueryLocator(this.query);
    }
    
    global void execute(Database.BatchableContext BC, List<Contact> scope){

        for(Contact con : scope) {
			if(con.email != null) con.email = con.email+'.invalid';       
        }
        update scope;
    }
    */
/*  REFRESH ACCOUNT EMAIL
global class BATCH_TEST implements Database.Batchable<sObject>, Database.Stateful {
    public String query;
    global Database.QueryLocator start(Database.BatchableContext bc){
        
        this.query = 'SELECT Id, email__c FROM Account WHERE NOT(email__c LIKE \'%invalid\')';
        
        return Database.getQueryLocator(this.query);
    }
    
    global void execute(Database.BatchableContext BC, List<Account> scope){

        for(Account acc : scope) {
			if(acc.email__c != null) acc.email__c = acc.email__c+'.invalid';       
        }
        update scope;
    }
*/
/* Batch pour la RDD 
global class BATCH_TEST implements Database.Batchable<sObject>, Database.Stateful {
    public String query;
    global Database.QueryLocator start(Database.BatchableContext bc){
        
        this.query = 'SELECT Id, salespersonCode__c, assistanteCommerciale__c, groupRegion__c,BillingPostalCode,Responsable_secteur__c FROM Account';
        
        return Database.getQueryLocator(this.query);
    }
    
    global void execute(Database.BatchableContext BC, List<Account> scope){
        Map<Id,String> rs = new Map<Id,String>();
        Map<Id,Id> rsId = new Map<Id,Id>();
        
        List<Account> AccountsToUpdate = new List<Account>();
        
        String get_rs;
        Id get_rsId;
        
        List<AccountUserTerritory2View> aut_rs = [SELECT AccountId, User.Email, UserId
                                                  FROM AccountUserTerritory2View 
                                                  WHERE AccountId IN :SCOPE AND RoleInTerritory2 = :System.Label.Responsable_Secteur
                                                 ];
        
        for(AccountUserTerritory2View aut : aut_rs) {
            rs.put(aut.AccountId, aut.User.Email);
            rsId.put(aut.AccountId, aut.UserId);
        }
        
        for(Account acc : scope) {
			get_rs = rs.get(acc.Id);
            get_rsId = rsId.get(acc.Id);
            
            if (get_rs != null) 
            {
                acc.salespersonCode__c = get_rs;
                acc.Responsable_secteur__c = get_rsId;
            }                 
            AccountsToUpdate.add(acc);            
        }
        update AccountsToUpdate;
    }

 */
/* Batch pour la RDD 
global class BATCH_TEST implements Database.Batchable<sObject>, Database.Stateful {
    public String query;
    global Database.QueryLocator start(Database.BatchableContext bc){
        
        this.query = 'SELECT Id, Nbr_Factures__c, Nbr_Factures_En_Regle__c, Nbr_Factures_Impayes__c, (SELECT Id,Montant_TTC_r_gl__c,Montant_TTC_facture__c,Etat_de_la_facture__c,Nom_du_compte__c FROM Commande_Factures__r) FROM Account';
        
        return Database.getQueryLocator(this.query);
    }
    
    global void execute(Database.BatchableContext BC, List<Account> scope){
        List<Account> accToUpdate = new List<Account>();
        List<Facture__c> facturesUpdated = new List<Facture__c>();
        Set<Id> accountIds = new Set<Id>();
        Map<Id, List<Facture__c>> mapFactures = new Map<Id, List<Facture__c>>();
        Map<Id,Account> mapAccounts = new Map<Id,Account>();
        
        for(Account account : scope) {
            account.Nbr_Factures__c =0;
            account.Nbr_Factures_Impayes__c=0;        
            account.Nbr_Factures_En_Regle__c=0;
            List<Facture__c> factures = account.Commande_Factures__r;
            for(Facture__c facture : factures){
                account.Nbr_Factures__c++;
                if(facture.Etat_de_la_facture__c == 'Impayée')
                {
                    account.Nbr_Factures_Impayes__c++;
                }
                else if(facture.Etat_de_la_facture__c == 'Paid' || facture.Etat_de_la_facture__c == 'En attente de paiement' || facture.Etat_de_la_facture__c == 'Cancelled_with_asset')
                {
                    account.Nbr_Factures_En_Regle__c++;
                } 
				facturesUpdated.add(facture);
            }
            accToUpdate.add(account);
            
            
        }
        if(!TEST.isRunningTest()) update accToUpdate;
        update facturesUpdated;
    }*/
    /*    public String query;
global Database.QueryLocator start(Database.BatchableContext bc){

this.query = 'SELECT Id,Nbr_contacts__c,(Select Id from Contacts) FROM Account';

return Database.getQueryLocator(this.query);
}

global void execute(Database.BatchableContext BC, List<Account> scope){
List<Account> accountListToUpdate = new List<Account>();

for(Account acc : scope){
List<Contact> contactList = acc.Contacts;
acc.Nbr_contacts__c = contactList.size();
accountListToUpdate.add(acc);
}
update accountListToUpdate;
}*/
    global void finish(Database.BatchableContext BC){
        
    }
    
}