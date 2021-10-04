/* 

 * Copyright (C) EuraNov -- All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 * Written by Nathan Martin <nathan@euranov.com>, May 2019

 */
trigger DeleteLotTravaux on Qualification_prospect_adherent__c (after delete) {
    System.debug('trigger DeleteLotTravaux BEGINS');
    if (Trigger.isDelete) {
        new DeleteLotsTravaux(trigger.old);
    }
    System.debug('trigger DeleteLotTravaux ENDS');
}