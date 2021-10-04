/* 
 * Written by Nathan Martin <nathan@euranov.com>, July 2019
 * Edited by Khaoula Moumen <khaoula.moumen@talan.com>, March 2020 
*/
global class EUR15_RelanceFinOffreDecouverte implements Database.Batchable<sObject>, Database.Stateful {
    
    public String query;
    String adherent = 'Adhérent';
    String offredecouverte = 'OFFRE DECOUVERTE';
    
    Date daterelance = Date.today().addMonths(+1);
    
    // GET OWEA SERVICE ADMINISTRATTIF
    public OrgWideEmailAddress owa = [SELECT id, DisplayName, Address FROM OrgWideEmailAddress where DisplayName = 'Service Administratif' LIMIT 1];
    
    private List<Convention_annuelle__c> conventions;

    // GET ALL THE CONVENTIONS RELATED TO ADHERENTS AND RELANCEES IN THE LAST 5 MONTHS 
    global Database.QueryLocator start(Database.BatchableContext bc){
        
        this.conventions = new List<Convention_annuelle__c>();
        this.query = 'SELECT Id, Adherent__c, Adherent__r.Email__c, EndDate__c, Date_debut_contrat__c,Date_fin_offre__c FROM Convention_annuelle__c WHERE conventionArticle__c = :offredecouverte  AND Adherent__r.Profil__c = :adherent AND Date_fin_offre__c = :daterelance ORDER BY Date_debut_contrat__c ASC';
        
        return Database.getQueryLocator(this.query);
    }
    
    global void execute(Database.BatchableContext BC, List<Convention_annuelle__c> scope){
        
        List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
       
        for (Convention_annuelle__c c : scope){
            mails.add(getInformation(c,owa));
        }
        System.debug('Taille liste email : ' + mails.size());
        Messaging.sendEmail(mails);
    }
    
    global void finish(Database.BatchableContext BC){}
    
    private Messaging.SingleEmailMessage getInformation(Convention_annuelle__c con, OrgWideEmailAddress owa){
        Messaging.SingleEmailMessage mailToSend = new Messaging.SingleEmailMessage();
        // Get all contacts to send them e mails
        List<Contact> contacts = [SELECT Id,Email,roles_du_contact__c FROM Contact WHERE roles_du_contact__c includes ('Interlocuteur administratif','Interlocuteur contrat','Interlocuteur commercial') AND AccountId IN (SELECT Adherent__c FROM Convention_annuelle__c WHERE Id = :con.Id)];
        System.debug('Requete SOQL (contacts): ' + contacts);
        List<String> mailingList = new List<String>();
        // We add all recipients to contact by mail
        for (Contact contact:contacts) {
            mailingList.add(contact.Email);
        }
        
        User Assco = new User();
        System.debug('COMPTE :' + con.Adherent__c);
        // Récupération du Territoire lié au compte auquel est associé l'facture
        ObjectTerritory2Association TER = new ObjectTerritory2Association();
        try {
            TER = [SELECT Territory2Id FROM ObjectTerritory2Association WHERE ObjectId = :con.Adherent__c LIMIT 1];
        } catch (Exception e) {
            System.debug(e);
        }
        // Récupération des utilisateurs du territoire
        List<UserTerritory2Association> TerritoryUsers = new List<UserTerritory2Association>();
        try {
            TerritoryUsers = [SELECT UserId, User.FirstName, User.LastName, User.Name, User.Email, RoleInTerritory2 FROM UserTerritory2Association WHERE Territory2Id = :TER.Territory2Id AND RoleInTerritory2 ='Assistant(e) Commercial(e)'];
        } catch (Exception e) {
            system.debug(e);
        }
        // ADD ASSISTANTE COMMERCIALE TO THE MAILING LIST
        for (UserTerritory2Association tuser:TerritoryUsers) {
            if (tuser.RoleInTerritory2 == 'Assistant(e) Commercial(e)') {
                Assco.Id=tuser.UserId;
                Assco.FirstName = tuser.User.FirstName;
                Assco.LastName = tuser.User.LastName;
            } 
        }
        
        // If we don't have first and lastname of assco
        String prenom_et_nom_assco = Assco.FirstName + ' ' + Assco.LastName ;
        if (Assco.FirstName == null || Assco.LastName == null || Assco.LastName.equals('') || Assco.FirstName.equals('')) {
            prenom_et_nom_assco = 'Votre service client';
        }

        // EMAIL BODY
        String mailBody = '<p>Cher(e) adh&eacute;rent(e),</p><p>Vous avez b&eacute;n&eacute;fici&eacute; de plusieurs mois offerts pour d&eacute;couvrir le R&eacute;seau,&nbsp; vous voil&agrave; pleinement adh&eacute;rent(e)&nbsp;SynerCiel !&nbsp;&nbsp;</p><p>Votre adh&eacute;sion se poursuit jusqu&rsquo;&agrave; la fin de l&rsquo;ann&eacute;e et vous continuez ainsi d&rsquo;acc&eacute;der sans interruption, &agrave; toute l&rsquo;offre Synerciel&nbsp;:</p><ul><li>L&rsquo;image d&rsquo;un R&eacute;seau de Qualit&eacute;</li><li>L&rsquo;accompagnement d&rsquo;un Responsable Secteur sur le terrain</li><li>Les Cercles Confort Habitat, pour d&eacute;velopper avec le r&eacute;seau local Synerciel du chiffre d&rsquo;affaires additionnel</li><li>Les solutions de financement avec notre partenaire Domofinance</li><li>Les Offres et Services de nos Partenaires pour optimiser vos charges</li><li>Les Rencontres pour des moments d&rsquo;&eacute;changes d&rsquo;exp&eacute;riences, des intervenants experts, &hellip;</li><li>Le programme Partenaire Economie d&rsquo;Energie d&rsquo;EDF pour les signataires du contrat membre Partenaire Economie d&rsquo;Energie d&rsquo;EDF</li></ul><p>Nous vous rappelons que vous avez n&eacute;anmoins la possibilit&eacute; de r&eacute;silier votre adh&eacute;sion par lettre recommand&eacute;e avec accus&eacute; de r&eacute;ception avant le '+ con.Date_fin_offre__c.format()+' (date du cachet de la poste faisant foi) et l&rsquo;adresser &agrave; :</p><p>Synerciel - Service administratif &ndash; 21 avenue de Cambridge, TSA 50004, 14203 HEROUVILLE SAINT CLAIR.</p><p>Pass&eacute; ce d&eacute;lai le contrat d&rsquo;adh&eacute;sion sera reconduit tacitement jusqu&rsquo;&agrave; la fin de l&rsquo;ann&eacute;e et vous recevrez votre facture &agrave; r&eacute;gler en une seule fois par pr&eacute;l&egrave;vement, du montant de l&rsquo;adh&eacute;sion pour les mois restants.</p><p style="text-align: left;">Votre service administratif SynerCiel</p><p>&nbsp;</p>';
       
        // ID EN DUR >??????
        Assco.Id = '0051r0000093SD9AAM';
        
        // CREATE TASK FIN OFFRE DECOUVERTE RELATED TO ADHERENT 
        Task task = new Task(Subject='Fin de l\'offre Découverte', WhatId=con.Adherent__c, OwnerId=Assco.Id, ActivityDate=Date.today());
        
            try {
                // INSERT TASK
                insert task;
            } catch(Exception e) {
                System.debug(e);
            }
 
        mailingList.add(con.Adherent__r.email__c );
        System.debug('Add adhérent address :' + con.Adherent__r.email__c );

            try {
                system.debug('mailbody: ' +mailBody);
                for(string s : mailingList){
                    system.debug('s:'+s);
                }
                System.debug('owa :'+owa.id);
                // SEND EMAIL
                mailToSend = sendMail(mailBody, mailingList, owa.id, con.Adherent__c);
            } catch (Exception e) {
                System.debug(e);
            }
            return mailToSend;
    }

    // METHOD THAT SEND EMAIL
    private Messaging.SingleEmailMessage sendMail(String mailBody, List<String> mailingList, String fromMail, Id whatID) {
        Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();      
        //TODO : setBccAddresses(bccAddresses)
        message.toAddresses = mailingList;
        message.optOutPolicy = 'FILTER';
        message.subject = 'Fin de votre Offre Découverte';
        System.debug('ID mail : ' + fromMail);
        message.setOrgWideEmailAddressId(fromMail);
        message.setHtmlBody(mailBody);
        message.setWhatId(whatID);
        message.setUseSignature(false);
        return(message);
        //message.setSenderDisplayName('Service client Synerciel');
        /*Messaging.SingleEmailMessage[] messages = new List<Messaging.SingleEmailMessage> {message};
        Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);

        if (results[0].success) {
            System.debug('The email was sent successfully.');
        } else {
            System.debug('The email failed to send: ' + results[0].errors[0].message);
        }*/
    }
}