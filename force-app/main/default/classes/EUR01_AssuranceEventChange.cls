/* 

 * Copyright (C) EuraNov -- All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 * Written by Gautier Swiercz <gautier@euranov.com>, June 2019

 */
public class EUR01_AssuranceEventChange {

    Public List<Assurance__c> oldAssurance {get;set;}
    Public List<Assurance__c> newAssurance {get;set;}
    Public Map<Id, Assurance__c> historyAssurance {get;set;}
    Public OrgWideEmailAddress defaultAdress {get;set;}
    List<Messaging.SingleEmailMessage> mails {get;set;}
    String adherent = 'Adhérent';
    String serviceadm = 'Service Administratif';

    Public EUR01_AssuranceEventChange(List<Assurance__c> OldList, List<Assurance__c> NewList) {
        
        System.debug('Detection dun changement sur Assurance');
        this.oldAssurance = OldList;
        historyAssurance = new Map<Id, Assurance__c>(OldList);
        this.newAssurance = NewList;
        this.defaultAdress = [select id, DisplayName, Address from OrgWideEmailAddress where DisplayName =:serviceadm limit 1];
        this.mails = new List<Messaging.SingleEmailMessage>();
        manageStatus();
        System.debug('Taille liste email : ' + mails.size());
        if(!Test.isRunningTest()) Messaging.sendEmail(mails);

        System.debug('Detection terminée');
    }

    // CHECK ASSURANCE PREVIOUS STATUS IF IT HAS CHANGED
    Public void manageStatus() {
        System.debug('Manage assurance Status');
        for (Assurance__c currentAssurance : newAssurance) {
            if (checkPreviousStatus(currentAssurance)) {
                statusChangedEvent(currentAssurance);
                System.debug('Le statut a évolué : ' + currentAssurance.Statut_Assurance__c);
            }
        }
    }

    Public void statusChangedEvent(Assurance__c currentAssurance) {
		// IF ASSURANCE PASSE A TOLEREE OU INTERDITE
        if (currentAssurance.Statut_Assurance__c.equals('Tolérée') ||  currentAssurance.Statut_Assurance__c.equals('Interdite')) {
            List<Assurances__c> allRelated = [SELECT ID, Date_de_debut__c, Date_de_fin__c, Compte__c, Compte__r.Type, Compte__r.email__c
            FROM Assurances__c WHERE Assurance__c =:currentAssurance.ID AND Compte__r.Profil__c =:adherent AND Date_de_fin__c >=:Date.today()];
            
            // GET ASSURANCES RELATED TO CONVERTED LEADS
            List<Assurances__c> IdleadsToUpdate = [Select Prospect__c from Assurances__c where Assurance__c =:currentAssurance.ID and Prospect__r.isConverted = false];
            List<Lead> updatedLeads = new List<Lead>();
            // UPDATE LEADS FIELD 'Assurance_hors_liste_autoris_e__c' TO TRUE
            for (Assurances__c a : IdleadsToUpdate){
                updatedLeads.add(new Lead(Id=a.Prospect__c,Assurance_hors_liste_autoris_e__c = true));
            }
            System.debug('updatedLeads: ' + updatedLeads);
            try{
                System.debug('mise à jour lead assurance non autorisée');
                // UPDATE LEADS RELATED TO ASSURANCES NON TOLEREE
                update(updatedLeads);
            }
            catch(Exception e){
                System.debug('Problème lors de la mise à jour des prospects : ' + e.getMessage());
            }
			System.debug('currentAssurance : ' + currentAssurance.id);
			System.debug('allRelated : ' + allRelated);

            if (allRelated.size() <= 0) {
                return;
            }
            Set<Id> accountIDs = setAccount(allRelated);
            // GET CONTACTS REKATED TO THE ASSURANCES ACCOUNTS
            List<Contact> contacts = [SELECT Id,Email, AccountID, LastName, FirstName, roles_du_contact__c FROM Contact WHERE roles_du_contact__c includes ('Interlocuteur administratif','Interlocuteur contrat','Interlocuteur facturation') AND AccountId IN :accountIDs];
            displayContactList(contacts);
            for (Assurances__c myRelated : allRelated) {
                System.debug('Sending Email for : ' + myRelated.Id + ' Email : ' + myRelated.Compte__r.email__c);
                System.debug('OrgAdress Mail : ' + defaultAdress);
                // SEND EMAIL
                setMailingList(myRelated.Compte__c, contacts, currentAssurance.Statut_Assurance__c);
            }
            } else {
			// GET CONVERTED LEADS RELATED TO CURRENT ASSURANCE
             List<Assurances__c> IdleadsToUpdate = [Select Prospect__c from Assurances__c where Assurance__c =:currentAssurance.ID and Prospect__r.isConverted = false];
            List<Lead> updatedLeads = new List<Lead>();
                // UPDATE LEADS FIELD 'Assurance_hors_liste_autoris_e__c' TO FALSE
            for (Assurances__c a : IdleadsToUpdate){
                updatedLeads.add(new Lead(Id=a.Prospect__c,Assurance_hors_liste_autoris_e__c = false));
            }
            try{
                System.debug('mise à jour lead assurance autorisée');
                // UPDATE LEADS RELATED TO ASSURANCES AUTORISEE
                update(updatedLeads);
            }
            catch(Exception e){
                System.debug('Problème lors de la mise à jour des prospects : ' + e.getMessage());
            }
        }
    }

    Public Set<Id> setAccount(List<Assurances__c> allRelated) {
        Set<Id> tmpSet = new Set<Id>();
        for (Assurances__c tmp : allRelated) {
            tmpset.add(tmp.Compte__c);
        }
        return tmpSet;
    }

