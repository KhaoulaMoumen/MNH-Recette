/*
----------------------------------------------------------------------
-- - Name          : SchBT08_ScheduleStatAnalyticsCreation
-- - Author        : Mouloud BENAKROUR (Talan)
-- - Description   : Batch schedulable qui va se déclencher tous les premier du mois pour créer l'objet Statistic_Analtytics__c vide pour chaque User/Offre
*/
global class SchBT08_ScheduleStatAnalyticsCreation implements Schedulable {
    
    global void execute(SchedulableContext sc) {
        BA12_BatchCreateEmptyStatisticAnalytics batch = new BA12_BatchCreateEmptyStatisticAnalytics();
        Database.executebatch(batch,10);
    }
}