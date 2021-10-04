/* 

 * Copyright (C) EuraNov -- All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 * Written by Catherine DELEGLISE <catherine@euranov.com>, sept 2019

 */
public with sharing class EUR04_QualificationTriggered {
    public EUR04_QualificationTriggered(List<Qualification_prospect_adherent__c> qualificationsProspectAdherent,Boolean isInsertUpdate) {

        //compter le nombre de qualifications associée au compte et cocher la case nb_qualif_valides__c sur le compte/le prospect
        List<Account> comptesToUpdate = new List<Account>();
        List<Lead> prospectsToUpdate = new List<Lead>();
        List<id> qualifsPAid = new List<id>();
        Map<Id,Integer> deletedQualifLead = new Map<Id,Integer>();
        Map<Id,Integer> deletedQualifAccount = new Map<Id,Integer>();

         // DECREMENT THE NUMBER OF QUALIFICATIONS IN THE ACCOUNTS - DELETE CASE
        for (Qualification_prospect_adherent__c qualificationPA : qualificationsProspectAdherent) {
            if (qualificationPA.Compte__c != null) {
                qualifsPAid.add(qualificationPA.Compte__c);
                if(!isInsertUpdate){
                    if(deletedQualifAccount.containsKey(qualificationPA.Compte__c)){
                        deletedQualifAccount.put(qualificationPA.Compte__c, deletedQualifAccount.get(qualificationPA.Compte__c)+1);
                    }else{
                        deletedQualifAccount.put(qualificationPA.Compte__c,1);
                    }
                }
			// DECREMENT THE NUMBER OF QUALIFICATIONS IN THE LEADS - DELETE CASE
            } else if (qualificationPA.Prospect__c != null) {
                qualifsPAid.add(qualificationPA.Prospect__c);
                if(!isInsertUpdate){
                    if(deletedQualifLead.containsKey(qualificationPA.Prospect__c)){
                        deletedQualifLead.put(qualificationPA.Prospect__c, deletedQualifLead.get(qualificationPA.Compte__c)+1);
                    }else{
                        deletedQualifLead.put(qualificationPA.Prospect__c,1);
                    }
                }
            }
        }
        System.debug('qualifsPAid :' + qualifsPAid);

        List<Account> comptes=[Select Id,nb_qualif_valides__c from Account where Id IN : qualifsPAid];
        List<Lead> leads=[Select Id,nb_qualif_valides__c from Lead where Id IN : qualifsPAid];
        // GET ALL VALID QUALIFICATIONS RELATED TO ACCOUNTS AND CONTACTS
        AggregateResult[] qualifComptesAssocies = [SELECT Compte__c, Count(Id) FROM Qualification_prospect_adherent__c WHERE Compte__c != null AND Date_de_fin__c > :date.today() AND Compte__c IN :qualifsPAid GROUP BY Compte__c];
        AggregateResult[] qualifProspectsAssocies = [SELECT Prospect__c, Count(Id) FROM Qualification_prospect_adherent__c WHERE Prospect__c != null AND Date_de_fin__c > :date.today() AND Prospect__c IN :qualifsPAid GROUP BY Prospect__c];

        if (qualifComptesAssocies.size() > 0){
        for (AggregateResult ar : qualifComptesAssocies){
            Account acc = new Account();
            acc.id = (Id)ar.get('Compte__c');
            // INSERT-UPDATE CASE : CALCULATE THE NUMBER OF VALID QUALIFICATIONS FOR ACCOUNTS
            if(isInsertUpdate){
                system.debug('je suis là');
                acc.nb_qualif_valides__c = (Decimal)ar.get('expr0');
            // DELETE CASE : CALCULATE THE NUMBER OF VALID QUALIFICATIONS FOR ACCOUNTS
            }else if(!isInsertUpdate && (Decimal)ar.get('expr0')> 0 ){
                acc.nb_qualif_valides__c =  (Decimal)ar.get('expr0') - deletedQualifAccount.get(acc.id);
            }
            comptesToUpdate.add(acc);
        }}else{
            for(Account a : comptes){
                a.nb_qualif_valides__c = 0;
                comptesToUpdate.add(a);
            }
            }
            
        if (qualifProspectsAssocies.size() > 0){
        for (AggregateResult ar : qualifProspectsAssocies){
            Lead prosp = new Lead();
            prosp.Id = (Id) ar.get('Prospect__c');
            // INSERT-UPDATE CASE : CALCULATE THE NUMBER OF VALID QUALIFICATIONS FOR LEADS
            if(isInsertUpdate){
                prosp.nb_qualif_valides__c = (Decimal)ar.get('expr0');
            // DELETE CASE : CALCULATE THE NUMBER OF VALID QUALIFICATIONS FOR LEADS
            }else if(!isInsertUpdate && (Decimal)ar.get('expr0') > 0 ){
                prosp.nb_qualif_valides__c =  (Decimal)ar.get('expr0') - deletedQualifLead.get(prosp.id);
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