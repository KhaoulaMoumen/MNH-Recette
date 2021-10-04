/*
----------------------------------------------------------------------
-- - Name          : SchBT10_ScheduleStatAnalyticsDeletion
-- - Author        : Mouloud BENAKROUR (Talan)
-- - Description   : Batch schedulable qui va se déclencher tous les dernier jours du mois pour supprimer les objets Statistic_Analtytics__c vides
*/ 
global class SchBT10_ScheduleStatAnalyticsDeletion implements Schedulable {
   
    global void execute(SchedulableContext sc) {
        BA14_BatchDeleteEmptyStatisticAnalytics batch = new BA14_BatchDeleteEmptyStatisticAnalytics();
        Database.executebatch(batch);
    }
}