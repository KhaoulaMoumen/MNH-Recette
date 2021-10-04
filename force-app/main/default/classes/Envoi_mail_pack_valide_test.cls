@isTest

public class Envoi_mail_pack_valide_test {
    @isTest
    static void test() {
        
        list<Account> accs =DataFactory.createAccounts(1, 'Adhérent', 'Accepté', true);
        list<Contact> contacts =DataFactory.createContacts(1,accs[0].id , 'Interlocuteur administratif', false);
        contacts[0].email='test@talan.com';
        contacts[0].Fonction__c= 'Gérant / Directeur Général';
        insert contacts[0];
        list<Opportunity> opps = DataFactory.createOpportunities(1, accs[0].id, 'Créé', true);
        List<Id> Myopp = new List<Id>{opps[0].id};
		Id pricebookId = Test.getStandardPricebookId();
        Pricebook2 standardPricebook = new Pricebook2(Id = Test.getStandardPricebookId());
        update standardPricebook;
        list<Product2> prods = DataFactory.createProducts(1, true);
        //prods[0].name=''
        List<PricebookEntry> entry = DataFactory.createPriceBookEntries(1, pricebookId, prods[0].id, 10, true);

        try {
            Test.startTest();       
            Envoi_mail_pack_valide.envoyer(Myopp); 
            Integer invocations = Limits.getEmailInvocations();
            System.assertEquals(1, invocations, 'An email has not been sent');
            Test.stopTest(); 
        }catch (DmlException e){
            System.debug('A DmlException error occurred when sending mail : ' + e.getMessage());
        }
    }
}