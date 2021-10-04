trigger StatistiqueAnaltyticsTrigger on Statistique_Analtytics__c(before Insert, Before Update) {
    if(trigger.isBefore){
        if(trigger.isUpdate || trigger.isInsert){
            AP04_StatistiqueAnaltytics.FillLookupID(trigger.new);
        }
    }
}