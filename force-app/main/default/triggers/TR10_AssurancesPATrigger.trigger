/*
Trigger that calculate nbr of valid assurances PA on account
CreatedBy : MOUMEN Khaoula
@Email : khaoula.moumen@talan.com
CreateDate : 08/12/2020
Remarques : *Based on the old trigger EUR05_AssurancesPATrigger
*/
trigger TR10_AssurancesPATrigger on Assurances__c (after insert, after update, before delete) {
    
    if(Trigger.isAfter && Trigger.isInsert) {
        System.debug('Déclenchement du trigger CTRL08_AssurancesPAHandler sur insertion des assurances prospect adhérent');
        CTRL08_AssurancesPAHandler.calculateNbrAssurancesPA(Trigger.New, true);
    }
    
    if(Trigger.isAfter && Trigger.isUpdate) {
        System.debug('Déclenchement du trigger CTRL08_AssurancesPAHandler sur MAJ des assurances prospect adhérent');
        List<Assurances__c> assuToUpdate = new List<Assurances__c>();
        for(Assurances__c assurance : Trigger.New) {
            if(Trigger.oldMap.get(assurance.Id).Statut__c != Trigger.newMap.get(assurance.Id).Statut__c || Trigger.oldMap.get(assurance.Id).Date_de_debut__c != Trigger.newMap.get(assurance.Id).Date_de_debut__c || Trigger.oldMap.get(assurance.Id).Date_de_fin__c != Trigger.newMap.get(assurance.Id).Date_de_fin__c){
                assuToUpdate.add(assurance);
            }
        }
        CTRL08_AssurancesPAHandler.calculateNbrAssurancesPA(assuToUpdate, true);
    }
    
    if(Trigger.isBefore && Trigger.isDelete) {
        System.debug('Déclenchement du trigger CTRL08_AssurancesPAHandler sur suppression des assurances prospect adhérent');
        CTRL08_AssurancesPAHandler.calculateNbrAssurancesPA(Trigger.old, false);
    }
}