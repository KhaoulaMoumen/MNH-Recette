/*
----------------------------------------------------------------------
-- - Nom           : SchBT04_RelanceFinOffreDecouverte
-- - Auteur        : TALAN - Factory 
-- - Description   : Batch schedulé du batch EUR09_ExpiredAssuranceFormalNotice
-- Version:
--
-- Date         Nom                Version     Remarques
-- -----------  -----------         --------    ---------------------------------------
-- 24-03-2020   MOUMEN                 1.0         
---------------------------------------------------------------------------------------
*/
global class SchBT04_RelanceFinOffreDecouverte implements schedulable{
    global void execute(SchedulableContext sc)
    {
     EUR15_RelanceFinOffreDecouverte b = new EUR15_RelanceFinOffreDecouverte(); 
     database.executebatch(b, 20);
    }
}