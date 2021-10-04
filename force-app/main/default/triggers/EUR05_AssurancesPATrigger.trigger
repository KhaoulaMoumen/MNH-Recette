/* 

 * Copyright (C) EuraNov -- All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 * Written by Catherine DELEGLISE <catherine@euranov.com>, sept 2019

 */
 
trigger EUR05_AssurancesPATrigger on Assurances__c (after insert, after update, before delete) {

    if(trigger.isAfter) {
        if (trigger.isInsert || trigger.isUpdate){      
            System.debug('Déclenchement du trigger EUR05_AssurancesPATrigger sur insertion de assurances prospect adhérent');
            EUR05_AssurancesPATriggered manageAssurancesInsertOrDelete = new EUR05_AssurancesPATriggered(Trigger.new, true);
        }
    }
    if(trigger.isBefore) {
        if (trigger.isDelete) {
            System.debug('Déclenchement du trigger EUR05_AssurancesPATrigger sur suppression de assurances prospect adhérent');
            EUR05_AssurancesPATriggered manageAssurancesInsertOrDelete = new EUR05_AssurancesPATriggered(Trigger.old, false);
        }
    }
}