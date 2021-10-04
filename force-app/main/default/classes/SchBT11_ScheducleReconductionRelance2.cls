/*
----------------------------------------------------------------------
-- - Name          : SchBT11_ScheducleReconductionRelance2
-- - Author        : KHAOULA MOUMEN
-- - Description   : Batch schedulable qui va se déclencher tous les jours du mois pour faire la reconduction des offres clients et desactiver les acces des utilisateurs qui souhaite pas faire la reconduction
*/
global class SchBT11_ScheducleReconductionRelance2 implements Schedulable {
    
    global void execute(SchedulableContext sc) {
        BA17_ReconductionOffre_Relance2 batch = new BA17_ReconductionOffre_Relance2();
        Database.executebatch(batch,10);
    }
}