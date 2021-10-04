/*
----------------------------------------------------------------------
-- - Name          : ScheduleBatchReportDownload
-- - Author        : BOU
-- - Description   : Batch schedulable qui va se déclencher tous les jours pour créer une nouvelle version du rapport
-- Maintenance History:
--
-- Date         Name                Version     Remarks 
-- -----------  -----------         --------    ---------------------------------------
-- 17-08-2019   BOU                 1.0         Init
---------------------------------------------------------------------------------------
*/
global class ScheduleBatchReportDownload implements Schedulable {
    
    global void execute(SchedulableContext sc) {
        BatchReportDownload batch = new BatchReportDownload();
        Database.executebatch(batch,1);
    }
}