/*
------------------------------------------------------------------------------------
-- - Name          : SchBT01_OPPLastActivityNotifications
-- - Author        : Khaoula MOUMEN
-- - Description   : Class that schedules the batch "BA01_OPPLastActivityNotifications"
--    
-- Maintenance History:
--
-- Date         Name                Version     Remarks 
-- -----------  -----------         --------    ---------------------------------------
-- 13-09-2021   K.M                 1.0         Init
---------------------------------------------------------------------------------------
*/
global class SchBT01_OPPLastActivityNotifications implements Schedulable {
    global void execute(SchedulableContext sc) {
        //Execute the batch class with scope 10
        Database.executeBatch(new BA01_OPPLastActivityNotifications(),10);
    }
}