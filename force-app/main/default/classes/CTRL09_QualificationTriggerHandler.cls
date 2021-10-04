/*
Handler class for trigger that calculate nbr of valid qualifications PA un compte
CreatedBy : MOUMEN Khaoula
@Email : khaoula.moumen@talan.com
CreateDate : 08/12/2020
Remarques : *Based on the old handler class EUR04_QualificationTriggered
*/
public class CTRL09_QualificationTriggerHandler {
    
    public static void calculateNbrQualifications(List<Qualification_prospect_adherent__c> qualificationsPA, Boolean isInsertUpdate) {
        
        List<Account> comptesToUpdate = new List<Account>();
        List<Lead> prospectsToUpdate = new List<Lead>();
        List<id> qualifsPAidA = new List<id>();
        List<id> qualifsPAidL = new List<id>();
        Map<Id,Integer> deletedQualifLead = new Map<Id,Integer>();
        Map<Id,Integer> deletedQualifAccount = new Map<Id,Integer>();
        
        // DECREMENT THE NUMBER OF QUALIFICATIONS IN THE ACCOUNTS - DELETE CASE
        for (Qualification_prospect_adherent__c qualificationPA : qualificationsPA) {
            if (qualificationPA.Compte__c != null) {
                qualifsPAidA.add(qualificationPA.Compte__c);
                if(!isInsertUpdate){
                    if(deletedQualifAccount.containsKey(qualificationPA.Compte__c)){
                        if(qualificationPA.Date_de_fin__c >= date.today()) deletedQualifAccount.put(qualificationPA.Compte__c, deletedQualifAccount.get(qualificationPA.Compte__c)+1);
                    } else if (!deletedQualifAccount.containsKey(qualificationPA.Compte__c) && qualificationPA.Date_de_fin__c >= date.today()) {
                        deletedQualifAccount.put(qualificationPA.Compte__c,1);
                    }
                }
                // DECREMENT THE NUMBER OF QUALIFICATIONS IN THE LEADS - DELETE CASE
            } else if (qualificationPA.Prospect__c != null) {
                qualifsPAidL.add(qualificationPA.Prospect__c);
                if(!isInsertUpdate) {
                    if(deletedQualifLead.containsKey(qualificationPA.Prospect__c)){
                        if(qualificationPA.Date_de_fin__c >= date.today()) deletedQualifLead.put(qualificationPA.Prospect__c, deletedQualifLead.get(qualificationPA.Compte__c)+1);
                    }else if (!deletedQualifLead.containsKey(qualificationPA.Prospect__c) && qualificationPA.Date_de_fin__c >= date.today()){
                        deletedQualifLead.put(qualificationPA.Prospect__c,1);
                    }
                }
            }
        }
        
        List<Account> comptes = [SELECT Id, nb_qualif_valides__c FROM Account WHERE Id IN : qualifsPAidA];
        List<Lead> leads = [SELECT Id, nb_qualif_valides__c FROM Lead WHERE Id IN : qualifsPAidL];
        
        // GET ALL VALID QUALIFICATIONS RELATED TO ACCOUNTS AND CONTACTS
        AggregateResult[] qualifComptesAssocies = [SELECT Compte__c, Count(Id) 
                                                   FROM Qualification_prospect_adherent__c 
                                                   WHERE Compte__c != null AND Date_de_fin__c >= :date.today() AND Compte__c IN :qualifsPAidA 
                                                   GROUP BY Compte__c];
        
        AggregateResult[] qualifProspectsAssocies = [SELECT Prospect__c, Count(Id) 
                                                     FROM Qualification_prospect_adherent__c 
                                                     WHERE Prospect__c != null AND Date_de_fin__c >= :date.today() AND Prospect__c IN :qualifsPAidL 
                                                     GROUP BY Prospect__c];
        
        if (qualifComptesAssocies.size() > 0) {
            for (AggregateResult ar : qualifComptesAssocies) {
                
                Account acc = new Account();
                acc.id = (Id)ar.get('Compte__c');
                
                // INSERT-UPDATE CASE : CALCULATE THE NUMBER OF VALID QUALIFICATIONS FOR ACCOUNTS
                if(isInsertUpdate) {
                    acc.nb_qualif_valides__c = (Decimal)ar.get('expr0');
                    
                    // DELETE CASE : CALCULATE THE NUMBER OF VALID QUALIFICATIONS FOR ACCOUNTS
                } else if(!isInsertUpdate && (Decimal)ar.get('expr0')> 0 ) {
                    acc.nb_qualif_valides__c =  (Decimal)ar.get('expr0') - deletedQualifAccount.get(acc.id);
                }
                comptesToUpdate.add(acc);
            }
        } else {
            for(Account a : comptes){
                a.nb_qualif_valides__c = 0;
                comptesToUpdate.add(a);
            }
        }
        
        if (qualifProspectsAssocies.size() > 0) {
            for (AggregateResult ar : qualifProspectsAssocies){ 
                
                Lead prosp = new Lead();
                prosp.Id = (Id) ar.get('Prospect__c');
                
                // INSERT-UPDATE CASE : CALCULATE THE NUMBER OF VALID QUALIFICATIONS FOR LEADS
                if(isInsertUpdate){
                    prosp.nb_qualif_valides__c = (Decimal)ar.get('expr0');
                    
                    // DELETE CASE : CALCULATE THE NUMBER OF VALID QUALIFICATIONS FOR LEADS
                } else if(!isInsertUpdate && (Decimal)ar.get('expr0') > 0 ) {
                    prosp.nb_qualif_valides__c =  (Decimal)ar.get('expr0') - deletedQualifLead.get(prosp.id);
                }
                prospectsToUpdate.add(prosp);
            }
        } else {
            for(Lead l : leads){
                l.nb_qualif_valides__c = 0;
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