/* 

 * Copyright (C) EuraNov -- All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 * Written by Gautier Swiercz <gautier@euranov.com>, June 2019

 */
trigger EUR01_AssuranceEventChange on Assurance__c (after update) {

    if (Trigger.isUpdate) {
        List<Assurance__c> oldAssurance = Trigger.Old;
        List<Assurance__c> newAssurance = Trigger.New;
        EUR01_AssuranceEventChange manageEventChange = new EUR01_AssuranceEventChange(oldAssurance, newAssurance);
    }
}