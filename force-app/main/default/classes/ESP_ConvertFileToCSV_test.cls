@isTest
public class ESP_ConvertFileToCSV_test {
    public static String str = 'Code partenaire;SIRET;Date Commande;Type/Réf/Code article;Quantité;Montant Commande;Date de DEBUT de validité;Date de FIN de validité;Volume lignes fixes;Volume lignes mobiles;Date de LIVRAISON (pour les véhicules) \n' +
        'PSA;47911587500029;;REZRE;1;400;;;;;';
    @testSetup 
    static void setup() {
        
        list<Account> accs = Datafactory.createAccounts(2, 'Partenaire', 'Non applicable', false);
        accs[0].Profil__c='Partenaire';
        accs[1].Profil__c='Partenaire';
        accs[1].sirenSiret__c='47911587500029';
        insert accs;
        List<Commande_partenaire_recue__c > cprs = Datafactory.createCommandePR(1, accs[0].id, '', 'Nouveau', true);

    }
    static testmethod void test() {
        List<ContentVersion> cvs =  Datafactory.createContentVersion(1, false);
        
            cvs[0].Title = 'Test';
            cvs[0].PathOnClient = 'Test.csv';
            cvs[0].VersionData = Blob.valueOf(str);
            cvs[0].IsMajorVersion = true;
        insert cvs;
    ContentVersion contentVersionInsert = cvs[0];
        Id getId = [Select ContentDocumentId From ContentVersion Where Id =:contentVersionInsert.id and isLatest=true].ContentDocumentId;
        Account a  = [select id from account limit 1];
        Commande_partenaire_recue__c cpr  = [select id,Partenaire__c from Commande_partenaire_recue__c limit 1];
        ESP_ConvertFileToCSV.Request rq = new  ESP_ConvertFileToCSV.Request();
        rq.commandePartenaireId = cpr.id;
        rq.partenaireId=cpr.Partenaire__c;
        rq.contentDocumentId=getId;
        rq.objectApiName='Offres_et_Service__c';
        Test.startTest();
        ESP_ConvertFileToCSV.Request[] rqs = new ESP_ConvertFileToCSV.Request[]{rq};
        ESP_ConvertFileToCSV.convert(rqs);
        Test.stopTest();
    }

}