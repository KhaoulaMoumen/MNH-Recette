trigger TR06_Notification_my_synerciel on Notification_My_Synerciel__c (after update) {
    Set<Id> notifsToUpdate = new Set<Id>();
    
    if(Trigger.isAfter && Trigger.isUpdate){
        for(Notification_My_Synerciel__c n : Trigger.New){
            Notification_My_Synerciel__c old =Trigger.oldMap.get(n.Id);
            if(old.Statut__c != null){
                if((old.Statut__c.endsWith('Brouillon')) && (n.Statut__c.endsWith('Programmée'))){
                    notifsToUpdate.add(n.Id);
                }
                CTRL11_handleNotificationMySynercielTR.updateNotifications(notifsToUpdate);
            }
            if(old.isProgrammed__c  == false && n.isProgrammed__c == true){
                system.debug('I am here !');
                //CTRL11_handleNotificationMySynercielTR.createTacheNotif(n);
                CTRL11_handleNotificationMySynercielTR.createTaskswithBatch();
            }
            if(((old.Statut__c != n.Statut__c) && (n.Statut__c.endsWith('Annulée'))) || ((old.Statut__c != n.Statut__c) && (n.Statut__c.endsWith('Brouillon')))){
                CTRL11_handleNotificationMySynercielTR.deleteTacheNotif(n);
            }
        }
    }    
}