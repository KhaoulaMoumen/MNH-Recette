/* 

 * Copyright (C) EuraNov -- All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 * Written by Nathan Martin <nathan@euranov.com>, June 2019

 */
public with sharing class EUR04_UnpaidQualifFormalNoticeTriggered {
    public EUR04_UnpaidQualifFormalNoticeTriggered(List<Task> tasks) {
        System.debug('Tasks : ' + tasks);

        // GET OWA 'Service Administratif'
        OrgWideEmailAddress owa = [select id, DisplayName, Address from OrgWideEmailAddress where DisplayName = 'Service Administratif' limit 1];

        // GET TASK'S ACCOUNTS
        List<Id> accountIds = new List<Id>();
        for (Task task:tasks) {
            accountIds.add(task.whatId);
        }
        // Get all qualifications 
        List<Qualification_prospect_adherent__c> qualificationsPA = [SELECT Id,Name,Date_de_fin__c,Compte__c, Compte__r.email__c,Compte__r.BillingAddress FROM Qualification_prospect_adherent__c WHERE Compte__c IN :accountIds ORDER BY Compte__c];
        
        // QUALIFICATION PA CONFIRMED TASKS 'Mise en demeure – Motif : qualification échue' 
        for (Qualification_prospect_adherent__c qualifPA:qualificationsPA) {
            for (Task task:tasks) {
                if (task.Subject == 'Mise en demeure – Motif : qualification échue' && task.Status == 'Confirmer') {
                    if (qualifPA.Date_de_fin__c.addDays(15) <= Date.today()) {
                        // CREATE 
                        getInformation(task, qualifPA, owa);
                    }
                }
            }
        }
    }

    private void getInformation(Task task, Qualification_prospect_adherent__c qualifPA, OrgWideEmailAddress owa) {
        List<String> mailingList = new List<String>();

        // To display the date in french format
        String dateFormatString = 'dd-MM-yyyy';
        Date d = qualifPA.Date_de_fin__c;
        Datetime dt = Datetime.newInstance(d.year(),d.month(),d.day());
        String endDateString = dt.format(dateFormatString);
        System.debug('end date fenchformat :'+ endDateString);

        Date d2 = Date.today();
        Datetime dt2 = Datetime.newInstance(d2.year(),d2.month(),d2.day());
        String todayInFrenchFormat = dt2.format(dateFormatString);

        User Assco = new User();
        System.debug('COMPTE :' + qualifPA.Compte__c);
        // Récupération du Territoire lié au compte auquel est associé la qualification PA
        ObjectTerritory2Association TER = new ObjectTerritory2Association();
        try {
            TER = [SELECT Territory2Id FROM ObjectTerritory2Association WHERE ObjectId = :qualifPA.Compte__r.Id LIMIT 1];
        } catch (Exception e) {
            System.debug(e);
        }
        // Récupération des utilisateurs du territoire
        List<UserTerritory2Association> TerritoryUsers = new List<UserTerritory2Association>();
        try {
            TerritoryUsers = [SELECT UserId, User.Name, User.Email, RoleInTerritory2 FROM UserTerritory2Association WHERE Territory2Id = :TER.Territory2Id];
        } catch (Exception e) {
            system.debug(e);
        }
        // We add all recipients to contact by mail
        for (UserTerritory2Association tuser:TerritoryUsers) {
            if (tuser.RoleInTerritory2 == 'Responsable de Secteur') {
                mailingList.add(tuser.User.Email);
            } 
            if (tuser.RoleInTerritory2 == 'Assistant(e) Commercial(e)') {
                Assco.Id=tuser.UserId;
                mailingList.add(tuser.User.Email);
            } 
        }

        String mailBody = '';
        // add adhérent to contact
        mailingList.add(qualifPA.Compte__r.email__c);
        // TODO : mettre date de signature dans le corps du mail
        mailBody = qualifPA.Name +'<br>'+ qualifPA.Compte__r.BillingAddress +'<br><br>La Défense le '+ todayInFrenchFormat +'<br>Objet : mise en demeure : défaut qualification professionnelle<br>LRAR<br><br>Madame, Monsieur, <br><br>Nous constatons que, malgré nos différents échanges et sauf erreur de notre part, vous n\'avez toujours pas procédé à la régularisation de votre dossier administratif. A date nous ne disposons pas d\'un certificat de qualification professionnelle couvrant les activités déclarées.<br><br>Votre entreprise est signataire d’une Convention de membre adhérent du réseau SynerCiel au titre de l’année 2018 (Le Contrat), signée le '+  +'. A ce jour, votre entreprise ne respecte pas ses engagements relatifs aux qualifications professionnelles tels que précisés aux articles 4.1 et 4.2 lui permettant d’être membre adhérent du réseau SynerCiel.<br><br>En l\'absence de régularisation dans un délai de 30 jours à compter du présent courrier, SynerCiel résiliera Le Contrat selon les termes et conditions prévues par son article 7. Dans l’attente, vos droits et obligations liés à la convention sont suspendus.<br><br>En pareille situation, votre entreprise :<br><br>• Doit cesser immédiatement l’usage de la Marque "Professionnels Rénovation SynerCiel", (telle que définie à l’Annexe 2 du Contrat) sous quelque forme que ce soit, pour quelque produit et/ou service que ce soit, et à quelque titre que ce soit ;<br><br>•	N’a plus accès à l\'ensemble des offres et services proposés par SynerCiel<br><br>Par ailleurs si votre entreprise est signataire d’un Contrat de Partenariat Partenaire Solutions Habitat d’EDF, et conformément à l’article 7.7 du Contrat, la résiliation de la Convention de membre adhérent du réseau SynerCiel entraînera la résiliation du Contrat de Partenariat Partenaire Solution Habitat.<br><br>Veuillez agréer, Madame, Monsieur, nos salutations distinguées.<br><br>Service administratif Synerciel';

        // todo mis en commentaire à la demande du client
        // try {
        //     sendMail(mailBody, mailingList, owa.id);
        // } catch (Exception e) {
        //     System.debug(e);
        // }
    }


    // private void sendMail(String mailBody, List<String> mailingList, Id fromMail) {
    //     Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
        
    //     message.toAddresses = mailingList;
    //     message.optOutPolicy = 'FILTER';
    //     message.subject = 'Mise en demeure : défaut qualification professionnelle';
    //     System.debug('ID mail : ' + fromMail);
    //     message.setOrgWideEmailAddressId(fromMail);
    //     message.setHtmlBody(mailBody);
    //     //message.setSenderDisplayName('Service client Synerciel');
    //     Messaging.SingleEmailMessage[] messages = new List<Messaging.SingleEmailMessage> {message};
    //     Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);

    //     if (results[0].success) {
    //         System.debug('The email was sent successfully.');
    //     } else {
    //         System.debug('The email failed to send: ' + results[0].errors[0].message);
    //     }
    // }
}