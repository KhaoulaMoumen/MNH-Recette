/*
Trigger that calculate nbr of valid qualifications on account
CreatedBy : MOUMEN Khaoula
@Email : khaoula.moumen@talan.com
CreateDate : 08/12/2020
Remarques : Based on the old trigger EUR04_QualificationTrigger
*/
trigger TR11_QualificationTrigger on Qualification_prospect_adherent__c (after insert, after update, before delete) {
    
    if(Trigger.isAfter && Trigger.isInsert) {
        System.debug('Déclenchement du trigger CTRL09_QualificationTriggerHandler sur insertion des Qualifications prospect adhérent');
        CTRL09_QualificationTriggerHandler.calculateNbrQualifications(Trigger.New, true);
    }
    
    if(Trigger.isAfter && Trigger.isUpdate) {
        System.debug('Déclenchement du trigger CTRL09_QualificationTriggerHandler sur MAJ des Qualifications prospect adhérent');
        List<Qualification_prospect_adherent__c> qualifsToUpdate = new List<Qualification_prospect_adherent__c>();
        for(Qualification_prospect_adherent__c qualifPA : Trigger.New) {
            if(Trigger.oldMap.get(qualifPA.Id).Date_de_debut__c != Trigger.newMap.get(qualifPA.Id).Date_de_debut__c || Trigger.oldMap.get(qualifPA.Id).Date_de_fin__c != Trigger.newMap.get(qualifPA.Id).Date_de_fin__c){
                qualifsToUpdate.add(qualifPA);
            }
        }
        CTRL09_QualificationTriggerHandler.calculateNbrQualifications(qualifsToUpdate, true);
    }
    
    if(Trigger.isBefore && Trigger.isDelete) {
        System.debug('Déclenchement du trigger CTRL09_QualificationTriggerHandler sur suppression des Qualifications prospect adhérent');
        CTRL09_QualificationTriggerHandler.calculateNbrQualifications(Trigger.old, false);
    }
}