/*
------------------------------------------------------------------------------------
-- - Name          : SchBT02_LeadLastActivityNotifications
-- - Author        : Khaoula MOUMEN
-- - Description   : Class that schedules the batch "BA02_SuspectLastActivityNotifs"
--    
-- Maintenance History:
--
-- Date         Name                Version     Remarks 
-- -----------  -----------         --------    ---------------------------------------
-- 13-09-2021   K.M                 1.0         Init
---------------------------------------------------------------------------------------
*/
global class SchBT02_LeadLastActivityNotifications implements Schedulable {
    global void execute(SchedulableContext sc) {
        //Execute the batch class with scope 10
        Database.executeBatch(new BA02_SuspectLastActivityNotifs(),10);
    }
}