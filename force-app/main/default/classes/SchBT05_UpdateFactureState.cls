/*
----------------------------------------------------------------------
-- - Nom           : SchBT05_UpdateFactureState
-- - Auteur        : TALAN - Factory 
-- - Description   : Batch schedulé du batch BA03_UpdateFactureState
-- Version:
--
-- Date         Nom                Version      Remarques
-- -----------  -----------         --------    ---------------------------------------
-- 04-2020      MOUMEN                 1.0         
---------------------------------------------------------------------------------------
*/
global class SchBT05_UpdateFactureState implements schedulable{
    global void execute(SchedulableContext sc)
    {
     BA03_UpdateFactureState b = new BA03_UpdateFactureState(); 
     database.executebatch(b, 200);
    }
}