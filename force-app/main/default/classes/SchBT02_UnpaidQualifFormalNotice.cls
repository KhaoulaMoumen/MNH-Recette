/*
----------------------------------------------------------------------
-- - Nom           : SchBT02_UnpaidQualifFormalNotice
-- - Auteur        : TALAN - Factory 
-- - Description   : Batch schedulé du batch EUR06_UnpaidQualifFormalNotice
-- Version:
--
-- Date         Nom                Version     Remarques
-- -----------  -----------         --------    ---------------------------------------
-- 23-03-2020   MOUMEN                 1.0         
---------------------------------------------------------------------------------------
*/
global class SchBT02_UnpaidQualifFormalNotice implements schedulable{
    global void execute(SchedulableContext sc)
    {
     EUR06_UnpaidQualifFormalNotice b = new EUR06_UnpaidQualifFormalNotice(); 
     database.executebatch(b, 100);
    }
}