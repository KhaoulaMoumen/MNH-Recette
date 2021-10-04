trigger TR07_CME on Club_Mobilite_Electrique__c (after insert,after update,after delete) {
    if(Trigger.isAfter) {
        if(Trigger.isInsert) {
            list<String> accs = new list<String>();
            list<Account> myAccs = new list<Account>();
            for(Club_Mobilite_Electrique__c cme : Trigger.new){
                accs.add(cme.Account__c);
            }
          
            myAccs=[SELECT Id,ClubPEE__c, ClubCME__c, Club_CCH__c, name,(SELECT Id FROM Clubs_Mobilite_Electrique__r where Date_entree_CME__c <= TODAY AND (Date_sortie_CME__c >= TODAY OR Date_sortie_CME__c = null)),
                    (select id from Offres_PSH__r where DateEntreePee__c <=TODAY AND (DateSortiePEE__c >= TODAY OR DateSortiePEE__c = null)),
                    (select id from Cercles_Confort_Habitat__r where Date_d_entree__c <=TODAY AND (Date_sortie_CCH__c >= TODAY OR Date_sortie_CCH__c = null)) FROM Account where id IN : accs];
            CTRL07_AccountAdhesionClubs.cocher_club_CME(myAccs);
            //Update_acc_club.updateAccCME(Trigger.New);
        }
        if(Trigger.isUpdate) {
            list<String> accs = new list<String>();
            list<Account> myAccs = new list<Account>();
            for (Club_Mobilite_Electrique__c myCME : Trigger.new) {
                Club_Mobilite_Electrique__c old = Trigger.oldMap.get(myCME.Id);
                if ((myCME.Date_entree_CME__c != old.Date_entree_CME__c)||(myCME.Date_sortie_CME__c != old.Date_sortie_CME__c)) {
                    //myCMEs.add(myCME);
                    accs.add(myCME.Account__c);
                }
            }
            myAccs=[SELECT Id,ClubCME__c,name,
                    (SELECT Id FROM Clubs_Mobilite_Electrique__r where Date_entree_CME__c <= TODAY AND (Date_sortie_CME__c >= TODAY OR Date_sortie_CME__c = null))
                     FROM Account where id IN : accs];
            CTRL07_AccountAdhesionClubs.cocher_club_CME(myAccs);
            //Update_acc_club.updateAccCME(myCMEs);
        }
        if(Trigger.isDelete) {
            list<String> accs = new list<String>();
            list<Account> myAccs = new list<Account>();
            for(Club_Mobilite_Electrique__c cme : Trigger.old){
                accs.add(cme.Account__c);
            }
          
            myAccs=[SELECT Id,ClubPEE__c, ClubCME__c, Club_CCH__c, name,(SELECT Id FROM Clubs_Mobilite_Electrique__r where Date_entree_CME__c <= TODAY AND (Date_sortie_CME__c >= TODAY OR Date_sortie_CME__c = null)),
                    (select id from Offres_PSH__r where DateEntreePee__c <=TODAY AND (DateSortiePEE__c >= TODAY OR DateSortiePEE__c = null)),
                    (select id from Cercles_Confort_Habitat__r where Date_d_entree__c <=TODAY AND (Date_sortie_CCH__c >= TODAY OR Date_sortie_CCH__c = null)) FROM Account where id IN : accs];
            CTRL07_AccountAdhesionClubs.cocher_club_CME(myAccs);
            //Update_acc_club.updateAccCME(Trigger.New);
        }
    }
    
}