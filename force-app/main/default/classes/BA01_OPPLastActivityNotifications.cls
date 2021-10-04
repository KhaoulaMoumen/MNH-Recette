/*
------------------------------------------------------------------------------------
-- - Name          : BA01_OPPLastActivityNotifications
-- - Author        : Khaoula MOUMEN
-- - Description   : BATCH Opportunity - Sends last activity notifications to commercials
--    
-- Maintenance History:
--
-- Date         Name                Version     Remarks 
-- -----------  -----------         --------    ---------------------------------------
-- 13-09-2021   K.M                 1.0         Init
---------------------------------------------------------------------------------------
*/
global class BA01_OPPLastActivityNotifications implements Database.Batchable<sObject> {
    Date last90Days = (Date.today()).addDays(-90);
    Date last3Days = (Date.today()).addDays(-3);
    String waitingSignature = 'En attente de signature';
    CustomNotificationType notifType = [SELECT Id 
                                        FROM CustomNotificationType 
                                        WHERE DeveloperName = 'MNH_Notification' LIMIT 1];
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        system.debug('[BA01_OPPLastActivityNotifications] Started');
        // Get all opportunities with last activity more than 90 days or the last activity is in the last 3 days and the stage is waiting for signature
        String query = 'SELECT Id, Name, StageName, LastActivityDate, OwnerId FROM Opportunity WHERE LastActivityDate < :last90Days OR (LastActivityDate = :last3Days AND StageName = :waitingSignature)';
        return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext BC, List<Opportunity> scope) { 
        
        for(Opportunity opp : scope) {
            // Create custom notification
            Messaging.CustomNotification obj = new Messaging.CustomNotification();
            obj.setNotificationTypeId(notifType.Id);
            obj.setTargetId(opp.id);
            //if the last activity is in more than 90 days
            if(opp.LastActivityDate < last90Days){
                obj.setTitle('Opportunité inactive plus de 90 jours');
                obj.setBody('L\'opportunité '+opp.Name+' est inactive depuis plus de 90 jours. Merci de reprendre les actions à mener ou de clôturer l\'opportunité.');
            }
            // if the last activity is in the last 3 days and the stage is waiting for signature
            else if(opp.LastActivityDate == last3Days && opp.StageName == waitingSignature) {
                obj.setTitle('Opportunité en attende et inactive depuis 3 jours');
                obj.setBody('L\'opportunité '+opp.Name+' est en attente de signature et inactive depuis plus de 3 jours. Merci de reprendre les actions à mener ou de clôturer l\'opportunité.');  
            }
            set <String> users = new set <String> {opp.OwnerId};
                
                try {
                   // Send the custom notifications
                   obj.send(users);                    
                }
            catch (Exception e) {
                System.debug('Problem sending notification: ' + e.getMessage());
            }
        }
        
    }   
    global void finish(Database.BatchableContext BC) {
        system.debug('[BA01_OPPLastActivityNotifications] Finished'); 
    }
    
}