/* 

 * Copyright (C) EuraNov -- All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 * Written by Nathan Martin <nathan@euranov.com>, June 2019

 */
public with sharing class UnpaidFormalNoticeTriggered {
    public UnpaidFormalNoticeTriggered(List<Task> tasks) {
        System.debug('Tasks : ' + tasks);
        String unpaid = 'Impayée';
        String adherent = 'Adhérent';
        // Useless because of desactivating mails sending
        // OrgWideEmailAddress owa = [select id, DisplayName, Address from OrgWideEmailAddress where DisplayName = 'Service Administratif' limit 1];
        
        List<Id> accountIds = new List<Id>();
        
        // SET ACCOUNTS IDS RELATED TO TASKS
        for (Task task:tasks) {
            accountIds.add(task.whatid);
        }

        // GET UNPAID FACTURES RELATED TO ADHERENTS 
        List<Facture__c> factures = [SELECT Id, Etat_de_la_facture__c, Date_d_ch_ance__c, Montant_TTC_Proratise__c, Nom_du_compte__c, Nom_du_compte__r.email__c
                                     FROM Facture__c 
                                     WHERE Etat_de_la_facture__c =:unpaid AND Montant_TTC_Proratise__c > 0 AND Nom_du_compte__c IN :accountIds AND Nom_du_compte__r.type =:adherent 
                                     ORDER BY Nom_du_compte__c];
        
        // System.debug('account[0].Id :  '+ account[0].Id);
        // System.debug('facture.Nom_du_compte__c :  '+ facture.Nom_du_compte__c);
        //if (account[0].Id == facture.Nom_du_compte__c) {


        for (Facture__c facture:factures) {
            System.debug('Facture : ' + facture);
            for (Task task:tasks) {
                System.debug('Task : ' + task);

                if (task.whatid == facture.Nom_du_compte__c) {
					
                    // MAIL BODY CHANGES BASED ON INDEX 0 AND 1
                    if (task.Subject == 'Mise en demeure – Motif : impayés' && task.Status == 'Confirmer') {
                        getInformation(task, facture, 0);
                    } else if (task.Subject == 'Résiliation - Motif : impayés' && task.Status == 'Confirmer') {
                        getInformation(task, facture, 1);
                    }
                    if (task.Subject == 'Mise en demeure – Motif : impayés' && task.Status == 'Confirmer' && task.CompletedDateTime.addDays(45) < Date.today()) {
                        // facture expired 45 day ago
                        getInformation(task, facture, 1);
                        System.debug('Relance impayé depuis plus de 45 jours');
                    }
                }
            }
        }
    }

    // todo : add OrgWideEmailAddress owa if you have to send mails (in coment for now)
    private void getInformation(Task task, Facture__c facture, Integer indexRelance) {
        
        System.debug('account[0].Id :  '+ task.whatid);
        System.debug('facture.Nom_du_compte__c :  '+ facture.Nom_du_compte__c);
        
        if (task.whatid == facture.Nom_du_compte__c) {

            List<String> mailingList = new List<String>();
            System.debug('Account :' + task.whatid);

            // To display the date in french format
            String dateFormatString = 'dd-MM-yyyy';
            Date d = facture.Date_d_ch_ance__c;
            Datetime dt = Datetime.newInstance(d.year(),d.month(),d.day());
            String endDateString = dt.format(dateFormatString);
            System.debug('end date fench format :'+ endDateString);

            User Assco = new User();
            System.debug('COMPTE :' + task.whatid);
            // Récupération du Territoire lié au compte auquel est associé la facture
            ObjectTerritory2Association TER = new ObjectTerritory2Association();
            try {
                TER = [SELECT Territory2Id FROM ObjectTerritory2Association WHERE ObjectId = :task.whatid LIMIT 1];
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
                // GET RESPONSABLE SECTEUR
                if (tuser.RoleInTerritory2 == 'Responsable de Secteur') {
                    mailingList.add(tuser.User.Email);
                    system.debug('Responsable de Secteur' + tuser.User.Email);
                } 
                // GET ASSISTANCE COMMERCIALE
                if (tuser.RoleInTerritory2 == 'Assistant(e) Commercial(e)') {
                    Assco.Id=tuser.UserId;
                    mailingList.add(tuser.User.Email);
                    system.debug('Assistant(e) Commercial(e)' + tuser.User.Email);
                } 
            }

            String mailBody = '';
            if (indexRelance == 0) {
                // add adhérent to contact
                mailingList.add(facture.Nom_du_compte__r.email__c);
                mailBody = 'Madame, Monsieur, <br><br>Nous constatons que malgré nos précédentes lettres de vous n\'avez toujours pas procédé au règlement de la facture référencée ci-dessus, échue le ' + endDateString +'.Votre compte reste donc débiteur à ce jour de la somme de '+ facture.Montant_TTC_Proratise__c +' euros TTC représentant le montant du Droit d’Accès au réseau SynerCiel. <br>En conséquence, nous vous mettons en demeure par la présente lettre recommandée de nous régler la somme de '+ facture.Montant_TTC_Proratise__c +' euros TTC sous huitaine, à défaut nous nous verrions contraints de recouvrer notre créance par voie judiciaire. <br>Le règlement est à effectuer par virement sur le compte suivant en précisant la référence :<center><br><br>SYNERCIEL SAS<br>IBAN :FR76  1820  6001  5060  2748  4008  347<br>BIC : AGRIFRPP882<br><br><br></center>Nous nous permettons également de vous indiquer que si vous n\'honorez pas le règlement après cette relance, nous serons amenés à vous facturer les intérêts de retard prévus dans nos conditions de vente. <br>Nous sommes persuadés que vous nous éviterez de recourir à ces mesures. <br><br>Veuillez agréer, Madame, Monsieur, nos salutations distinguées.<br><br>Nicolas REYDELLET<br>Directeur Administratif et Financier';
            }
            else if (indexRelance == 1) {
                // add accounting service
                mailingList.add('comptabilite@synerciel.fr');
                mailBody = 'TODO : ajouter l\'adresse mail du service comptabilité <br><br>Madame, Monsieur, <br><br>Nous constatons que malgré nos précédentes lettres de vous n\'avez toujours pas procédé au règlement de la facture référencée ci-dessus, échue le ' + endDateString +'.Votre compte reste donc débiteur à ce jour de la somme de '+ facture.Montant_TTC_Proratise__c +' euros TTC représentant le montant du Droit d’Accès au réseau SynerCiel. <br>En conséquence, nous vous mettons en demeure par la présente lettre recommandée de nous régler la somme de '+ facture.Montant_TTC_Proratise__c +' euros TTC sous huitaine, à défaut nous nous verrions contraints de recouvrer notre créance par voie judiciaire. <br>Le règlement est à effectuer par virement sur le compte suivant en précisant la référence :<center><br><br>SYNERCIEL SAS<br>IBAN :FR76  1820  6001  5060  2748  4008  347<br>BIC : AGRIFRPP882<br><br><br></center>Nous nous permettons également de vous indiquer que si vous n\'honorez pas le règlement après cette relance, nous serons amenés à vous facturer les intérêts de retard prévus dans nos conditions de vente. <br>Nous sommes persuadés que vous nous éviterez de recourir à ces mesures. <br><br>Veuillez agréer, Madame, Monsieur, nos salutations distinguées.<br><br>Nicolas REYDELLET<br>Directeur Administratif et Financier';
            }

            // try {
            //     sendMail(mailBody, mailingList, owa.id);
            // } catch (Exception e) {
            //     System.debug(e);
            // }
        }
    }

    // private void sendMail(String mailBody, List<String> mailingList, ID fromMail) {
    //     Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
                
    //     message.toAddresses = mailingList;
    //     message.optOutPolicy = 'FILTER';
    //     message.subject = 'Mise en demeure de paiement de la facture ';
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
    // }
}