/*
----------------------------------------------------------------------
-- - Name          : SchBT12_ScheducleReconductionRelance1
-- - Author        : KHAOULA MOUMEN
-- - Description   : Batch schedulable qui va se déclencher tous les jours du mois pour envoyer l'email de relance de la reconduction
*/
global class SchBT12_ScheducleReconductionRelance1 implements Schedulable {
    
    global void execute(SchedulableContext sc) {
        BA16_ReconductionOffre_Relance1 batch = new BA16_ReconductionOffre_Relance1();
        Database.executebatch(batch,10);
    }
}