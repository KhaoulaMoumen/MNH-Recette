/* 

 * Copyright (C) EuraNov -- All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 * Written by Nathan Martin <nathan@euranov.com>, July 2019

 */
trigger EUR10_ExpiredQualifAfterUpdate on Task (after update) {
    if (Trigger.isUpdate) {
        List<Task> tasks = new List<Task>();
        RecordType notifRT = [SELECT Id FROM RecordType WHERE Name = :'Notification' AND SobjectType = :'Task' LIMIT 1];
        for(Task t : Trigger.New) {
            if(t.RecordTypeId != notifRT.Id) tasks.add(t);
        }
        if(tasks.size() > 0){
        System.debug('EUR11_ExpQualifAfterUpdateTriggered triggered');
        new EUR11_ExpQualifAfterUpdateTriggered(Trigger.new);
    }
    }
}