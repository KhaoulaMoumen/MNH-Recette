/*
----------------------------------------------------------------------
-- - Name          : SchBT09_ScheduleStatAnalyticsUpdate
-- - Author        : Mouloud BENAKROUR (Talan)
-- - Description   : Batch schedulable qui va se déclencher tous les jours du mois pour mettre a jour l'objet Statistic_Analtytics__c vide pour chaque User/Offre avec les données d'Analytics
*/
global class SchBT09_ScheduleStatAnalyticsUpdate implements Schedulable {
    
    global void execute(SchedulableContext sc) {
        BA13_BatchUpdateStatisticAnalytics batch = new BA13_BatchUpdateStatisticAnalytics();
        Database.executebatch(batch,1);
    }
}