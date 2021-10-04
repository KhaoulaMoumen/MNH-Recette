/* 

 * Copyright (C) EuraNov -- All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 * Written by Catherine DELEGLISE <catherine@euranov.com>, sept 2019
 */
public with sharing class EUR05_AssurancesPATriggered{
    public EUR05_AssurancesPATriggered(List<Assurances__c> assurancessProspectAdherent,Boolean isInsertUpdate) {

        //compter le nombre de qualifications associée au compte et cocher la case nb_assur_valides__c sur le compte/le prospect
        List<Account> comptesToUpdate = new List<Account>();
        List<Lead> prospectsToUpdate = new List<Lead>();
        List<id> assursPAid = new List<id>();
        Map<Id,Integer> deletedAssurLead = new Map<Id,Integer>();
        Map<Id,Integer> deletedAssurAccount = new Map<Id,Integer>();

        // DECREMENT THE NUMBER OF ASSURANCES IN THE ACCOUNTS - DELETE CASE
        for (Assurances__c assurancesPA : assurancessProspectAdherent) {
            if (assurancesPA.Compte__c != null) {
                assursPAid.add(assurancesPA.Compte__c);
                if(!isInsertUpdate){
                    if(deletedAssurAccount.containsKey(assurancesPA.Compte__c)){
                        deletedAssurAccount.put(assurancesPA.Compte__c, deletedAssurAccount.get(assurancesPA.Compte__c)+1);
                    }else{
                        deletedAssurAccount.put(assurancesPA.Compte__c,1);
                    }
                }
			// DECREMENT THE NUMBER OF ASSURANCES IN THE LEADS - DELETE CASE
            } else if (assurancesPA.Prospect__c != null) {
                assursPAid.add(assurancesPA.Prospect__c);
                if(!isInsertUpdate){
                    if(deletedAssurLead.containsKey(assurancesPA.Prospect__c)){
                        deletedAssurLead.put(assurancesPA.Prospect__c, deletedAssurLead.get(assurancesPA.Prospect__c)+1);
                    }else{
                        deletedAssurLead.put(assurancesPA.Prospect__c,1);
                    }
                }
            }
        }
        System.debug('assursPAid :' + assursPAid);
        List<Account> comptes=[Select Id,nb_qualif_valides__c from Account where Id IN : assursPAid];
        List<Lead> leads=[Select Id,nb_qualif_valides__c from Lead where Id IN : assursPAid];
        // GET ALL ASSURANCES AUTORISEES RELATED TO ACCOUNTS AND CONTACTS
        AggregateResult[] assurancesComptesAssocies = [SELECT Compte__c, Count(Id) FROM Assurances__c WHERE Compte__c != null AND Statut__c = 'Autorisée' AND Date_de_fin__c > :date.today() AND Compte__c IN :assursPAid GROUP BY Compte__c];
        AggregateResult[] assurancesProspectsAssocies = [SELECT Prospect__c, Count(Id) FROM Assurances__c WHERE Prospect__c != null AND Statut__c = 'Autorisée' AND Date_de_fin__c > :date.today() AND Prospect__c IN :assursPAid GROUP BY Prospect__c];

        if (assurancesComptesAssocies.size() > 0){
        for (AggregateResult ar : assurancesComptesAssocies){
            Account acc = new Account();
            acc.id = (Id)ar.get('Compte__c');
            // INSERT-UPDATE CASE : CALCULATE THE NUMBER OF VALID ASSURANCES FOR ACCOUNTS
            if(isInsertUpdate){
                acc.nb_assur_valides__c = (Decimal)ar.get('expr0');
             // DELETE CASE : CALCULATE THE NUMBER OF VALID ASSURANCES FOR ACCOUNTS
            }else if(!isInsertUpdate && (Decimal)ar.get('expr0')> 0 ){
                acc.nb_assur_valides__c =  (Decimal)ar.get('expr0') - deletedAssurAccount.get(acc.id);
            }
            comptesToUpdate.add(acc);
        }}else{
            for(Account a : comptes){
                a.nb_qualif_valides__c = 0;
                comptesToUpdate.add(a);
            }
            }

        if (assurancesProspectsAssocies.size() > 0){
        for (AggregateResult ar : assurancesProspectsAssocies){
            Lead prosp = new Lead();
            prosp.Id = (Id) ar.get('Prospect__c');
            // INSERT-UPDATE CASE : CALCULATE THE NUMBER OF VALID ASSURANCES FOR LEADS
            if(isInsertUpdate){
                prosp.nb_assur_valides__c = (Decimal)ar.get('expr0');
            // DELETE CASE : CALCULATE THE NUMBER OF VALID ASSURANCES FOR ACCOUNTS
            }else if(!isInsertUpdate && (Decimal)ar.get('expr0') > 0 ){
                prosp.nb_assur_valides__c =  (Decimal)ar.get('expr0') - deletedAssurLead.get(prosp.id);
            }
            prospectsToUpdate.add(prosp);
        }}else{
            for(Lead l : leads){
                l.nb_qualif_valides__c = 0;
                prospectsToUpdate.add(l);
            }
        }
		// UPDATE ACCOUNTS
        try {
            update comptesToUpdate;
        } catch (Exception e) {
            System.debug('Error :'+ e );
        }
		// UPDATE LEADS
        try {
            update prospectsToUpdate;
        } catch (Exception e) {
            System.debug('Error :'+ e );
        }
    }
}