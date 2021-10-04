/* 

 * Copyright (C) EuraNov -- All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 * Written by Nathan Martin <nathan@euranov.com>, July 2019
 * Edited by Khaoula Moumen <khaoula.moumenn@talan.com>, June 2020

 */
public with sharing class EUR11_ExpQualifAfterUpdateTriggered {
    public EUR11_ExpQualifAfterUpdateTriggered(List<Task> tasks) {

        System.debug('My tasks : ' + tasks);
        System.debug('My tasks length : ' + tasks.size());
        
        // GET OWA - Service Administratif
        OrgWideEmailAddress owa = [select id, DisplayName, Address from OrgWideEmailAddress where DisplayName = 'Service Administratif' limit 1];

        // GET ACCOUNTS RELATED TO TASKS
        List<Id> accountIds = new List<Id>();
        for (Task task:tasks) {
            accountIds.add(task.whatId);
        }

        Date TODAY = Date.today();
        // GET ALL QUALIFICATIONS PA
        // GET EXPIRED QUALIFICATIONS PA
        List<Qualification_prospect_adherent__c> expiredQualificationsPA = [SELECT Id,Date_de_fin__c,Compte__c,Compte__r.email__c,Name FROM Qualification_prospect_adherent__c WHERE Compte__c IN :accountIds AND Date_de_fin__c < TODAY ORDER BY Compte__c];
        // GET VALID QUALIFICATION PA
        List<Qualification_prospect_adherent__c> validQualificationsPA = [SELECT Id,Date_de_fin__c,Compte__c,Compte__r.email__c,Name FROM Qualification_prospect_adherent__c WHERE Compte__c IN :accountIds AND Date_de_fin__c > TODAY ORDER BY Compte__c];

        System.debug('expiredQualificationsPA  size : ' + expiredQualificationsPA.size());
        System.debug('validQualificationsPA  size: ' + validQualificationsPA.size());
        System.debug('validQualificationsPA : ' + validQualificationsPA);

        // We make a set with all expired qualif and their account 
        Map<String, Qualification_prospect_adherent__c> expiredMap = new Map<String, Qualification_prospect_adherent__c>();
        for (Qualification_prospect_adherent__c eqpa:expiredQualificationsPA) {
            expiredMap.put(eqpa.compte__c,eqpa);
        }

        // We make a set with all valid qualif and their account 
        Map<String, Qualification_prospect_adherent__c> validMap = new Map<String, Qualification_prospect_adherent__c>();
        for (Qualification_prospect_adherent__c vqpa:validQualificationsPA) {
            validMap.put(vqpa.compte__c,vqpa);
        }

        List<Qualification_prospect_adherent__c> qualificationsPA = new List<Qualification_prospect_adherent__c>();

        // to send mail without duplicates
        for (Task task:tasks) {
            if (task.Status == 'Confirmer' && task.Subject == 'Mise en demeure – Motif : qualification échue') {
                if (expiredMap.get(task.whatId) != null) {
                    // expired since more than since 7 days
                    Qualification_prospect_adherent__c qualifPA = expiredMap.get(task.whatId);
                    // TODO trancher avec client qui est prioritaire si plusieurs qualifs qui respectent ces conditions mais comme pas de doublons elles ne sont mêmes pas dans la map (notamment les plus vieilles peuvent sauter)
                    if (qualifPA.Date_de_fin__c.addDays(7) < TODAY) {
                        // expired since less than since 7 days 
                        getInformation(task, qualifPA, owa, 2);   
                        System.debug('Relance expirée de plus de 7 jours ');
                    } else if (qualifPA.Date_de_fin__c.addDays(7) > TODAY) {
                        getInformation(task, qualifPA, owa, 1); 
                        System.debug('Relance expirée de moins de 7 jours ');
                    }
                }
                if (validMap.get(task.whatId) != null) {
                    Qualification_prospect_adherent__c qualifPA = validMap.get(task.whatId);
                    getInformation(task, qualifPA, owa, 0);
                    System.debug('Relance de qualif valide');
                } 
            }
        }
        
        for (Task task:tasks) {
            // to update every fields of expired qualifications
            for (Qualification_prospect_adherent__c eqpa:expiredQualificationsPA) {
                // to update every fields of qualifications
                if (task.Status == 'Confirmer' && task.Subject == 'Mise en demeure – Motif : qualification échue') {
                // expired since more than since 7 days
                    // TODO trancher avec client qui est prioritaire si plusieurs qualifs qui respectent ces conditions
                    if (eqpa.Date_de_fin__c.addDays(7) < TODAY) {
                        
                        // QUALIF THAT WILL EXPIRED IN THE LAST 7 DAYS -- RELANCE NIVEAU 2
                        // expired since less than since 7 days -- RELANCE NIVEAU 2
                        eqpa.Dernier_niveau_de_relance__c = 'Relance niveau 2';
                        eqpa.Date_de_derniere_relance__c = Date.today();
                        qualificationsPA.add(eqpa); 
                        System.debug('MAJ des champs de la qualif expirée depuis plus de 7 jours');
                    } else if (eqpa.Date_de_fin__c.addDays(7) > TODAY) {
                        // QUALIF THAT WILL EXPIRE IN THE NEXT 7 DAYS -- RELANCE NIVEAU 1
                        eqpa.Dernier_niveau_de_relance__c = 'Relance niveau 1';
                        eqpa.Date_de_derniere_relance__c = Date.today();
                        qualificationsPA.add(eqpa);
                        System.debug('MAJ des champs de la qualif expirée depuis moins de 7 jours ');
                    }
                }
            } 
        }
        try {
            update qualificationsPA;
        } catch(Exception e) {
            System.debug(e);
        }
    }

    private void getInformation(Task task, Qualification_prospect_adherent__c qualifPA, OrgWideEmailAddress owa, Integer indexRelance) {

        // To display the date in french format
        String dateFormatString = 'dd-MM-yyyy';
        Date d = qualifPA.Date_de_fin__c;
        Datetime dt = Datetime.newInstance(d.year(),d.month(),d.day());
        String endDateString = dt.format(dateFormatString);
        System.debug(endDateString);

        // Get all contacts to send them e mails
        List<Contact> contacts = [SELECT Id,Email,roles_du_contact__c FROM Contact WHERE roles_du_contact__c includes ('Interlocuteur administratif','Interlocuteur contrat','Interlocuteur commercial') AND AccountId IN (SELECT Compte__c FROM Qualification_prospect_adherent__c WHERE Id = :qualifPA.Id)];
        System.debug('Requete SOQL 2 (contacts): ' + contacts);
        List<String> mailingList = new List<String>();
        // We add all recipients to contact by mail
        for (Contact contact:contacts) {
            mailingList.add(contact.Email);
        }
        
        User Assco = new User();            
        System.debug('COMPTE :' + qualifPA.Compte__c );
        // Récupération du Territoire lié au compte auquel est associé la qualification
        ObjectTerritory2Association TER = new ObjectTerritory2Association();
        try {
            TER = [SELECT Territory2Id FROM ObjectTerritory2Association WHERE ObjectId = :qualifPA.Compte__c LIMIT 1];
        } catch (Exception e) {
            System.debug(e);
        }

        // Récupération des utilisateurs du territoire
        List<UserTerritory2Association> TerritoryUsers = new List<UserTerritory2Association>();
        try {
            TerritoryUsers = [SELECT UserId, User.Name, User.Email, RoleInTerritory2, User.FirstName, User.LastName FROM UserTerritory2Association WHERE Territory2Id = :TER.Territory2Id];
        } catch (Exception e) {
            System.debug(e);
        }
        
        // We add all recipients to contact by 
        for (UserTerritory2Association tuser:TerritoryUsers) {
            System.debug('Nom du tuser:TerritoryUsers : tuser.User.Email' + tuser.User.Email);

            if (tuser.RoleInTerritory2 == 'Responsable de Secteur') {
                mailingList.add(tuser.User.Email);
                System.debug('Responsable de Secteur : tuser.User.Email' + tuser.User.Email);
            } 
            if (tuser.RoleInTerritory2 == 'Assistant(e) Commercial(e)') {
                Assco.Id=tuser.UserId;
                Assco.Email= tuser.User.Email;
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
        if (indexRelance == 0) {
            mailBody = 'Bonjour,'+''+'<br/><br/>Vos qualifications arrivent à échéance le ' + endDateString + '.<br/><br/>Conformément à votre contrat (article 4) et pour éviter la suspension de vos droits, nous vous remercions de bien vouloir faire le nécessaire pour leurs renouvellements, soit par retour de mail, soit à l’adresse suivante : <br/><br/><center>SYNERCIEL SERVICES<br/>Service Administratif<br/>21 avenue de Cambridge TSA 50004<br/>14203 HEROUVILLE SAINT CLAIR</center><br/><br/>Nous vous remercions par avance.<br/><br/>Bien cordialement,<br/><br/>Service administratif Synerciel';
        }
        else if (indexRelance == 1) {
            if (ownerId == null) {
                ownerId = Label.Administratif_Synerciel_Id; // Administratif Synerciel
            }
            mailBody = 'Bonjour,'+''+'<br/><br/>Vos qualifications sont arrivées à échéance depuis le ' + endDateString + '.<br/><br/>Conformément à votre contrat (article 4) et pour éviter la suspension de vos droits, nous vous remercions de bien vouloir faire le nécessaire pour leurs renouvellements au plus vite, soit par retour de mail, soit à l’adresse suivante :<br/><br/><center>SYNERCIEL SERVICES<br/>Service Administratif<br/>21 avenue de Cambridge TSA 50004<br/>14203 HEROUVILLE SAINT CLAIR</center><br/>Nous vous remercions par avance.<br/><br/>Bien cordialement,<br/><br/>Service administratif Synerciel';
        }
        else if (indexRelance == 2) {
            //todo delete, for testing
            if (ownerId == null) {
                ownerId = Label.Administratif_Synerciel_Id; // Administratif Synerciel
            }
            mailBody = 'Bonjour,'+'' +'<br/><br/>Vos qualifications sont arrivées à échéance depuis le ' + endDateString + '.<br/><br/>Malgré notre dernière relance et sauf erreur de notre part, vous n\'avez pas renouvelé votre qualification.<br/><br/>Conformément à votre contrat (article 4) et pour éviter la suspension de vos droits, nous vous remercions de bien vouloir renouveler au plus vite, soit par retour de mail, soit à l’adresse suivante :<br/><br/><center>SYNERCIEL SERVICES<br/>Service Administratif<br/>21 avenue de Cambridge TSA 50004<br/>14203 HEROUVILLE SAINT CLAIR</center><br/>Nous vous remercions par avance.<br/><br/>Bien cordialement,<br/><br/>Service administratif Synerciel';
        }
        
        // add adhérent to contact
        mailingList.add(qualifPA.compte__r.email__c);

        // If this qualification is the only one with this account 
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
    //     message.subject = 'Relance Synerciel';
    //     message.setOrgWideEmailAddressId(fromMail);
    //     message.setHtmlBody(mailBody);
    //     Messaging.SingleEmailMessage[] messages = new List<Messaging.SingleEmailMessage> {message};
    //     Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);

    //     if (results[0].success) {
    //         System.debug('The email was sent successfully.');
    //     } else {
    //         System.debug('The email failed to send: ' + results[0].errors[0].message);
    //     }
    // }
}