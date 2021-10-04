/* 

 * Copyright (C) EuraNov -- All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 * Written by Nathan Martin <nathan@euranov.com>, June 2019

 */
public with sharing class EUR08_ExpiredAssurFormalNoticeTriggered {
    // TODO changer le Batch Schedule dans l'exec du batch car c'est le nom que l'on voit apparaitre dans sales force
    
    public EUR08_ExpiredAssurFormalNoticeTriggered(List<Task> tasks) {
        System.debug('Tasks : ' + tasks);
        String adherent = 'Adhérent';
        
        // GET OWA - Service Administratif
        OrgWideEmailAddress owa = [SELECT id, DisplayName, Address FROM OrgWideEmailAddress where DisplayName = 'Service Administratif'  LIMIT 1];
        
        // Get all Assurances 
        List<Assurances__c> assurances = [SELECT Id,Date_de_fin__c,Compte__c,Compte__r.email__c,Compte__r.Name,Compte__r.Id,Name  FROM Assurances__c WHERE Compte__c != null AND Compte__r.type =:adherent ORDER BY Compte__c];
        System.debug('assurances : ' + assurances);

        // GET ASSURANCES THAT WILL EXPIRE IN THE NEXT 15 DAYS AND WHICH RELATED ACCOUNT HAS A TASK -Mise en demeure – Motif : assurance échue
        for (Assurances__c assurance:assurances) {
            for (Task task:tasks) {
                if (task.whatId == assurance.Compte__c && task.Subject == 'Mise en demeure – Motif : assurance échue') {
                    if (assurance.Date_de_fin__c.addDays(15) < Date.today()) {
                        getInformation(task, assurance, owa);
                    }
                }
            }
        }
    }

    private void getInformation(Task task, Assurances__c assurance, OrgWideEmailAddress owa) {
        List<String> mailingList = new List<String>();

        // To display the date in french format
        String dateFormatString = 'dd-MM-yyyy';
        Date d = assurance.Date_de_fin__c;
        Datetime dt = Datetime.newInstance(d.year(),d.month(),d.day());
        String endDateString = dt.format(dateFormatString);
        System.debug('end date fenchformat :'+ endDateString);
        // To display today in french format
        Date d2 = Date.today();
        Datetime dt2 = Datetime.newInstance(d2.year(),d2.month(),d2.day());
        String todayInFrenchFormat = dt2.format(dateFormatString);

        User Assco = new User();
        System.debug('COMPTE :' + assurance.Compte__c);
        // Récupération du Territoire lié au compte auquel est associé la qualification PA
        ObjectTerritory2Association TER = new ObjectTerritory2Association();
        try {
            TER = [SELECT Territory2Id FROM ObjectTerritory2Association WHERE ObjectId = :assurance.Compte__c LIMIT 1];
        } catch (Exception e) {
            System.debug(e);
        }
        // Récupération des utilisateurs du territoire
        List<UserTerritory2Association> TerritoryUsers = new List<UserTerritory2Association>();
        try {
            System.debug('TER.Id' + TER.Id);
            TerritoryUsers = [SELECT UserId, User.Name, User.Email, RoleInTerritory2 FROM UserTerritory2Association WHERE Territory2Id = :TER.Territory2Id];
        } catch (Exception e) {
            system.debug(e);
        }

        system.debug('TerritoryUsers fetched size' + TerritoryUsers.size());
        system.debug('TerritoryUsers fetched' + TerritoryUsers);

        // We add all recipients to contact by mail 
        // ADD LE RESPONSABLE DU SECTEUR ET L'ASSISTANTE COMMERCIALE AU MAILING LIST
        for (UserTerritory2Association tuser:TerritoryUsers) {
            if (tuser.RoleInTerritory2 == 'Responsable de Secteur') {
                mailingList.add(tuser.User.Email);
                system.debug('Responsable de Secteur' + tuser.User.Email);
            } 
            if (tuser.RoleInTerritory2 == 'Assistant(e) Commercial(e)') {
                Assco.Id=tuser.UserId;
                mailingList.add(tuser.User.Email);
                system.debug('Assistant(e) Commercial(e)' + tuser.User.Email);
            } 
        }

        String mailBody = '';
        // add adhérent to contact 
        // AD RELATED ACCOUNT TO MAILING LIST
        mailingList.add(assurance.Compte__r.email__c);
        // TODO : mettre date de signature dans le corps du mail
        mailBody = assurance.Compte__r.Name +'<br>'+  +'<br>'+  +'<br><br>La Défense le '+ todayInFrenchFormat +'<br>Objet : mise en demeure : défaut attestation assurance<br>LRAR<br><br>Madame, Monsieur, <br><br>Nous constatons que, malgré nos différents échanges et sauf erreur de notre part, vous n\'avez toujours pas procédé à la régularisation de votre dossier administratif. A date nous ne disposons pas d’une attestation d’assurance responsabilité civile et/ou décennale couvrant les activités déclarées.<br><br>Votre entreprise est signataire d’une Convention de membre adhérent du réseau SynerCiel au titre de l’année 2018 (Le Contrat), signée le '+  +'. A ce jour, votre entreprise ne respecte pas ses engagements relatifs aux assurances tels que précisés à l’article 4.1 lui permettant d’être membre adhérent du réseau SynerCiel.<br><br>En l\'absence de régularisation dans un délai de 30 jours à compter du présent courrier, SynerCiel résiliera le Contrat selon les termes et conditions prévues par son article 7. Dans l’attente, vos droits et obligations liés à la convention sont suspendus.<br><br>En pareille situation, votre entreprise :<br><br>• Doit cesser immédiatement l’usage de la Marque "Professionnels Rénovation SynerCiel", (telle que définie à l’Annexe 2 du Contrat) sous quelque forme que ce soit, pour quelque produit et/ou service que ce soit, et à quelque titre que ce soit ;<br><br>•	N’a plus accès à l\'ensemble des offres et services proposés par SynerCiel<br><br>Par ailleurs si votre entreprise est signataire d’un Contrat de Partenariat Partenaire Solutions Habitat d’EDF, et conformément à l’article 7.7 du Contrat, la résiliation de la Convention de membre adhérent du réseau SynerCiel entraînera la résiliation du Contrat de Partenariat Partenaire Solution Habitat.<br><br>Veuillez agréer, Madame, Monsieur, nos salutations distinguées.<br><br>Service administratif Synerciel';
        // try {
        //     sendMail(mailBody, mailingList, owa.id);
        // } catch (Exception e) {
        //     System.debug(e);
        // }
    }

    // private void sendMail(String mailBody, List<String> mailingList, ID fromMail) {
    //     Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();

    //     message.toAddresses = mailingList;
    //     message.optOutPolicy = 'FILTER';
    //     message.subject = 'Mise en demeure : défaut attestation assurance';
    //     System.debug('ID mail : ' + fromMail);
    //     message.setOrgWideEmailAddressId(fromMail);
    //     message.setHtmlBody(mailBody);
    //     Messaging.SingleEmailMessage[] messages = new List<Messaging.SingleEmailMessage> {message};
    //     Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);

    //     if (results[0].success) {
    //         System.debug('The email was sent successfully.');
    //     } else {
    //         System.debug('The email failed to send: ' + results[0].errors[0].message);
    //     }
    //}
}