    Public void setMailingList(String AccountID, List<Contact> contactList, String Status) {
        List<String> mailingList = new List<String>();
        User Assco = new User();
        ObjectTerritory2Association TER = new ObjectTerritory2Association();
        System.debug('ID DU COMPTE : ' + AccountID);
        try {
            // GET THE TERRITORY OF THE ACCOUNT RELATED TO THE ASSURANCE
            TER = [SELECT Id, Territory2Id FROM ObjectTerritory2Association WHERE ObjectId = :AccountID LIMIT 1];
            System.debug('ID DU TERRITOIRE : ' + TER.Id);
        } catch (Exception e) {
            System.debug('Problème lors de la récupération du territoir associé : ' + e.getMessage());
        }

        List<UserTerritory2Association> TerritoryUsers = new List<UserTerritory2Association>();
        try {
            // GET USERS IN THE ACCOUNT TERRITORY
            TerritoryUsers = [SELECT UserId, User.LastName, User.FirstName, User.Email, RoleInTerritory2 FROM UserTerritory2Association WHERE Territory2Id = :TER.Territory2Id];
            System.debug('LIST SIZE : ' + TerritoryUsers.size());
        } catch (Exception e) {
            system.debug('Problème lors de la récupération des utilisateurs associés au territoire :' + e.getMessage());
        }
        String AsscoName = '';
        // GET THE ASSISTANT COMMERCIAL OF THE TERRITORY
        for (UserTerritory2Association tuser: TerritoryUsers) {
            System.debug('User associé : ' + tuser.User.Lastname + tuser.User.FirstName);
            if (tuser.RoleInTerritory2 == 'Assistant(e) Commercial(e)') {
                System.debug('Assistant(e) associé(e) : ');
                if (tuser.User.LastName != null || !(tuser.User.LastName.equals('')) || tuser.User.LastName != 'null') {
                    AsscoName = tuser.User.LastName;
                }
                if (tuser.User.FirstName != null || !(tuser.User.FirstName.equals('')) || tuser.User.FirstName != 'null') {
                    AsscoName = AsscoName + ' ' + tuser.User.FirstName;
                }
            } 
        }

        for (Contact con : contactList) {
            System.debug('con.AccountID.equals(AccountID' + con.AccountID.equals(AccountID));
            if (con.AccountID.equals(AccountID)) {
                String Name = '';
                if (con.LastName != null || !(con.LastName.equals('')) || con.LastName != 'null') {
                    Name = con.LastName;
                }
                if (con.FirstName != null || !(con.FirstName.equals('')) || con.FirstName != 'null') {
                    Name = Name + ' ' + con.FirstName;
                }
                mailingList.add(con.Email);
                String body = '';
				// BODY OF THE EMAIL - ASSURANCE'S STATUS TOLEREE
                if (Status.equals('Tolérée')) {
                    body = 'Bonjour M. ' + Name + ',<br/><br/>L\'assureur que vous avez choisi et pour lequel nous avions conclu notre contrat ne répond plus<br/>entièrement aux exigences de qualité de notre réseau.<br/><br/>Votre dossier est à jour mais vous remercions à l\'avance de procéder à leur modification lors du<br/>prochain renouvellement de contrat.<br/><br/>Nous restons à votre disposition pour tout renseignement au 0805 850 450.<br/><br/>Bien cordialement<br/><br/>Service administratif Synerciel';
                }
                // BODY OF THE EMAIL - ASSURANCE'S STATUS INTERDITE
                else if (Status.equals('Interdite')) {
                    body = 'Bonjour M. ' + Name + ',<br/><br/>L\'assureur que vous avez choisi et pour lequel nous avions conclu notre contrat ne répond plus aux exigences de qualité de notre réseau.<br/><br/>Nous vous remercions à l’avance de nous présenter un nouveau contrat d\'assurance sous 7 jours. Dans le cas contraire, vous vous exposez à une exclusion de notre réseau.<br/><br/>Nous restons à votre disposition pour tout renseignement au 0805 850 450.<br/><br/>Bien cordialement<br/><br/>Service administratif Synerciel';
                }
                // SEND EMAIL
                sendMail(body, mailingList, defaultAdress.Id, con.AccountID);
            }
        }
    }

    Public void sendMail(String mailBody, List<String> mailingList, Id fromMail, Id whatID) {
        Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
        
        message.toAddresses = mailingList;
        message.optOutPolicy = 'FILTER';
        message.subject = 'Relance Synerciel';
        message.setOrgWideEmailAddressId(fromMail);
        message.setHtmlBody(mailBody);
        message.setWhatId(whatID);
        message.setUseSignature(false);
        mails.add(message);
        //Messaging.SingleEmailMessage[] messages = new List<Messaging.SingleEmailMessage> {message};
        //Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);

        /*if (results[0].success) {
            System.debug('The email was sent successfully.');
        } else {
            System.debug('The email failed to send: ' + results[0].errors[0].message);
        }*/

    }



    //Fonction de vérification et d'interpretation des données
    Public Boolean checkPreviousStatus(Assurance__c myAssurance) {
        Assurance__c oldTmp = historyAssurance.get(myAssurance.ID);
        if (oldTmp == null) {
            return false;
        }
        else if ((oldTmp.Statut_Assurance__c != myAssurance.Statut_Assurance__c)) {
            return true;
        }
        return false;
    }

    Public void displayContactList(List<Contact> myList) {
        for (Contact con : myList) {
            System.debug('Contact récupéré : ' + con.LastName + ' ' + con.Email);
        }
    }
}