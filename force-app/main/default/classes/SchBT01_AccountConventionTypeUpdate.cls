/*
----------------------------------------------------------------------
-- - Nom          : SchBT01_AccountConventionTypeUpdate
-- - Auteur        : ASA
-- - Description   : Batch schedulé du batch BT01_AccountConventionTypeUpdate
-- Version:
--
-- Date         Nom                Version     Remarques
-- -----------  -----------         --------    ---------------------------------------
-- 12-12-2019   ASA                 1.0         Init
---------------------------------------------------------------------------------------
*/
global class SchBT01_AccountConventionTypeUpdate implements schedulable{
    global void execute(SchedulableContext sc)
    {
     BT01_AccountConventionTypeUpdate b = new BT01_AccountConventionTypeUpdate(); 
     // EXECUTE BATCH WITH SCOPE = 200
     database.executebatch(b,200);
    }
}