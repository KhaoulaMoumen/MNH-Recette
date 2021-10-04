/*
Classe that calculate nbr of factures impayes et regles sur un compte
CreatedBy : MOUMEN Khaoula
@Email : khaoula.moumen@talan.com
CreateDate : 12/03/2020
*/
public class CTRL03_CommandeFactureHandler {
    
	 public static void CalculateNbrFactures(List<Facture__c> factures, Integer operation) {
        
        List<Account> accToUpdate = new List<Account>();
        Set<Id> accountIds = new Set<Id>();
        Map<Id, List<Facture__c>> mapFactures = new Map<Id, List<Facture__c>>();
        Map<Id,Account> mapAccounts = new Map<Id,Account>();
        Map<Id,Facture__c> mapOldFactures = new Map<Id,Facture__c>();
        
         for(Facture__c f : factures) {
             accountIds.add(f.Nom_du_compte__c);    
         }       
        
        List<Account> accounts = [SELECT Id, Nbr_Factures__c, Nbr_Factures_En_Regle__c, Nbr_Factures_Impayes__c, (SELECT Id,Etat_de_la_facture__c,Date_d_ch_ance__c,Montant_TTC_facture__c,Montant_TTC_r_gl__c,Nom_du_compte__c FROM Commande_Factures__r)
                                  FROM Account 
                                  WHERE Id IN :accountIds
                                 ];    
        
        for(Account acc : accounts) {
            mapFactures.put(acc.Id, acc.Commande_Factures__r);
        } 
        for(Account acc : [SELECT Id, Nbr_Factures__c, Nbr_Factures_En_Regle__c, Nbr_Factures_Impayes__c FROM Account WHERE Id IN :accountIds])
        {
            mapAccounts.put(acc.Id,acc);
            system.debug('account****'+acc);
        } 
        
        for(Facture__c newF : factures) {
            if(newF.Nom_du_compte__c != NULL){
            Account account = mapAccounts.get(newF.Nom_du_compte__c);
            
            
            if(operation == 0) {
                account.Nbr_Factures__c++;
                if(newF.Etat_de_la_facture__c == 'Impayée')
                {
                    account.Nbr_Factures_Impayes__c++;
                }
                else if(newF.Etat_de_la_facture__c == 'Paid' || newF.Etat_de_la_facture__c == 'En attente de paiement' || newF.Etat_de_la_facture__c == 'Cancelled_with_asset')
                {
                    account.Nbr_Factures_En_Regle__c++;
                }
                    accToUpdate.add(account);
            }
                   
            else if(operation == 1 || operation == 2)
            {
                List<Facture__c> facturesUpdate = mapFactures.get(newF.Nom_du_compte__c);
                account.Nbr_Factures_Impayes__c = 0;
                account.Nbr_Factures_En_Regle__c = 0;
                
                for(Facture__c f : facturesUpdate){
                    if(f.Etat_de_la_facture__c == 'Impayée')
                    {
                        account.Nbr_Factures_Impayes__c++;
                    }
                    else if(f.Etat_de_la_facture__c == 'Paid' || f.Etat_de_la_facture__c == 'En attente de paiement' || f.Etat_de_la_facture__c == 'Cancelled_with_asset')
                    {
                        account.Nbr_Factures_En_Regle__c++;
                    }
                    if(operation == 2) account.Nbr_Factures__c--;
                }
                accToUpdate.add(account);
            }
        }
        }
        if(accToUpdate.size() >0) {
            try {
                System.debug('comptesToUpdate :' + accToUpdate);
                update accToUpdate;
            } catch (Exception e) {
                System.debug('Error update accounts:' + e );
            }
        }
    }
    
    public static List<Facture__c> fillAccountField(List<Facture__c> factures){
        Set<Id> quoteIds = new Set<Id>();
        
        for(Facture__c facture : factures) {
            if(facture.Commande_Vente__c != NULL) quoteIds.add(facture.Commande_Vente__c);
        }
        List<Quote> quotes = [SELECT Id, Opportunity.AccountId FROM Quote WHERE Id IN :quoteIds];
        Map<Id,Quote> mapQuotes = new Map<Id,Quote>();
        
        for(Quote q : quotes) mapQuotes.put(q.Id, q);
        
        for(Facture__c f : factures){
            if(f.Nom_du_compte__c == NULL) {
                Quote q = mapQuotes.get(f.Commande_Vente__c);
                system.debug('quoooote ****'+q.Opportunity.AccountId);
                f.Nom_du_compte__c = q.Opportunity.AccountId;
            }
        }
        return factures;
    }
}