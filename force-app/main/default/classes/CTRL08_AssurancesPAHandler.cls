/*
Handler class for trigger that calculate nbr of valid assurances PA un compte
CreatedBy : MOUMEN Khaoula
@Email : khaoula.moumen@talan.com
CreateDate : 08/12/2020
Remarques : *Based on the old handler class EUR05_AssurancesPATriggered
*/
public class CTRL08_AssurancesPAHandler {
    
    public static void calculateNbrAssurancesPA(List<Assurances__c> assurancesPA, Boolean isInsertUpdate) {
        
        List<Account> comptesToUpdate = new List<Account>();
        List<Lead> prospectsToUpdate = new List<Lead>();
        List<id> assursPAidA = new List<id>();
        List<id> assursPAidL = new List<id>();
        Map<Id,Integer> deletedAssurLead = new Map<Id,Integer>();
        Map<Id,Integer> deletedAssurAccount = new Map<Id,Integer>();
        
        
        for (Assurances__c assPA : assurancesPA) {
            
            // DECREMENT THE NUMBER OF ASSURANCES IN THE ACCOUNTS - DELETE CASE
            if (assPA.Compte__c != null) {
                assursPAidA.add(assPA.Compte__c);
                if(!isInsertUpdate) {
                    if(deletedAssurAccount.containsKey(assPA.Compte__c)){
                        if(assPA.Date_de_fin__c >= date.today() && (assPA.Statut__c == 'Autorisée' || assPA.Statut__c == 'Tolérée')) deletedAssurAccount.put(assPA.Compte__c, deletedAssurAccount.get(assPA.Compte__c)+1);
                    } else if(!deletedAssurAccount.containsKey(assPA.Compte__c) && assPA.Date_de_fin__c >= date.today() && (assPA.Statut__c == 'Autorisée' || assPA.Statut__c == 'Tolérée')) {
                        deletedAssurAccount.put(assPA.Compte__c,1);
                    }
                }
            } 
            // DECREMENT THE NUMBER OF ASSURANCES IN THE LEADS - DELETE CASE
            else if (assPA.Prospect__c != null) {
                assursPAidL.add(assPA.Prospect__c);
                if(!isInsertUpdate) {
                    if(deletedAssurLead.containsKey(assPA.Prospect__c)){
                        if(assPA.Date_de_fin__c >= date.today() && (assPA.Statut__c == 'Autorisée' || assPA.Statut__c == 'Tolérée')) deletedAssurLead.put(assPA.Prospect__c, deletedAssurLead.get(assPA.Prospect__c)+1);
                    } else if(!deletedAssurLead.containsKey(assPA.Prospect__c) && assPA.Date_de_fin__c >= date.today() && (assPA.Statut__c == 'Autorisée' || assPA.Statut__c == 'Tolérée')) {
                        deletedAssurLead.put(assPA.Prospect__c,1);
                    }
                }
            }
        }
        
        // INSERT/UPDATE CASE
        List<Account> comptes = [SELECT Id, nb_assur_valides__c FROM Account WHERE Id IN : assursPAidA];
        List<Lead> leads = [Select Id, nb_assur_valides__c FROM Lead WHERE Id IN : assursPAidL];
        
        // GET ALL ASSURANCES VALIDES RELATED TO ACCOUNTS AND LEADS
        AggregateResult[] assurancesComptesAssocies = [SELECT Compte__c, Count(Id) 
                                                       FROM Assurances__c 
                                                       WHERE Compte__c != null AND (Statut__c = 'Autorisée' OR Statut__c = 'Tolérée') AND Date_de_debut__c <= :date.today() AND Date_de_fin__c >= :date.today() AND Compte__c IN :assursPAidA 
                                                       GROUP BY Compte__c];
        
        AggregateResult[] assurancesProspectsAssocies = [SELECT Prospect__c, Count(Id) 
                                                         FROM Assurances__c 
                                                         WHERE Prospect__c != null AND (Statut__c = 'Autorisée' OR Statut__c = 'Tolérée') AND Date_de_debut__c <= :date.today() AND Date_de_fin__c >= :date.today() AND Prospect__c IN :assursPAidL 
                                                         GROUP BY Prospect__c];
        
        if (assurancesComptesAssocies.size() > 0) {
            for (AggregateResult ar : assurancesComptesAssocies) {
                
                Account acc = new Account();
                acc.id = (Id)ar.get('Compte__c');
                
                // INSERT-UPDATE CASE : CALCULATE THE NUMBER OF VALID ASSURANCES FOR ACCOUNTS
                if(isInsertUpdate) {
                    acc.nb_assur_valides__c = (Decimal)ar.get('expr0');
                }
                // DELETE CASE : CALCULATE THE NUMBER OF VALID ASSURANCES FOR ACCOUNTS
                else if(!isInsertUpdate) {
                    system.debug('number of assurances'+(Decimal)ar.get('expr0'));
                    system.debug('number of deleted assurances'+deletedAssurAccount.get(acc.id));
                     acc.nb_assur_valides__c =  (Decimal)ar.get('expr0') - deletedAssurAccount.get(acc.id);
                }
                comptesToUpdate.add(acc);
            }
        } 
        else {
            // NO ASSURANCEPA IS VALID 
            for(Account a : comptes){
                a.nb_assur_valides__c = 0;
                comptesToUpdate.add(a);
            }
        }
        
        if (assurancesProspectsAssocies.size() > 0){
            for (AggregateResult ar : assurancesProspectsAssocies){
                
                Lead prosp = new Lead();
                prosp.Id = (Id) ar.get('Prospect__c');
                
                // INSERT-UPDATE CASE : CALCULATE THE NUMBER OF VALID ASSURANCES FOR LEADS
                if(isInsertUpdate) {
                    prosp.nb_assur_valides__c = (Decimal)ar.get('expr0');
                   
                // DELETE CASE : CALCULATE THE NUMBER OF VALID ASSURANCES FOR LEADS
                }else if(!isInsertUpdate && (Decimal)ar.get('expr0') > 0 ){
                    prosp.nb_assur_valides__c =  (Decimal)ar.get('expr0') - deletedAssurLead.get(prosp.id);
                }
                prospectsToUpdate.add(prosp);
            }
        } else {
                for(Lead l : leads){
                    l.nb_assur_valides__c = 0;
                    prospectsToUpdate.add(l);
                }
            }
        
        // UPDATE ACCOUNTS
        try {
            update comptesToUpdate;
        } catch (Exception e) {
            System.debug('Error Update Account :'+ e );
        }
		// UPDATE LEADS
        try {
            update prospectsToUpdate;
        } catch (Exception e) {
            System.debug('Error Update Lead :'+ e );
        }
    }
    
}