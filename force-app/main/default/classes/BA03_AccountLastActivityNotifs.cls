/*
------------------------------------------------------------------------------------
-- - Name          : BA03_AccountLastActivityNotifs
-- - Author        : Khaoula MOUMEN
-- - Description   : BATCH Accounts - Sends last activity notifications to commercials
--    
-- Maintenance History:
--
-- Date         Name                Version     Remarks 
-- -----------  -----------         --------    ---------------------------------------
-- 13-09-2021   K.M                 1.0         Init
---------------------------------------------------------------------------------------
*/
global class BA03_AccountLastActivityNotifs implements Database.Batchable<sObject> {
    Date last6Months = (Date.today()).addMonths(-6);
    Date lastYear = (Date.today()).addYears(-1);
    //Date last6Months = (Date.today()).addDays(-6);
    //Date lastYear = (Date.today()).addDays(-1);
    String clientRT_Id = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Adhérent').getRecordTypeId(); 
    String prospectRT_Id = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Prospect').getRecordTypeId(); 
    String ancienClientRT_Id = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Ancien Adhérent').getRecordTypeId();
    
    CustomNotificationType notifType = [SELECT Id 
                                        FROM CustomNotificationType 
                                        WHERE DeveloperName = 'MNH_Notification' LIMIT 1];
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        system.debug('[BA03_AccountLastActivityNotifs] Started'); 
        // Get all prospects and old clients inactif in more than 6 months and the clients inactif in more than a year
        String query = 'SELECT Id, FirstName,LastName, LastActivityDate,LastModifiedDate, OwnerId,RecordTypeId FROM Account WHERE ((RecordTypeId = :ancienClientRT_Id OR RecordTypeId = :prospectRT_Id) AND (LastActivityDate < :last6Months OR LastModifiedDate < :last6Months)) OR (RecordTypeId = :clientRT_Id AND (LastActivityDate < :lastYear OR LastModifiedDate < :lastYear))';
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<Account> scope) { 
        
        for(Account pa : scope) {
            // Create custom notification
            Messaging.CustomNotification obj = new Messaging.CustomNotification();
            obj.setNotificationTypeId(notifType.Id);
            obj.setTargetId(pa.id);
            // Old client inactif and not modified in the last 6 months
            if((pa.LastActivityDate < last6Months || pa.LastModifiedDate < last6Months) && pa.RecordTypeId == ancienClientRT_Id){
                obj.setTitle('Ancien client inactive/non modifié plus de 6 mois');
                obj.setBody('L\'ancien client '+pa.FirstName+' '+pa.LastName+' est inactive depuis plus de 6 mois. Merci de reprendre les actions à mener.');
            }
            // Prospect inactif and not modified in the last 6 months
            else if((pa.LastActivityDate < last6Months || pa.LastModifiedDate < last6Months) &&  pa.RecordTypeId == prospectRT_Id){
                obj.setTitle('Prospect inactive/non modifié plus de 6 mois');
                obj.setBody('Le prospect '+pa.FirstName+' '+pa.LastName+' est inactive depuis plus de 6 mois. Merci de reprendre les actions à mener.');
            } 
            // Client inactif and not modified in the last year
            else if((pa.LastActivityDate < lastYear || pa.LastModifiedDate < lastYear) &&  pa.RecordTypeId == clientRT_Id){
                obj.setTitle('Client inactive/non modifié plus d\'une année');
                obj.setBody('Le client '+pa.FirstName+' '+pa.LastName+' est inactive depuis plus d\'une année. Merci de reprendre les actions à mener.');
            } 
            set <String> users = new set <String> {pa.OwnerId};
                
                try {
                    // Send custom notificaions
                    obj.send(users);                    
                }
            catch (Exception e) {
                System.debug('Problem sending notification: ' + e.getMessage());
            }
        }
    }   
    
    global void finish(Database.BatchableContext BC) {
        system.debug('[BA03_AccountLastActivityNotifs] Finished'); 
    }
    
}