/* 

 * Copyright (C) EuraNov -- All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 * Written by Nathan Martin <nathan@euranov.com>, June 2019
 * Edited by Khaoula Moumen <khaoula.moumenn@talan.com>, June 2020

 */

global class ExpiredQualificationWarner implements Schedulable {
    // TODO changer le Batch Schedule dans l'exec du batch car c'est le nom que l'on voit apparaitre dans sales force

    Map<Id,Id> mapTER {get;set;}
    
    global void execute(System.SchedulableContext sc) {

        // GET OWEA SERVICE ADMINISTRATIF
        OrgWideEmailAddress owa = [select id, DisplayName, Address from OrgWideEmailAddress where DisplayName = 'Service Administratif' limit 1];
        List<ObjectTerritory2Association> listTER= [SELECT Territory2Id, ObjectID FROM ObjectTerritory2Association];
        mapTER = new Map<Id,Id>();
        for(ObjectTerritory2Association t : listTER){
            mapTER.put(t.ObjectID, t.Territory2Id);
        }
        /*List<UserTerritory2Association> listTERUsers= [SELECT UserId, User.Name, User.Email, RoleInTerritory2, User.FirstName, User.LastName FROM UserTerritory2Association];
        Map<Id,Id> mapTER = new Map<Id,Id>();
        for(ObjectTerritory2Association t : listTER){
            mapTER.put(t.ObjectID, t.Territory2Id);
        }*/
        String adherent = 'Adhérent';
        Date inamonth = Date.today().addMonths(1);
        Date sevendaysago = Date.today().addDays(-7);
        // Get all qualifications 
        List<Qualification_prospect_adherent__c> qualificationsPA = [SELECT Id,Date_de_fin__c,Compte__c,Compte__r.email__c,Name,Qualification__r.name,Description__c,Compte__r.nb_qualif_valides__c, RecordType.Name, Nom_du_sous_traitant__c FROM Qualification_prospect_adherent__c WHERE Compte__c != null AND Compte__r.type =:adherent AND Date_de_fin__c<= :inamonth AND Date_de_fin__c>= :sevendaysago ORDER BY Compte__c,Date_de_fin__c ];
        List<Qualification_prospect_adherent__c> qualificationsWithDuplicateAccounts = new List<Qualification_prospect_adherent__c>();
        
        List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
        List<Messaging.SingleEmailMessage> emailsAenvoyer = new List<Messaging.SingleEmailMessage>();

        // We have to treat each Adhérent only once, so we remove adhérent with many qualifications which end at same day
        if (qualificationsPA.size() > 0) {
            for (Integer i = 1; i < qualificationsPA.size(); i++) {
                System.debug('Incrément i : ' + i);
                System.debug('qualifProspectAdherents.size() : ' + qualificationsPA.size());
                if (qualificationsPA[i-1].Compte__c == qualificationsPA[i].Compte__c && qualificationsPA[i-1] != qualificationsPA[i] && qualificationsPA[i-1].Date_de_fin__c == qualificationsPA[i].Date_de_fin__c) {
                    qualificationsWithDuplicateAccounts.add(qualificationsPA[i]);
                }
            }
        }
        System.debug('Nombre de doublons comptes trouvés : '+ qualificationsWithDuplicateAccounts.size());

        for (Qualification_prospect_adherent__c qualifProspectAdherent:qualificationsPA) {
            
            System.debug('Qualifications :' + qualifProspectAdherent);
            System.debug('Date de fin de la qualification :' + qualifProspectAdherent.Date_de_fin__c);
            
            // Qualification expired in one month
            // QUALIFICATION THAT EXPIRED IN THE LAST MONTH 
            if (qualifProspectAdherent.Date_de_fin__c.addDays(-30).isSameDay(Date.today()) && qualifProspectAdherent.compte__r.nb_qualif_valides__c == 1) {
                qualifProspectAdherent.Dernier_niveau_de_relance__c = 'Relance préventive';
                qualifProspectAdherent.Date_de_derniere_relance__c = Date.today();
                
                // SEND EMAIL
                mails.add(getInformation(qualifProspectAdherent, qualificationsWithDuplicateAccounts, 0, owa));
                System.debug('Relance Month - 1 qualif : '+qualifProspectAdherent.Name);

            } else if (qualifProspectAdherent.Date_de_fin__c.addDays(1).isSameDay(Date.today()) && qualifProspectAdherent.compte__r.nb_qualif_valides__c <= 0) {
                // Qualification expired one day ago
                qualifProspectAdherent.Dernier_niveau_de_relance__c = 'Relance niveau 1';
                qualifProspectAdherent.Date_de_derniere_relance__c = Date.today();
                
                // SEND EMAIL
                mails.add(getInformation(qualifProspectAdherent, qualificationsWithDuplicateAccounts, 1, owa));
                System.debug('Relance day + 1 qualif : '+qualifProspectAdherent.Name);

            } else if (qualifProspectAdherent.Date_de_fin__c.addDays(7).isSameDay(Date.today()) && qualifProspectAdherent.compte__r.nb_qualif_valides__c <= 0) {
                // Qualification expired seven day ago
                qualifProspectAdherent.Dernier_niveau_de_relance__c = 'Relance niveau 2';
                qualifProspectAdherent.Date_de_derniere_relance__c = Date.today(); 
                
                // SEND EMAIL
                mails.add(getInformation(qualifProspectAdherent, qualificationsWithDuplicateAccounts, 2, owa));            
                System.debug('Relance day + 7 qualif : '+qualifProspectAdherent.Name);
            }
        }   

        // UPDATE QUALIFICATIONS PA
        try {
            update qualificationsPA;
        } catch(Exception e) {
            System.debug('Erreur update qualif ' +e.getmessage());
        }
        for (Messaging.SingleEmailMessage e : mails) {
            if(e.toaddresses != null){
                system.debug('destinataires : '+ e.toaddresses); 
                emailsAenvoyer.add(e);  
            }    
        }
        
        // SEND EMAIL
        Messaging.sendEmail(emailsAenvoyer);
    }

    private Messaging.SingleEmailMessage getInformation(Qualification_prospect_adherent__c qualifProspectAdherent, List<Qualification_prospect_adherent__c> qualificationsWithDuplicateAccounts, Integer indexRelance, OrgWideEmailAddress owa) {
        Messaging.SingleEmailMessage mailToSend = new Messaging.SingleEmailMessage();
        // To display the date in french format
        String dateFormatString = 'dd-MM-yyyy';
        Date d = qualifProspectAdherent.Date_de_fin__c;
        Datetime dt = Datetime.newInstance(d.year(),d.month(),d.day());
        String endDateString = dt.format(dateFormatString);
        String typQualif = qualifProspectAdherent.RecordType.Name;
        System.debug(endDateString);

        // Get all contacts to send them e mails
        List<Contact> contacts = [SELECT Id,Email,roles_du_contact__c FROM Contact WHERE roles_du_contact__c includes ('Interlocuteur administratif','Interlocuteur contrat','Interlocuteur commercial') AND AccountId IN (SELECT Compte__c FROM Qualification_prospect_adherent__c WHERE Id = :qualifProspectAdherent.Id)];
        System.debug('Requete SOQL 2 (contacts): ' + contacts);
        List<String> mailingList = new List<String>();
        // We add all recipients to contact by mail
        for (Contact contact:contacts) {
            mailingList.add(contact.Email);
        }
        
        User Assco = new User();            
        System.debug('COMPTE :' + qualifProspectAdherent.Compte__c );
        // Récupération du Territoire lié au compte auquel est associé la qualification
        Id TER ;
        try {
            //TER = [SELECT Territory2Id FROM ObjectTerritory2Association WHERE ObjectId = :qualifProspectAdherent.Compte__c LIMIT 1];
            TER = mapTER.get(qualifProspectAdherent.Compte__c);
        } catch (Exception e) {
            System.debug(e);
        }

        // Récupération des utilisateurs du territoire
        List<UserTerritory2Association> TerritoryUsers = new List<UserTerritory2Association>();
        try {
            TerritoryUsers = [SELECT UserId, User.Name, User.Email, RoleInTerritory2, User.FirstName, User.LastName FROM UserTerritory2Association WHERE Territory2Id = :TER];
        } catch (Exception e) {
            System.debug(e);
        }
        
        // We add all recipients to contact by mail
        for (UserTerritory2Association tuser:TerritoryUsers) {
            System.debug('Nom du tuser:TerritoryUsers : tuser.User.Email' + tuser.User.Email);

            // ADD RESPONSABLE SECTEUR TO THE MAILING LIST
            if (tuser.RoleInTerritory2 == 'Responsable de Secteur') {
                mailingList.add(tuser.User.Email);
                System.debug('Responsable de Secteur : tuser.User.Email' + tuser.User.Email);
            } 
            
            // ADD ASSISTANTE COMMERCIALE TO THE MAILING LIST
            if (tuser.RoleInTerritory2 == 'Assistant(e) Commercial(e)') {
                Assco.Id=tuser.UserId;
                Assco.FirstName = tuser.User.FirstName;
                Assco.LastName = tuser.User.LastName;
            }
        }
            
        Id ownerId = Assco.Id;
        String prenom_et_nom_assco = Assco.FirstName + ' ' + Assco.LastName ;
        if (Assco.FirstName == null || Assco.LastName == null || Assco.LastName.equals('') || Assco.FirstName.equals('')) {
            prenom_et_nom_assco = 'Votre Service client';
        }
        
        String mailBody = '';
        if (indexRelance == 0 && typQualif == 'Adhérent') {
            mailBody = '<style> table, th, td {border: 1px solid black;border-collapse: collapse;padding:1%;text-align:left;}</style>Bonjour,'+''+'<br/><br/>Vos qualifications, dont vous trouverez les détails ci-dessous, arrivent à échéance le   ' + endDateString + ': <br/><br/><table style="width:auto"><tr><th>Qualification</th><th>Libellé de la qualification</th><th>Date de fin de validité</th></tr><tr><td>'+qualifProspectAdherent.Qualification__r.name+'</td><td>'+qualifProspectAdherent.Description__c+'</td><td>'+endDateString+'</td></tr></table><br/><br/>Conformément à votre contrat (article 4) et pour éviter la suspension de vos droits, nous vous remercions de bien vouloir faire le nécessaire pour leur renouvellement, soit par retour de mail, soit à l’adresse suivante : <br/><br/><center>SYNERCIEL SERVICES<br/>Service Administratif<br/>21 avenue de Cambridge TSA 50004<br/>14203 HEROUVILLE SAINT CLAIR</center><br/><br/>Nous vous remercions par avance.<br/><br/>Bien cordialement,<br/><br/>Service administratif Synerciel<br/>0805 850 450<br/>administratif@synerciel.fr';
        }
        if (indexRelance == 0 && typQualif == 'Sous-traitant') {
            mailBody = '<style> table, th, td {border: 1px solid black;border-collapse: collapse;padding:1%;text-align:left;}</style> Bonjour,'+''+'<br/><br/>Les qualifications de vos sous-traitants, dont vous trouverez les détails ci-dessous, arrivent à échéance le   ' + endDateString + ': <br/><br/><table style="width:auto"><tr><th>Nom du sous-traitant</th><th>Qualification</th><th>Libellé de la qualification</th><th>Date de fin de validité</th></tr><tr><td>'+qualifProspectAdherent.Nom_du_sous_traitant__c+'</td><td>'+qualifProspectAdherent.Qualification__r.name+'</td><td>'+qualifProspectAdherent.Description__c+'</td><td>'+endDateString+'</td></tr></table><br/><br/>Conformément à votre contrat (article 4) et pour éviter la suspension de vos droits, nous vous remercions de bien vouloir faire le nécessaire pour leurs renouvellements, soit par retour de mail, soit à l’adresse suivante : <br/><br/><center>SYNERCIEL SERVICES<br/>Service Administratif<br/>21 avenue de Cambridge TSA 50004<br/>14203 HEROUVILLE SAINT CLAIR</center><br/><br/>Nous vous remercions par avance.<br/><br/>Bien cordialement,<br/><br/>Service administratif Synerciel<br/>0805 850 450<br/>administratif@synerciel.fr';
        }
        else if (indexRelance == 1  && typQualif == 'Adhérent') {
            if (ownerId == null) {
                ownerId = Label.Administratif_Synerciel_Id; // Administratif Synerciel
            }
            mailBody = '<style> table, th, td {border: 1px solid black;border-collapse: collapse;padding:1%;text-align:left;}</style>Bonjour,'+''+'<br/><br/>Vos qualifications, dont vous trouverez les détails ci-dessous, sont arrivées à échéance depuis le  ' + endDateString + ': <br/><br/><table style="width:auto"><tr><th>Qualification</th><th>Libellé de la qualification</th><th>Date de fin de validité</th></tr><tr><td>'+qualifProspectAdherent.Qualification__r.name+'</td><td>'+qualifProspectAdherent.Description__c+'</td><td>'+endDateString+'</td></tr></table><br/><br/>Conformément à votre contrat (article 4) et pour éviter la suspension de vos droits, nous vous remercions de bien vouloir faire le nécessaire pour leur renouvellement, soit par retour de mail, soit à l’adresse suivante : <br/><br/><center>SYNERCIEL SERVICES<br/>Service Administratif<br/>21 avenue de Cambridge TSA 50004<br/>14203 HEROUVILLE SAINT CLAIR</center><br/><br/>Nous vous remercions par avance.<br/><br/>Bien cordialement,<br/><br/>Service administratif Synerciel<br/>0805 850 450<br/>administratif@synerciel.fr';
            
            // CREATE TASK - Qualification(s) à mettre à jour
            Task task = new Task(Subject='Qualification(s) à mettre à jour', WhatId=qualifProspectAdherent.compte__c, OwnerId=ownerId, ActivityDate=Date.today(),descriptionShort__c='Référence qualification : '+qualifProspectAdherent.Name);
            try {
                upsert task;
            } catch(Exception e) {
                System.debug(e);
            }
        }
        else if (indexRelance == 1  && typQualif == 'Sous-traitant') {
            if (ownerId == null) {
                ownerId = Label.Administratif_Synerciel_Id; // Administratif Synerciel
            }
            mailBody = '<style> table, th, td {border: 1px solid black;border-collapse: collapse;padding:1%;text-align:left;}</style> Bonjour,'+''+'<br/><br/>Les qualifications de vos sous-traitants, dont vous trouverez les détails ci-dessous, sont arrivées à échéance le  ' + endDateString + ': <br/><br/><table style="width:auto"><tr><th>Nom du sous-traitant</th><th>Qualification</th><th>Libellé de la qualification</th><th>Date de fin de validité</th></tr><tr><td>'+qualifProspectAdherent.Nom_du_sous_traitant__c+'</td><td>'+qualifProspectAdherent.Qualification__r.name+'</td><td>'+qualifProspectAdherent.Description__c+'</td><td>'+endDateString+'</td></tr></table><br/><br/>Conformément à votre contrat (article 4) et pour éviter la suspension de vos droits, nous vous remercions de bien vouloir faire le nécessaire pour leurs renouvellements, soit par retour de mail, soit à l’adresse suivante : <br/><br/><center>SYNERCIEL SERVICES<br/>Service Administratif<br/>21 avenue de Cambridge TSA 50004<br/>14203 HEROUVILLE SAINT CLAIR</center><br/><br/>Nous vous remercions par avance.<br/><br/>Bien cordialement,<br/><br/>Service administratif Synerciel<br/>0805 850 450<br/>administratif@synerciel.fr';
            
            // CREATE TASK - Qualification(s) à mettre à jour
            Task task = new Task(Subject='Qualification(s) à mettre à jour', WhatId=qualifProspectAdherent.compte__c, OwnerId=ownerId, ActivityDate=Date.today(),descriptionShort__c='Référence qualification : '+qualifProspectAdherent.Name);
            try {
                upsert task;
            } catch(Exception e) {
                System.debug(e);
            }
        }
        else if (indexRelance == 2  && typQualif == 'Adhérent') {
            //todo delete, for testing
            if (ownerId == null) {
                ownerId = Label.Administratif_Synerciel_Id; // Administratif Synerciel
            }
            mailBody = '<style> table, th, td {border: 1px solid black;border-collapse: collapse;padding:1%;text-align:left;}</style>Bonjour,'+''+'<br/><br/>Vos qualifications, dont vous trouverez les détails ci-dessous, sont arrivées à échéance depuis le  ' + endDateString + ': <br/><br/><table style="width:auto"><tr><th>Qualification</th><th>Libellé de la qualification</th><th>Date de fin de validité</th></tr><tr><td>'+qualifProspectAdherent.Qualification__r.name+'</td><td>'+qualifProspectAdherent.Description__c+'</td><td>'+endDateString+'</td></tr></table><br/><br/>Conformément à votre contrat (article 4) et pour éviter la suspension de vos droits, nous vous remercions de bien vouloir faire le nécessaire pour leur renouvellement, soit par retour de mail, soit à l’adresse suivante : <br/><br/><center>SYNERCIEL SERVICES<br/>Service Administratif<br/>21 avenue de Cambridge TSA 50004<br/>14203 HEROUVILLE SAINT CLAIR</center><br/><br/>Nous vous remercions par avance.<br/><br/>Bien cordialement,<br/><br/>Service administratif Synerciel<br/>0805 850 450<br/>administratif@synerciel.fr';
            
            // CREATE TASK 'Appel téléphonique pour qualification'
            Task task = new Task(Subject='Appel téléphonique pour qualification', WhatId=qualifProspectAdherent.compte__c, OwnerId=ownerId, ActivityDate=Date.today(),descriptionShort__c='Référence qualification : '+qualifProspectAdherent.Name);
            try {
                upsert task;
            } catch(Exception e) {
                System.debug(e);
            }
        }
        else if (indexRelance == 2  && typQualif == 'Sous-traitant') {
            //todo delete, for testing
            if (ownerId == null) {
                ownerId = Label.Administratif_Synerciel_Id; // Administratif Synerciel
            }
            mailBody = '<style> table, th, td {border: 1px solid black;border-collapse: collapse;padding:1%;text-align:left;}</style> Bonjour,'+''+'<br/><br/>Les qualifications de vos sous-traitants, dont vous trouverez les détails ci-dessous, sont arrivées à échéance le  ' + endDateString + ': <br/><br/><table style="width:auto"><tr><th>Nom du sous-traitant</th><th>Qualification</th><th>Libellé de la qualification</th><th>Date de fin de validité</th></tr><tr><td>'+qualifProspectAdherent.Nom_du_sous_traitant__c+'</td><td>'+qualifProspectAdherent.Qualification__r.name+'</td><td>'+qualifProspectAdherent.Description__c+'</td><td>'+endDateString+'</td></tr></table><br/><br/>Conformément à votre contrat (article 4) et pour éviter la suspension de vos droits, nous vous remercions de bien vouloir faire le nécessaire pour leurs renouvellements, soit par retour de mail, soit à l’adresse suivante : <br/><br/><center>SYNERCIEL SERVICES<br/>Service Administratif<br/>21 avenue de Cambridge TSA 50004<br/>14203 HEROUVILLE SAINT CLAIR</center><br/><br/>Nous vous remercions par avance.<br/><br/>Bien cordialement,<br/><br/>Service administratif Synerciel<br/>0805 850 450<br/>administratif@synerciel.fr';
            
            // CREATE TASK 'Appel téléphonique pour qualification'
            Task task = new Task(Subject='Appel téléphonique pour qualification', WhatId=qualifProspectAdherent.compte__c, OwnerId=ownerId, ActivityDate=Date.today(),descriptionShort__c='Référence qualification : '+qualifProspectAdherent.Name);
            try {
                upsert task;
            } catch(Exception e) {
                System.debug(e);
            }
        }
        
        // add adhérent to contact
        mailingList.add(qualifProspectAdherent.compte__r.email__c);

        // If this qualification is the only one with this account 
        if (qualificationsWithDuplicateAccounts.isEmpty()) {
            try {
                mailToSend = sendMail(mailBody, mailingList, owa.id,qualifProspectAdherent.compte__c);
            } catch (Exception e) {
                System.debug(e);
            }
        } else if (!qualificationsWithDuplicateAccounts.contains(qualifProspectAdherent)) {
            try {
                mailToSend = sendMail(mailBody, mailingList, owa.id,qualifProspectAdherent.compte__c);
            } catch (Exception e) {
                System.debug(e);
            }
        }
        return(mailToSend);
    }

    private Messaging.SingleEmailMessage sendMail(String mailBody, List<String> mailingList, Id fromMail,Id whatID) {
        Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
        system.debug('mailinglist sendMail: '+ mailingList);
        message.toAddresses = mailingList;
        message.optOutPolicy = 'FILTER';
        message.subject = 'Relance Synerciel';
        message.setOrgWideEmailAddressId(fromMail);
        message.setHtmlBody(mailBody);
        message.setWhatId(whatID);
        message.setUseSignature(false);
        return(message);
        /*Messaging.SingleEmailMessage[] messages = new List<Messaging.SingleEmailMessage> {message};
        Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);

        if (results[0].success) {
            System.debug('The email was sent successfully.');
        } else {
            System.debug('The email failed to send: ' + results[0].errors[0].message);
        }*/
    }
}