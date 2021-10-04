trigger TR09_CCHA_Delete on Cercle_confort_habitat_adh_rent__c (before delete,after delete) {
    List<Cercle_confort_habitat_adh_rent__c> lCCHARemoveTeamMembers = new List<Cercle_confort_habitat_adh_rent__c>();
    
    if(Trigger.isAfter){
        //adhesion au club
                
            list<String> accs = new list<String>();
            list<Account> myAccs = new list<Account>();
            for(Cercle_confort_habitat_adh_rent__c cch : Trigger.old){
                
                system.debug(cch.Compte__c);
                    accs.add(cch.Compte__c);
            }
          
            myAccs=[SELECT Id,Club_CCH__c, name,
                    (select id from Cercles_Confort_Habitat__r where Date_d_entree__c <=TODAY AND (Date_sortie_CCH__c >= TODAY OR Date_sortie_CCH__c = null)) FROM Account where id IN : accs];
        system.debug(myAccs);    
        CTRL07_AccountAdhesionClubs.cocher_club_CCH(myAccs);
                //Update_acc_club.updateAccCCH(Trigger.New);
                //fin adhesion au club
    }
    if(Trigger.isbefore) {
        
        for(Cercle_confort_habitat_adh_rent__c aCCHA : Trigger.Old) {        
            if(aCCHA.Compte__c != null && aCCHA.OwnerId != null) {
                lCCHARemoveTeamMembers.add(aCCHA);
            }
        }
    }
    
    if(lCCHARemoveTeamMembers.size() > 0) {
        AP01_GestionCCH.removeTeamMembers(lCCHARemoveTeamMembers);
    }    
}