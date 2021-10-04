/*
----------------------------------------------------------------------
-- - Name          : ScheduleBatchCompteUpdateQualite
-- - Author        : RDB
-- - Description   : Batch schedulable qui va se déclencher toutes les heures    
--					 et qui va lancer le batch qui calcul les champs Qualité sur les comptes
-- Maintenance History:
--
-- Date         Name                Version     Remarks 
-- -----------  -----------         --------    ---------------------------------------
-- 12-12-2019   RDB                 1.0         Init
---------------------------------------------------------------------------------------
*/
global class ScheduleBatchCompteUpdateQualite implements Schedulable {
    
    global void execute(SchedulableContext sc) {
        BatchUpdateCompteQualite batch = new BatchUpdateCompteQualite();
        Database.executebatch(batch);
    }
}