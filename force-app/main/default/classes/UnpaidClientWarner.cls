/* 

 * Copyright (C) EuraNov -- All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 * Written by Nathan Martin <nathan@euranov.com>, June 2019
 * Edited by Khaoula MOUMEN <khaoula.moumen@talan.com>, June 2020

 */

global class UnpaidClientWarner implements Schedulable {
    // TODO changer le Batch Schedule dans l'exec du batch car c'est le nom que l'on voit apparaitre dans sales force

    global void execute(System.SchedulableContext sc) {
        List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
        // GET OWEA SERVICE ADMINISTRATIF
        OrgWideEmailAddress owa = [SELECT id, DisplayName, Address FROM OrgWideEmailAddress where DisplayName = 'Service Administratif' LIMIT 1];
        List<Messaging.SingleEmailMessage> emailsAenvoyer = new List<Messaging.SingleEmailMessage>();

        System.debug('OrgWideEmailAddress ' + owa);
        
        String adherent = 'Adhérent';
        // GET UNPAID FACTURES RELATED TO ADHERENTS
        List<Facture__c> factures = [SELECT Id, Etat_de_la_facture__c, Date_d_ch_ance__c, Montant_TTC_Proratise__c, Nom_du_compte__c, N_de_Facture_NAV__c, Nom_du_compte__r.email__c,Name 
                                     FROM Facture__c
                                     WHERE Etat_de_la_facture__c IN ('Unpaid','Partly_paid','Impayée') AND Montant_TTC_Proratise__c > 0 AND Nom_du_compte__c != null AND Nom_du_compte__r.type =:adherent
                                     ORDER BY Nom_du_compte__c];
        
        List<Facture__c> facturesWithDuplicateAccounts = new List<Facture__c>();

        // We have to treat each Adhérent only once, so we remove adhérent with many factures which end at same day
        if (factures.size()>0) {
            for (Integer i = 1; i < factures.size(); i++) {
                System.debug('Facture : ' + factures[i].Name);
                System.debug('Incrément i : ' + i);
                System.debug('facturesWithDuplicateAccounts.size() : ' + facturesWithDuplicateAccounts.size());
                // ADD ACCOUNTS RELATED TO MULTIPLE FACTURES 
                if (factures[i-1].Nom_du_compte__c == factures[i].Nom_du_compte__c && factures[i-1] != factures[i]) {
                    facturesWithDuplicateAccounts.add(factures[i]);
                }
            }
        }
        System.debug('Nombre de doublons comptes trouvés  : '+ facturesWithDuplicateAccounts.size());
        System.debug('factures :' + factures);

        // We have to make a list with all accounts to update in data bases
        List<Account> accountsToUpdate = new List<Account>();

        for (Facture__c facture:factures) {
            
            // facture expired 7 days ago
            if (facture.Date_d_ch_ance__c.addDays(7).isSameDay(Date.today())) {
                // RELANCE NIV 1 - UPDATE ACCOUNT SITUATION FINANCIERE IMPAYE & DATE DE RELANCE
                Account myAccount = new Account(Id = facture.Nom_du_compte__r.Id, dernier_niveau_de_relance__c = 'Relance niveau 1', relanceDate__c = Date.today(), situation_financiere__c = 'En impayé');
                // We add the account to update on
                accountsToUpdate.add(myAccount);
                // SEND EMAIL + CREATE RELANCE TASK 
                mails.add(getInformation(facture, facturesWithDuplicateAccounts, 0, owa));
                System.debug('Relance days + 7');
                            
                // facture expired 15 days ago
            } else if (facture.Date_d_ch_ance__c.addDays(15).isSameDay(Date.today())) {
                // RELANCE NIV 2 - UPDATE ACCOUNT SITUATION FINANCIERE IMPAYE & DATE DE RELANCE
                Account myAccount = new Account(Id = facture.Nom_du_compte__r.Id, dernier_niveau_de_relance__c = 'Relance niveau 2', relanceDate__c = Date.today(), situation_financiere__c = 'En impayé');
                accountsToUpdate.add(myAccount);
                 // SEND EMAIL + CREATE RELANCE TASK 
                mails.add(getInformation(facture, facturesWithDuplicateAccounts, 1, owa));
                System.debug('Relance day + 15');
            }
        }
        
        try {
            // UPDATE ACCOUNTS
            update accountsToUpdate;
        } catch(Exception e) {
            System.debug(e);
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

    private Messaging.SingleEmailMessage getInformation(Facture__c facture, List<Facture__c> facturesWithDuplicateAccounts, Integer indexRelance, OrgWideEmailAddress owa) {
        Messaging.SingleEmailMessage mailToSend = new Messaging.SingleEmailMessage();
        // To display the date in french format
        String dateFormatString = 'dd-MM-yyyy';
        Date d = facture.Date_d_ch_ance__c;
        Datetime dt = Datetime.newInstance(d.year(),d.month(),d.day());
        String endDateString = dt.format(dateFormatString);
        System.debug('end date fenchformat :'+ endDateString);

        // Get all contacts to send them e mails
        List<Contact> contacts = [SELECT Id,Email,roles_du_contact__c FROM Contact WHERE roles_du_contact__c includes ('Interlocuteur administratif','Interlocuteur contrat','Interlocuteur commercial') AND AccountId IN (SELECT Nom_du_compte__c FROM Facture__c WHERE Etat_de_la_facture__c IN ('Unpaid','Partly_paid') AND Id = :facture.Id)];
        System.debug('Requete SOQL 2 (contacts): ' + contacts);
        List<String> mailingList = new List<String>();
        // We add all recipients to contact by mail
        for (Contact contact:contacts) {
            mailingList.add(contact.Email);
        }
        
        User Assco = new User();
        System.debug('COMPTE :' + facture.Nom_du_compte__c);
        // Récupération du Territoire lié au compte auquel est associé l'facture
        ObjectTerritory2Association TER = new ObjectTerritory2Association();
        try {
            TER = [SELECT Territory2Id FROM ObjectTerritory2Association WHERE ObjectId = :facture.Nom_du_compte__c LIMIT 1];
        } catch (Exception e) {
            System.debug(e);
        }
        // Récupération des utilisateurs du territoire
        List<UserTerritory2Association> TerritoryUsers = new List<UserTerritory2Association>();
        try {
            TerritoryUsers = [SELECT UserId, User.FirstName, User.LastName, User.Name, User.Email, RoleInTerritory2 FROM UserTerritory2Association WHERE Territory2Id = :TER.Territory2Id];
        } catch (Exception e) {
            system.debug(e);
        }
        // ADD RESPONSABLE DE SECTEUR DU TERRITOIRE TO THE MAILING LIST
        for (UserTerritory2Association tuser:TerritoryUsers) {
            if (tuser.RoleInTerritory2 == 'Responsable de Secteur') {
                mailingList.add(tuser.User.Email);
            } 
            // ADD ASSISTANTE COMMERCIALE DU TERRITOIRE TO THE MAILING LIST
            if (tuser.RoleInTerritory2 == 'Assistant(e) Commercial(e)') {
                Assco.Id=tuser.UserId;
                Assco.FirstName = tuser.User.FirstName;
                Assco.LastName = tuser.User.LastName;
                mailingList.add(tuser.User.Email);
            } 
        }
        
        // If we don't have first and lastname of assco
        String prenom_et_nom_assco = Assco.FirstName + ' ' + Assco.LastName ;
        if (Assco.FirstName == null || Assco.LastName == null || Assco.LastName.equals('') || Assco.FirstName.equals('')) {
            prenom_et_nom_assco = 'Votre service client';
        }

        String mailBody = '';
        if (indexRelance == 0) {
            mailBody = 'Madame, Monsieur, <br/><br/>Sauf erreur de notre part, votre facture référence '+ facture.N_de_Facture_NAV__c +' d’un montant de '+ facture.Montant_TTC_Proratise__c + '€ TTC n’est toujours pas réglée. Cette facture correspond au Droit d’Accès au Réseau SynerCiel pour l’année ' + Date.today().year() + '. <br/>Par conséquent, nous vous remercions de bien vouloir nous adresser votre règlement dans les meilleurs délais, à l’adresse suivante :<br/><br/><center>SYNERCIEL <br/>21 Avenue de Cambridge<br/>TSA 50004 14 200 HEROUVILLE SAINT CLAIR<br/><br/></center>Notre service adhérent reste à votre disposition pour répondre à vos éventuelles questions au 0.805.850.450. <br/><br/>Vous remerciant de faire le nécessaire et espérant une régularisation rapide de votre situation, nous vous prions d’agréer, Madame, Monsieur, nos salutations distinguées.<br/><br/>Service administratif Synerciel';
        }
        else if (indexRelance == 1) {
            String ownerId = Assco.Id;
            //todo delete, for testing
            if (ownerId == null) {
                ownerId = Label.Administratif_Synerciel_Id; // Administratif Synerciel
            }
            System.debug('Facture > 15 jours' + facture.Name);
            
            // CRAETE TASK APPEL TELEPHONIQUE
            Task task = new Task(Subject='Appel téléphonique pour impayé', WhatId=facture.Nom_du_compte__c, OwnerId=ownerId, ActivityDate=Date.today(),descriptionShort__c='Référence facture'+facture.Name);
            mailBody = 'Madame, Monsieur, <br/><br/>Sauf erreur de notre part, votre facture référence '+ facture.N_de_Facture_NAV__c +' d’un montant de '+ facture.Montant_TTC_Proratise__c + '€ TTC n’est toujours pas réglée. Cette facture correspond au Droit d’Accès au Réseau SynerCiel pour l’année ' + Date.today().year() + '. <br/>Par conséquent, nous vous remercions de bien vouloir nous adresser votre règlement dans les meilleurs délais, à l’adresse suivante :<br/><br/><center>SYNERCIEL <br/>21 Avenue de Cambridge<br/>TSA 50004 14 200 HEROUVILLE SAINT CLAIR<br/><br/></center>Notre service adhérent reste à votre disposition pour répondre à vos éventuelles questions au 0.805.850.450. <br/><br/>Vous remerciant de faire le nécessaire et espérant une régularisation rapide de votre situation, nous vous prions d’agréer, Madame, Monsieur, nos salutations distinguées.<br/><br/>Service administratif Synerciel';
        
            try {
                // INSERT TASK
                insert task;
            } catch(Exception e) {
                System.debug(e);
            }
        }

        /*try {
            upsert facture;
        } catch(Exception e) {
            System.debug(e);
        }*/

        // ADD ADHERENT EMAIL TO THE MAILING LIST
        mailingList.add(facture.Nom_du_compte__r.email__c);
        System.debug('Add adhérent address :' + facture.Nom_du_compte__r.email__c );

        // If this facture is the only one with this account 
        if (facturesWithDuplicateAccounts.isEmpty()) {
            try {
                mailToSend = sendMail(mailBody, mailingList,owa.id,facture.Nom_du_compte__c);
            } catch (Exception e) {
                System.debug(e);
            }
        } else if (!facturesWithDuplicateAccounts.contains(facture)) {
            try {
                mailToSend = sendMail(mailBody, mailingList, owa.id,facture.Nom_du_compte__c);
            } catch (Exception e) {
                System.debug(e);
            }
        }
        return(mailToSend);
    }

    // METHOD THAT SEND EMAIL WITH PARAMS PASSED 
    private Messaging.SingleEmailMessage sendMail(String mailBody, List<String> mailingList, Id fromMail, Id whatID) {
        Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
                
        //TODO : setBccAddresses(bccAddresses)
        message.toAddresses = mailingList;
        message.optOutPolicy = 'FILTER';
        message.subject = 'RELANCE POUR IMPAYE';
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