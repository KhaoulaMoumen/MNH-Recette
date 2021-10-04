/*
----------------------------------------------------------------------
-- - Nom           : SchBT03_ExpiredAssuranceFormalNotice
-- - Auteur        : TALAN - Factory 
-- - Description   : Batch schedulé du batch EUR09_ExpiredAssuranceFormalNotice
-- Version:
--
-- Date         Nom                Version     Remarques
-- -----------  -----------         --------    ---------------------------------------
-- 24-03-2020   MOUMEN                 1.0         
---------------------------------------------------------------------------------------
*/
global class SchBT03_ExpiredAssuranceFormalNotice implements schedulable{
    global void execute(SchedulableContext sc)
    {
     EUR09_ExpiredAssuranceFormalNotice b = new EUR09_ExpiredAssuranceFormalNotice(); 
     database.executebatch(b, 100);
    }
}