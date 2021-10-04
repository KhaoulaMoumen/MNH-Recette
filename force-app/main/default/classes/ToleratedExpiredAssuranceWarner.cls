/* 

 * Copyright (C) EuraNov -- All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 * Written by Nathan Martin <nathan@euranov.com>, June 2019
 * Edited by Khaoula Moumen <khaoula.moumenn@talan.com>, June 2020

 */

global class ToleratedExpiredAssuranceWarner implements Database.Batchable<sObject>, Database.Stateful {
    
    public String query;
    transient List<Messaging.SingleEmailMessage> mails;
    transient List<Messaging.SingleEmailMessage> emailsAenvoyer; 
    String toleree = 'Tolérée';
    String adherent = 'Adhérent';
    private List<Assurances__c> assurances;
    
    // GET OWA - Service Administratif
    OrgWideEmailAddress owa = [select id, DisplayName, Address from OrgWideEmailAddress where DisplayName = 'Service Administratif' limit 1];
    
    
    global Database.QueryLocator start(Database.BatchableContext bc){
        
        this.assurances = new List<Assurances__c>();
        this.emailsAenvoyer = new List<Messaging.SingleEmailMessage>();
        
        this.query = 'SELECT Id,Date_de_fin__c,Compte__c,Compte__r.email__c,Name, RecordType.Name, Type_assurance__c, Compte__r.Name, Assurance__r.name, Nom_du_sous_traitant__c FROM Assurances__c WHERE Statut__c =:toleree AND Compte__c != null AND compte__r.Profil__c =:adherent ORDER BY Compte__c,Date_de_fin__c';
        return Database.getQueryLocator(this.query);
    }
    
    global void execute(Database.BatchableContext BC, List<Assurances__c> scope){
        
        mails = new List<Messaging.SingleEmailMessage>();
        List<Assurances__c> assurancesToUpdate = new List<Assurances__c>();
        
        System.debug('assurances : ' + scope);
        List<Assurances__c> assurancesWithDuplicateAccounts = new List<Assurances__c>();
        List<Assurances__c> assurancesDup = [SELECT Id, Date_de_fin__c, Compte__c, Compte__r.email__c, Name, Assurance__r.Name, RecordType.Name, Type_assurance__c,Compte__r.Name, Nom_du_sous_traitant__c FROM Assurances__c WHERE Statut__c =: toleree AND Compte__c != null AND Compte__r.Type=:adherent];
        
        // We have to treat each Adhérent only once, so we remove adhérent with many Assurances which end at same day
        if (assurancesDup.size()>0) {
            for (Integer i = 1; i < assurancesDup.size(); i++) {
                System.debug('Incrément i : ' + i);
                System.debug('assurancesWithDuplicateAccounts.size() : ' + assurancesWithDuplicateAccounts.size());
                if (assurancesDup[i-1].Compte__c == assurancesDup[i].Compte__c && assurancesDup[i-1] != assurancesDup[i] && assurancesDup[i-1].Date_de_fin__c == assurancesDup[i].Date_de_fin__c) {
                    assurancesWithDuplicateAccounts.add(assurancesDup[i]);
                }
            }
        }
        System.debug('Nombre de doublons comptes trouvés  : '+ assurancesWithDuplicateAccounts.size());
        System.debug('Liste des doublons comptes trouvés  : '+ assurancesWithDuplicateAccounts);
        System.debug('Liste complète  : '+ assurances);
        
        
        for(Assurances__c assurance : scope){
           System.debug('Assurances :' + assurance);
            System.debug('Date de fin de l\'assurance :' + assurance.Date_de_fin__c);
            System.debug('Date de fin de l\'assurance -7J:' + assurance.Date_de_fin__c.addDays(+120));

            // We check end date of assurance to do different treatment   
            // Assurance expire in 4 months - RELANCE PREVENTIVE
            if (assurance.Date_de_fin__c.addDays(-120).isSameDay(Date.today())) {
                assurance.Dernier_niveau_de_relance__c = 'Relance préventive';
                assurance.Date_de_derniere_relance__c = Date.today();
                assurancesToUpdate.add(assurance);
                mails.add(getInformation(assurance, assurancesWithDuplicateAccounts, 0, owa));
                System.debug('Relance Month - 4');

                // ASSURANCE EXPIRED IN 30 DAYS - RELANCE PREVENTIVE
            } else if (assurance.Date_de_fin__c.addDays(-30).isSameDay(Date.today())) {
                // Update dernier niveau de relance et date de derniere relance
                assurance.Dernier_niveau_de_relance__c = 'Relance préventive';
                assurance.Date_de_derniere_relance__c = Date.today();
                assurancesToUpdate.add(assurance);
                mails.add(getInformation(assurance, assurancesWithDuplicateAccounts, 1, owa));
                System.debug('Relance Month - 1');

                // ASSURANCE EXPIRED IN 7 DAYS - RELANCE NIVEAU 2
            } else if (assurance.Date_de_fin__c.addDays(-7).isSameDay(Date.today())) {
                // Update dernier niveau de relance et date de derniere relance
                assurance.Dernier_niveau_de_relance__c = 'Relance niveau 2';
                assurance.Date_de_derniere_relance__c = Date.today(); 
                assurancesToUpdate.add(assurance);
                mails.add(getInformation(assurance, assurancesWithDuplicateAccounts, 2, owa));
                System.debug('Relance day - 7');
            }
        }
        
         try {
            // Update the Account Record
            update assurancesToUpdate;
             
              // SEND ALL EMAILS
       if(mails.size() > 0 ) Messaging.sendEmail(mails);
        } catch (Exception e) {
            System.debug('Error update :' + e );
        }
    }
    
    global void finish(Database.BatchableContext BC){
      
    }
    
    
    private Messaging.SingleEmailMessage getInformation(Assurances__c assurance, List<Assurances__c> assurancesWithDuplicateAccounts, Integer indexRelance, OrgWideEmailAddress owa) {
        Messaging.SingleEmailMessage mailtoSend = new Messaging.SingleEmailMessage();
        // To display the date in french format
        String dateFormatString = 'dd-MM-yyyy';
        Date d = assurance.Date_de_fin__c;
        Datetime dt = Datetime.newInstance(d.year(),d.month(),d.day());
        String endDateString = dt.format(dateFormatString);
        String typeAssurance = assurance.RecordType.Name;
        System.debug(endDateString);

        // Get all contacts to send them e mails
        System.debug('Assurances ID :' + assurance.id);

        // GET CONTACTS RELATED TO ACCOUNTS OF ASSURANCES WITH ROLES INTERLOCUTEUR
        List<Contact> contacts = [SELECT Id,Email,roles_du_contact__c 
                                  FROM Contact
                                  WHERE roles_du_contact__c includes ('Interlocuteur administratif','Interlocuteur contrat','Interlocuteur commercial') AND AccountId IN (SELECT Compte__c FROM Assurances__c WHERE Statut__c LIKE '%Tol%'  AND Id = :assurance.Id)
                                 ];
        System.debug('Requete SOQL 2 (contacts): ' + contacts);
        List<String> mailingList = new List<String>();
        // We add all recipients to contact by mail
        for (Contact contact:contacts) {
            mailingList.add(contact.Email);
        }

        User Assco = new User();
        // Récupération du Territoire lié au compte auquel est associé l'assurance
        ObjectTerritory2Association TER = new ObjectTerritory2Association();
        try {
            TER = [SELECT Territory2Id FROM ObjectTerritory2Association WHERE ObjectId = :assurance.Compte__c LIMIT 1];
        } catch (Exception e) {
            System.debug(e);
        }
        // Récupération des utilisateurs du territoire
        List<UserTerritory2Association> TerritoryUsers = new List<UserTerritory2Association>();
        try {
            TerritoryUsers = [SELECT UserId, User.FirstName, User.LastName, User.Email, RoleInTerritory2 FROM UserTerritory2Association WHERE Territory2Id = :TER.Territory2Id];
        } catch (Exception e) {
            system.debug(e);
        }

        //ADD RESPONSABLE DE SECTEUR  OF THE TERRITORY TO THE MAILING LIST
        for (UserTerritory2Association tuser:TerritoryUsers) {
            if (tuser.RoleInTerritory2 == 'Responsable de Secteur') {
                mailingList.add(tuser.User.Email);
            }
            //TODO : possibilité de supprimer la formule et de get le mail de l'assco comme ça if RoleInTerritory2 == 'Assistant(e) Commercial(e)' ...
            //ADD ASSISTANTE COMMERCIALE OF THE TERRITORY TO THE MAILING LIST
            if (tuser.RoleInTerritory2 == 'Assistant(e) Commercial(e)') {
                Assco.Id=tuser.UserId;
                Assco.FirstName = tuser.User.FirstName;
                Assco.LastName = tuser.User.LastName;
            } 
        }
        
        // If we don't have first and lastname of assco
        String prenom_et_nom_assco = Assco.FirstName + ' ' + Assco.LastName ;
        if (prenom_et_nom_assco == ' ') {
            prenom_et_nom_assco = 'Votre service client';
        }

        // CREATE EMAIL BODY BASED ON INDEX
        String mailBody = '';
        if (indexRelance == 0 && typeAssurance == 'Adhérent') {
            //FIXME: Le contenu du mail est le même dans les 3 cas. Possible d'avoir qu'une seule version?
            mailBody = '<style> table, th, td {border: 1px solid black;border-collapse: collapse;padding:1%;text-align:left;}</style> Bonjour,'+''+'<br/><br/>Vos assurances, dont vous trouverez les détails ci-dessous, arrivent à échéance le  ' + endDateString + ': <br/><br/><table style="width:auto"><tr><th>Nom de votre assurance</th><th>Type d’assurance</th><th>Date de fin de validité</th></tr><tr><td>'+assurance.Assurance__r.name+'</td><td>'+assurance.Type_assurance__c+'</td><td>'+endDateString+'</td></tr></table><br/><br/>Conformément à votre contrat (article 4) et pour éviter la suspension de vos droits, nous vous remercions de bien vouloir faire le nécessaire pour leurs renouvellements, soit par retour de mail, soit à l’adresse suivante : <br/><br/><center>SYNERCIEL SERVICES<br/>Service Administratif<br/>21 avenue de Cambridge TSA 50004<br/>14203 HEROUVILLE SAINT CLAIR</center><br/><br/>Nous vous remercions par avance.<br/><br/>Bien cordialement,<br/><br/>Service administratif Synerciel<br/>0805 850 450<br/>administratif@synerciel.fr';
        }
        if (indexRelance == 0 && typeAssurance == 'Sous-traitant') {
            mailBody = '<style> table, th, td {border: 1px solid black;border-collapse: collapse;padding:1%;text-align:left;}</style> Bonjour,'+''+'<br/><br/>Les assurances de vos sous-traitants, dont vous trouverez les détails ci-dessous, arrivent à échéance le   ' + endDateString + ': <br/><br/><table style="width:auto"><tr><th>Nom du sous-traitant</th><th>Nom de votre assurance</th><th>Type d’assurance</th><th>Date de fin de validité</th></tr><tr><td>'+assurance.Nom_du_sous_traitant__c+'</td><td>'+assurance.Assurance__r.name+'</td><td>'+assurance.Type_assurance__c+'</td><td>'+endDateString+'</td></tr></table><br/><br/>Conformément à votre contrat (article 4) et pour éviter la suspension de vos droits, nous vous remercions de bien vouloir faire le nécessaire pour leurs renouvellements, soit par retour de mail, soit à l’adresse suivante : <br/><br/><center>SYNERCIEL SERVICES<br/>Service Administratif<br/>21 avenue de Cambridge TSA 50004<br/>14203 HEROUVILLE SAINT CLAIR</center><br/><br/>Nous vous remercions par avance.<br/><br/>Bien cordialement,<br/><br/>Service administratif Synerciel<br/>0805 850 450<br/>administratif@synerciel.fr';
        }
        else if (indexRelance == 1 && typeAssurance == 'Adhérent') {
            mailBody = '<style> table, th, td {border: 1px solid black;border-collapse: collapse;padding:1%;text-align:left;}</style> Bonjour,'+''+'<br/><br/>Vos assurances, dont vous trouverez les détails ci-dessous, arrivent à échéance le  ' + endDateString + ': <br/><br/><table style="width:auto"><tr><th>Nom de votre assurance</th><th>Type d’assurance</th><th>Date de fin de validité</th></tr><tr><td>'+assurance.Assurance__r.name+'</td><td>'+assurance.Type_assurance__c+'</td><td>'+endDateString+'</td></tr></table><br/><br/>Conformément à votre contrat (article 4) et pour éviter la suspension de vos droits, nous vous remercions de bien vouloir faire le nécessaire pour leurs renouvellements, soit par retour de mail, soit à l’adresse suivante : <br/><br/><center>SYNERCIEL SERVICES<br/>Service Administratif<br/>21 avenue de Cambridge TSA 50004<br/>14203 HEROUVILLE SAINT CLAIR</center><br/><br/>Nous vous remercions par avance.<br/><br/>Bien cordialement,<br/><br/>Service administratif Synerciel<br/>0805 850 450<br/>administratif@synerciel.fr';
        }
        else if (indexRelance == 1 && typeAssurance == 'Sous-traitant') {
            mailBody = '<style> table, th, td {border: 1px solid black;border-collapse: collapse;padding:1%;text-align:left;}</style> Bonjour,'+''+'<br/><br/>Les assurances de vos sous-traitants, dont vous trouverez les détails ci-dessous, arrivent à échéance le   ' + endDateString + ': <br/><br/><table style="width:auto"><tr><th>Nom du sous-traitant</th><th>Nom de votre assurance</th><th>Type d’assurance</th><th>Date de fin de validité</th></tr><tr><td>'+assurance.Nom_du_sous_traitant__c+'</td><td>'+assurance.Assurance__r.name+'</td><td>'+assurance.Type_assurance__c+'</td><td>'+endDateString+'</td></tr></table><br/><br/>Conformément à votre contrat (article 4) et pour éviter la suspension de vos droits, nous vous remercions de bien vouloir faire le nécessaire pour leurs renouvellements, soit par retour de mail, soit à l’adresse suivante : <br/><br/><center>SYNERCIEL SERVICES<br/>Service Administratif<br/>21 avenue de Cambridge TSA 50004<br/>14203 HEROUVILLE SAINT CLAIR</center><br/><br/>Nous vous remercions par avance.<br/><br/>Bien cordialement,<br/><br/>Service administratif Synerciel<br/>0805 850 450<br/>administratif@synerciel.fr';
        }
        else if (indexRelance == 2  && typeAssurance == 'Adhérent') {
            String ownerId = Assco.Id;
            //todo delete, for testing
            if (ownerId == null) {
                ownerId = Label.Administratif_Synerciel_Id; // Administratif Synerciel
            }
            // CREATE TASK APPEL TELEPHONIQUE
            Task task = new Task(Subject='Appel téléphonique pour assurance', WhatId=assurance.Compte__c, OwnerId=ownerId, ActivityDate=Date.today(),descriptionShort__c='Référence assurance : '+assurance.Name);
            mailBody = '<style> table, th, td {border: 1px solid black;border-collapse: collapse;padding:1%;text-align:left;}</style> Bonjour,'+''+'<br/><br/>Vos assurances, dont vous trouverez les détails ci-dessous, arrivent à échéance le  ' + endDateString + ': <br/><br/><table style="width:auto"><tr><th>Nom de votre assurance</th><th>Type d’assurance</th><th>Date de fin de validité</th></tr><tr><td>'+assurance.Assurance__r.name+'</td><td>'+assurance.Type_assurance__c+'</td><td>'+endDateString+'</td></tr></table><br/><br/>Conformément à votre contrat (article 4) et pour éviter la suspension de vos droits, nous vous remercions de bien vouloir faire le nécessaire pour leurs renouvellements, soit par retour de mail, soit à l’adresse suivante : <br/><br/><center>SYNERCIEL SERVICES<br/>Service Administratif<br/>21 avenue de Cambridge TSA 50004<br/>14203 HEROUVILLE SAINT CLAIR</center><br/><br/>Nous vous remercions par avance.<br/><br/>Bien cordialement,<br/><br/>Service administratif Synerciel<br/>0805 850 450<br/>administratif@synerciel.fr';

            try {
                // INSERT TASK
                upsert task;
            } catch(Exception e) {
                System.debug(e);
            }
        }
        else if (indexRelance == 2  && typeAssurance == 'Sous-traitant') {
            String ownerId = Assco.Id;
            //todo delete, for testing
            if (ownerId == null) {
                ownerId = Label.Administratif_Synerciel_Id; // Administratif Synerciel
            }
            // CREATE TASK APPEL TELEPHONIQUE
            Task task = new Task(Subject='Appel téléphonique pour assurance', WhatId=assurance.Compte__c, OwnerId=ownerId, ActivityDate=Date.today(),descriptionShort__c='Référence assurance : '+assurance.Name);
            mailBody = '<style> table, th, td {border: 1px solid black;border-collapse: collapse;padding:1%;text-align:left;}</style> Bonjour,'+''+'<br/><br/>Les assurances de vos sous-traitants, dont vous trouverez les détails ci-dessous, arrivent à échéance le  ' + endDateString + ': <br/><br/><table style="width:auto"><tr><th>Nom du sous-traitant</th><th>Nom de votre assurance</th><th>Type d’assurance</th><th>Date de fin de validité</th></tr><tr><td>'+assurance.Nom_du_sous_traitant__c+'</td><td>'+assurance.Assurance__r.name+'</td><td>'+assurance.Type_assurance__c+'</td><td>'+endDateString+'</td></tr></table><br/><br/>Conformément à votre contrat (article 4) et pour éviter la suspension de vos droits, nous vous remercions de bien vouloir faire le nécessaire pour leurs renouvellements, soit par retour de mail, soit à l’adresse suivante : <br/><br/><center>SYNERCIEL SERVICES<br/>Service Administratif<br/>21 avenue de Cambridge TSA 50004<br/>14203 HEROUVILLE SAINT CLAIR</center><br/><br/>Nous vous remercions par avance.<br/><br/>Bien cordialement,<br/><br/>Service administratif Synerciel<br/>0805 850 450<br/>administratif@synerciel.fr';

            try {
                // INSERT TASK
                upsert task;
            } catch(Exception e) {
                System.debug(e);
            }
        }
        
        System.debug('assurancesWithDuplicateAccounts.isEmpty()' + assurancesWithDuplicateAccounts.isEmpty());
        System.debug('!assurancesWithDuplicateAccounts.contains(assurance)' + !assurancesWithDuplicateAccounts.contains(assurance));

        // add adhérent to contact
        mailingList.add(assurance.Compte__r.email__c);

        // If this qualification is the only one with this account
        if (assurancesWithDuplicateAccounts.isEmpty()) {
            try {
                mailToSend = sendMail(mailBody, mailingList, owa.Id,assurance.Compte__c);
            } catch (Exception e) {
                System.debug(e);
            }
        } else if (!assurancesWithDuplicateAccounts.contains(assurance)) {
            try {
                mailToSend = sendMail(mailBody, mailingList, owa.Id,assurance.Compte__c);
            } catch (Exception e) {
                System.debug(e);
            }
        }
        return(mailtoSend);
    }

    // METHOD THAT SENDS EMAIL BASED ON PARAMS PASSED
    private Messaging.SingleEmailMessage sendMail(String mailBody, List<String> mailingList, Id fromMail, Id whatID) {
        Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
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