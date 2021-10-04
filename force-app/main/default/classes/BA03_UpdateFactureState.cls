/* 
 * Written by Khaoula Moumen <khaoula.moumen@talan.com>, April 2020 
*/
global class BA03_UpdateFactureState implements Database.Batchable<sObject>, Database.Stateful {
    
    public String query;
    private List<Facture__c> factures;
    List<Facture__c> facturesToUpdate = new List<Facture__c>();
    Date TODAY = Date.today();
    
    global Database.QueryLocator start(Database.BatchableContext bc){
        
        this.factures = new List<Facture__c>();
        
        this.query = 'SELECT id, Etat_de_la_facture__c, Date_d_envoi_de_la_facture__c, Date_d_ch_ance__c, Montant_TTC_facture__c, Montant_TTC_r_gl__c FROM Facture__c';
        
        return Database.getQueryLocator(this.query);
    }
    
    global void execute(Database.BatchableContext BC, List<Facture__c> scope){
        
        for(Facture__c fact : scope)
        {
            if(fact.Date_d_envoi_de_la_facture__c != NULL && fact.Montant_TTC_facture__c > 0 && fact.Montant_TTC_r_gl__c < fact.Montant_TTC_facture__c && fact.Date_d_ch_ance__c < TODAY)
            {
                if(fact.Etat_de_la_facture__c != 'Impayée') facturesToUpdate.add(new Facture__c(id = fact.id, Etat_de_la_facture__c = 'Impayée')); 
            }
            else if(fact.Date_d_envoi_de_la_facture__c != NULL && fact.Montant_TTC_facture__c > 0 && fact.Montant_TTC_r_gl__c < fact.Montant_TTC_facture__c && fact.Date_d_ch_ance__c >= TODAY)
            {
                if(fact.Etat_de_la_facture__c != 'En attente de paiement') facturesToUpdate.add(new Facture__c(id = fact.id, Etat_de_la_facture__c = 'En attente de paiement')); 
            }
        }
        try 
        {
            
            System.debug('factures updated :' + facturesToUpdate);
            update facturesToUpdate;
        } 
        catch (Exception e) 
        {
            System.debug('Error update :' + e );
        }
    }
    
    global void finish(Database.BatchableContext BC){
        
    }
}