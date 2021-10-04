public class Envoi_mail_pack_valide {
    public static list<String> getPackValideOpportunity(){
        List < String > allOpts = new list < String > ();
		Schema.DescribeFieldResult fieldResult = Opportunity.Pack_valide_commercial__c.getDescribe();
		List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for (Schema.PicklistEntry a: ple) {
            allOpts.add(a.getValue());
        }
        system.debug('allOpts ---->' + allOpts);
        allOpts.sort();
        return allOpts;
    }
    
    @InvocableMethod
    public static void envoyer(List<Id> Myopp){
        User myUser = [select Email from user where Name = 'Administratif SynerCiel'];
        List<OrgWideEmailAddress> owea = [select Id from OrgWideEmailAddress where Address = 'administratif@synerciel.fr' LIMIT 1];

        list<Opportunity> opps = [select id,Accountid,Pack_valide_commercial__c,Montant_Pack_HT_non_remise__c from opportunity where 
                                  id IN : Myopp];

        PriceBook2 stdPriceBook = [select Id, Name, IsActive from PriceBook2 where IsStandard=True limit 1];
        Map<ID, Product2> allProds = new Map<ID, Product2>([select id,Name from Product2 
                                                            where Name IN : getPackValideOpportunity()]);
        list<PricebookEntry> prodUnitPrice = [select Product2Id,UnitPrice from PricebookEntry 
                                              where Product2Id IN : allProds.keyset() and PriceBook2Id =:stdPriceBook.id ];
        Map<String,Double> prodNameUP= new Map<String,Double>();
        for(PricebookEntry prod : prodUnitPrice){
            prodNameUP.put(allProds.get(prod.Product2Id).name,prod.UnitPrice);
        }
        Map<String,list<Contact>> emailsOfacc = new Map<String,list<Contact>>();

        list<Contact> allCons = [Select Id,AccountId, email,Fonction__c From Contact Where 
                                 (AccountId In (Select AccountId From Opportunity Where Id IN :Myopp))
                                 and(Fonction__c = 'Gérant / Directeur Général' or Fonction__c = 'Président')   ];
        system.debug('allll'+allCons);
        for(Contact myCon: allCons){
            system.debug('iteration'+myCon);
            if(emailsOfacc.containsKey(myCon.Accountid)){
                list<Contact> emails = emailsOfacc.get(myCon.Accountid);
                emails.add(myCon);
                emailsOfacc.put(myCon.Accountid,emails);
                system.debug('inif'+emails);
            }else{
                list<Contact> emails = new list<Contact> {myCon};
                    emailsOfacc.put(myCon.Accountid,emails);
                system.debug('outif'+emails);
            }            
        }
        
        List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
        if(emailsOfacc.size()>0){
            system.debug('contcts'+emailsOfacc);
            for(Opportunity opp :opps ){
                list<Contact> emails = new list<Contact>();
                list<Contact> emailsPres = new list<Contact>();
                String packName =opp.Pack_valide_commercial__c;
                Double tarif = prodNameUP.get(packName);
                if(emailsOfacc.get(opp.accountid).size()>0){
                    for(Contact con : emailsOfacc.get(opp.accountid)){
                        if(con.Fonction__c =='Gérant / Directeur Général' ){
                            emails.add(con);
                        }else{
                            emailsPres.add(con);
                        }
                    }}
                system.debug('eeeeeeee'+emails);
                system.debug('preeeeeees'+emailsPres);                
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                list<String> toAddresses = new list<String>() ; 
                if(emails.size()>0){
                    for(Contact con :emails){
                        toAddresses.add(con.Email);
                    }
                }else{
                    for(Contact con :emailsPres){
                        toAddresses.add(con.Email);
                    }
                }                
                mail.setToAddresses(toAddresses);
                system.debug(toAddresses);
                
                mail.setOrgWideEmailAddressId(owea[0].Id);
                                
                // Specify the address used when the recipients reply to the email. 
                mail.setReplyTo(myUser.Email);
                
                
                // Specify the subject line for your email address.
                mail.setSubject('Confirmation de votre Pack Synerciel 2021');
                
                // Set to True if you want to BCC yourself on the email.
                mail.setBccSender(false);
                
                mail.setHtmlBody('Bonjour,<br><br>'+ 
                                 'Nous vous remercions pour la qualité des échanges lors de la présentation de la nouvelle offre d’accompagnement Synerciel.<br><br>'+
                                 'Vous avez choisi de bénéficier des atouts du Pack Synerciel '+packName+', au tarif annuel de '+tarif+' €HT.<br>'+
                                 'Ainsi, vous recevrez à compter du 2 novembre, un mail avec un lien pour signer votre contrat Synerciel 2021, en fonction de votre pack.<br><br>'+
                                 'Nous vous remercions de votre fidélité car la dynamique du réseau Synerciel n’est possible qu’avec vous, votre engagement et votre confiance. Cette confiance nous incite à toujours mieux vous satisfaire et à continuer à innover avec de nouveaux services en 2021.<br><br>'+
                                 'Nous restons à votre entière disposition pour toute information complémentaire.<br><br>'+
                                 'Bien cordialement,<br><br>'+
                                 'Les équipes Synerciel ');
                mails.add(mail);
            }}
        
        // Send the email you have created.
        Messaging.sendEmail(mails);
        
    }
    
}