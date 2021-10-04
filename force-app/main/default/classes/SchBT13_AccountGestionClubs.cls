/*----------------------------------------------------------------------
-- - Name          : SchBT13_AccountGestionClubs
-- - Author        : Khaoula MOUMEN
-- - Description   : schedule batch BA18_GestionClubs
--   
-- Maintenance History:
--
-- Date         Name                Version     Remarks 
-- -----------  -----------         --------    ---------------------------------------
-- 10-05-2021   KM                    1.0         Init
---------------------------------------------------------------------------------------
*/
global class SchBT13_AccountGestionClubs implements Schedulable{
    global void execute(SchedulableContext sc) {  
        //execute batch
        Database.executeBatch(new BA18_GestionClubs());
    }
}