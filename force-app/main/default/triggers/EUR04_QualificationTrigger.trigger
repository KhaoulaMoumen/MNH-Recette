/* 

 * Copyright (C) EuraNov -- All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 * Written by Nathan Martin <nathan@euranov.com>, July 2019

 */
trigger EUR04_QualificationTrigger on Qualification_prospect_adherent__c (after insert, after update, before delete) {

    if(trigger.isAfter) {
        if (trigger.isInsert || trigger.isUpdate){      
            System.debug('Déclenchement du trigger EUR04_QualificationTrigger sur insertion de Qualifications prospect adhérent');
            EUR04_QualificationTriggered manageQualifInsertOrDelete = new EUR04_QualificationTriggered(Trigger.new, true);
        }
    }
    if(trigger.isBefore) {
        if (trigger.isDelete) {
            System.debug('Déclenchement du trigger EUR04_QualificationTrigger sur suppression de Qualifications prospect adhérent');
            EUR04_QualificationTriggered manageQualifInsertOrDelete = new EUR04_QualificationTriggered(Trigger.old, false);
        }
    }
}