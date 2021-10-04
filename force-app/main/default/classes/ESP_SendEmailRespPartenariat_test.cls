@isTest
public class ESP_SendEmailRespPartenariat_test {
    @testSetup 
    static void setup() {
        
        list<Account> accs = Datafactory.createAccounts(1, 'Partenaire', 'Non applicable', false);
        accs[0].Profil__c='Partenaire';
        insert accs;
        List<Commande_partenaire_recue__c > cprs = Datafactory.createCommandePR(1, accs[0].id, '', 'Nouveau', true);
    }
    static testmethod void test() {
        Commande_partenaire_recue__c cpr = [select id,Partenaire__c from Commande_partenaire_recue__c limit 1 ];
        Account acc = [select ownerid from Account where id =:cpr.Partenaire__c ];
        ESP_SendEmailRespPartenariat.Request req = new ESP_SendEmailRespPartenariat.Request ();
        req.respPartenariatID = acc.ownerid;
        req.commandepartenaireID = cpr.id;
        Test.startTest();
        ESP_SendEmailRespPartenariat.Request[] rqs = new ESP_SendEmailRespPartenariat.Request[]{req};
        ESP_SendEmailRespPartenariat.SendEmail(rqs);
        Integer invocations = Limits.getEmailInvocations();
        Test.stopTest();
        system.assertEquals(1, invocations,  ' An email should be sent');


    }

}