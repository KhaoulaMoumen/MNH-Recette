public class AP04_StatistiqueAnaltytics{

    public static void FillLookupID(list<Statistique_Analtytics__c> listSAs){
        for(Statistique_Analtytics__c SA: listSAs){
            SA.PartenaireLookup__c = SA.Partenaire_ID__c;
        }
    }
}