/*
------------------------------------------------------------------------------------
-- - Name          : BA02_SuspectLastActivityNotifs
-- - Author        : Khaoula MOUMEN
-- - Description   : BATCH Leads - Sends last activity notifications to commercials
--    
-- Maintenance History:
--
-- Date         Name                Version     Remarks 
-- -----------  -----------         --------    ---------------------------------------
-- 13-09-2021   K.M                 1.0         Init
---------------------------------------------------------------------------------------
*/
global class BA02_SuspectLastActivityNotifs implements Database.Batchable<sObject>{
    //Date last2Months = (Date.today()).addMonths(-2);
    Date last2Months = (Date.today()).addDays(-2);
    
    CustomNotificationType notifType = [SELECT Id 
                                        FROM CustomNotificationType 
                                        WHERE DeveloperName = 'MNH_Notification' LIMIT 1];
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        system.debug('[BA02_SuspectLastActivityNotifs] Started'); 
        // Get all the leads inactif in the last 2 months
        String query = 'SELECT Id, FirstName,LastName, LastActivityDate, OwnerId FROM Lead WHERE LastActivityDate < :last2Months';
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<Lead> scope) { 
        
        for(Lead piste : scope) {
            // Create custom notification
            Messaging.CustomNotification obj = new Messaging.CustomNotification();
            obj.setNotificationTypeId(notifType.Id);
            obj.setTargetId(piste.id);
            obj.setTitle('Suspect inactive plus de 2 mois');
            obj.setBody('Le suspect '+piste.FirstName+' '+piste.LastName+' est inactif depuis plus de 2 mois. Merci de reprendre les actions à mener ou de convertir le suspect.');
            set <String> users = new set <String> {piste.OwnerId};
                
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
        system.debug('[BA02_SuspectLastActivityNotifs] Finished'); 
    }
    
}