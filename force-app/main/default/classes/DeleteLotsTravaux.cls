/* 

 * Copyright (C) EuraNov -- All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 * Written by Nathan Martin <nathan@euranov.com>, May 2019

 */
public with sharing class DeleteLotsTravaux {
    public DeleteLotsTravaux(List<Qualification_prospect_adherent__c> myQualificationsPA) {

    System.debug('qualificationsPA : ' + myQualificationsPA);

    // get prospects and adherents linked to the qualification
    List<Id> adherentsWithLotsTravauxToDelete = new List<Id>();
    List<Id> prospectsWithLotsTravauxToDelete = new List<Id>();
    
    for (Qualification_prospect_adherent__c q : myQualificationsPA) {
        System.debug('ID PP' + q.Prospect__c);
        if (q.Prospect__c == null) {
            // GET QUALIFICATIONS RELATED TO ACCOUNT
            adherentsWithLotsTravauxToDelete.add(q.Compte__c);
        } else {
            // GET QUALIFICATIONS RELATED TO LEAD
            prospectsWithLotsTravauxToDelete.add(q.Prospect__c);
        }
    }
        System.debug('adherentsWithLotsTravauxToDelete : ' + adherentsWithLotsTravauxToDelete);
        System.debug('prospectsWithLotsTravauxToDelete : ' + prospectsWithLotsTravauxToDelete);
        
        // get all ids linked to Lots Travaux to delete
        List<Account> adherents = new List<Account>([SELECT Id FROM Account WHERE Id IN :adherentsWithLotsTravauxToDelete]);
        List<Lead> prospects = new List<Lead>([SELECT Id FROM Lead WHERE Id IN :prospectsWithLotsTravauxToDelete]);
        // get lots travaux to delete 
        List<Lots_Travaux__c> lotsTravauxToDelete = new List<Lots_Travaux__c>([SELECT Id FROM Lots_Travaux__c WHERE (Compte__r.Id IN :Adherents AND Qualification_prospect_adh_rent__r.Id = null) OR (Prospect__r.Id IN :Prospects AND Qualification_prospect_adh_rent__r.Id = null)]);
        // DELETE LOTS DE TRAVAUX
        deleteLotsTravaux(lotsTravauxToDelete);
    }

    // To delete lots travaux in sales force data base
    private void deleteLotsTravaux(List<Lots_Travaux__c> toDelete) {
        try {
            delete toDelete;
            System.debug('GOOD' + toDelete);
        } catch (DmlException e) {
            System.debug('The following exception has occurred in lotsTravauxFromAdherentsToDelete: ' + e.getMessage());
        }       
    }
}