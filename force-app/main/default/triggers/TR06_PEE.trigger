trigger TR06_PEE on Offre_PSH__c (after insert, after update,after delete) {
    if(Trigger.isAfter) {
        if(Trigger.isInsert) {
            list<String> accs = new list<String>();
            list<Account> myAccs = new list<Account>();
            for(Offre_PSH__c pee : Trigger.new){
                accs.add(pee.Compte__c);
            }
          
            myAccs=[SELECT Id,ClubPEE__c, name,
                    (select id from Offres_PSH__r where Date_de_signature_Recrutement_Synerciel__c <=TODAY AND (Date_de_fin_contrat__c >= TODAY OR Date_de_fin_contrat__c = null))
                    FROM Account where id IN : accs];
            CTRL07_AccountAdhesionClubs.cocher_club_PEE(myAccs);
            //Update_acc_club.updateAccPEE(Trigger.New);
        }
        if(Trigger.isUpdate) {
            list<String> accs = new list<String>();
            list<Account> myAccs = new list<Account>();
            //list<Offre_PSH__c> myPEEs = new list<Offre_PSH__c>();
            for (Offre_PSH__c myPEE : Trigger.new) {
                Offre_PSH__c old = Trigger.oldMap.get(myPEE.Id);
                if ((myPEE.Date_de_signature_Recrutement_Synerciel__c != old.Date_de_signature_Recrutement_Synerciel__c)||(myPEE.Date_de_fin_contrat__c != old.Date_de_fin_contrat__c)) {
                    //myPEEs.add(myPEE);
                    accs.add(myPEE.Compte__c);
                }
            }
            myAccs=[SELECT Id,ClubPEE__c,  name, 
                    (select id from Offres_PSH__r where Date_de_signature_Recrutement_Synerciel__c <=TODAY AND (Date_de_fin_contrat__c >= TODAY OR Date_de_fin_contrat__c = null))
                    FROM Account where id IN : accs];
            CTRL07_AccountAdhesionClubs.cocher_club_PEE(myAccs);
            //Update_acc_club.updateAccPEE(myPEEs);
        }
        if(Trigger.isDelete) {
            list<String> accs = new list<String>();
            list<Account> myAccs = new list<Account>();
            for(Offre_PSH__c pee : Trigger.old){
                accs.add(pee.Compte__c);
            }
          
            myAccs=[SELECT Id,ClubPEE__c, name,
                    (select id from Offres_PSH__r where Date_de_signature_Recrutement_Synerciel__c <=TODAY AND (Date_de_fin_contrat__c >= TODAY OR Date_de_fin_contrat__c = null))
                    FROM Account where id IN : accs];
            CTRL07_AccountAdhesionClubs.cocher_club_PEE(myAccs);
            //Update_acc_club.updateAccPEE(Trigger.New);
        }
    }


}