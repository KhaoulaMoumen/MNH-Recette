trigger TR08_CCHA on Cercle_confort_habitat_adh_rent__c (before insert, after insert, after update) {
    Map<Id, List<Cercle_confort_habitat_adh_rent__c>> mChgtOwnership = new Map<Id, List<Cercle_confort_habitat_adh_rent__c>>();
    List<Cercle_confort_habitat_adh_rent__c> lCCHAAddTeamMembers = new List<Cercle_confort_habitat_adh_rent__c>();
    list<String> accs = new list<String>();
    list<String> accsInsert= new list<String>();
    list<Account> myAccs = new list<Account>();
    List<Cercle_confort_habitat_adh_rent__c> lCCHARemoveTeamMembers = new List<Cercle_confort_habitat_adh_rent__c>();    
    
    for(Cercle_confort_habitat_adh_rent__c aCCHA : Trigger.New) {
        if(Trigger.isBefore) {
            if(Trigger.isInsert) {
                //Le propritétaire de CCHA doit être celui de CCH
                if(aCCHA.Cercle_Confort_Habitat__c != null) {
                    if(!mChgtOwnership.containsKey(aCCHA.Cercle_Confort_Habitat__c)) {
                        mChgtOwnership.put(aCCHA.Cercle_Confort_Habitat__c, new List<Cercle_confort_habitat_adh_rent__c>());
                        mChgtOwnership.get(aCCHA.Cercle_Confort_Habitat__c).add(aCCHA);
                    } else {
                        mChgtOwnership.get(aCCHA.Cercle_Confort_Habitat__c).add(aCCHA);
                    }
                }
            }
        } else if(Trigger.isAfter) {
            if(Trigger.isInsert) {
                //Si le propriétaire de CCH n'est pas celui du compte, on l'ajoute à l'équipe du compte
                if(aCCHA.Compte__c != null && aCCHA.OwnerId != null) {
                    lCCHAAddTeamMembers.add(aCCHA);
                }
                //adhesion au club
                accsInsert.add(aCCHA.Compte__c);

                //Update_acc_club.updateAccCCH(Trigger.New);
                //fin adhesion au club
            }
            if(Trigger.isUpdate) {
                if(aCCHA.Compte__c != null && aCCHA.OwnerId != null) {
                    lCCHAAddTeamMembers.add(aCCHA);
                    lCCHARemoveTeamMembers.add(Trigger.oldMap.get(aCCHA.Id)) ;
                }
            //adhesion au club    
                Cercle_confort_habitat_adh_rent__c old = Trigger.oldMap.get(aCCHA.Id);
                if ((aCCHA.Date_d_entree__c != old.Date_d_entree__c)||(aCCHA.Date_sortie_CCH__c != old.Date_sortie_CCH__c)) {
                    accs.add(aCCHA.Compte__c);
            }
                
            //Update_acc_club.updateAccCCH(myCCHs);
            //fin adhesion au club
                
            }
            
        }
    }
    
    if(mChgtOwnership.size() > 0) {
        AP01_GestionCCH.changeOwner(mChgtOwnership);
    }    
    if(lCCHAAddTeamMembers.size() > 0) {
        AP01_GestionCCH.addTeamMembers(lCCHAAddTeamMembers);
    }
    if(lCCHARemoveTeamMembers.size() > 0) {
        AP01_GestionCCH.removeTeamMembers(lCCHARemoveTeamMembers);
    }
    list <Account> myAccsInsert=[SELECT Id,Club_CCH__c, name,
                    (select id from Cercles_Confort_Habitat__r where Date_d_entree__c <=TODAY AND (Date_sortie_CCH__c >= TODAY OR Date_sortie_CCH__c = null)) FROM Account where id IN : accsInsert];
            CTRL07_AccountAdhesionClubs.cocher_club_CCH(myAccsInsert);   
    myAccs=[SELECT Id,Club_CCH__c, name,
                    (select id from Cercles_Confort_Habitat__r where Date_d_entree__c <=TODAY AND (Date_sortie_CCH__c >= TODAY OR Date_sortie_CCH__c = null)) FROM Account where id IN : accs];
            CTRL07_AccountAdhesionClubs.cocher_club_CCH(myAccs);
}