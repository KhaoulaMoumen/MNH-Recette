trigger CCHATrigger on Cercle_confort_habitat_adh_rent__c (before insert, after insert, after update) {
    Map<Id, List<Cercle_confort_habitat_adh_rent__c>> mChgtOwnership = new Map<Id, List<Cercle_confort_habitat_adh_rent__c>>();
    List<Cercle_confort_habitat_adh_rent__c> lCCHAAddTeamMembers = new List<Cercle_confort_habitat_adh_rent__c>();
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
            }
            if(Trigger.isUpdate) {
                if(aCCHA.Compte__c != null && aCCHA.OwnerId != null) {
                    lCCHAAddTeamMembers.add(aCCHA);
                    lCCHARemoveTeamMembers.add(Trigger.oldMap.get(aCCHA.Id)) ;
                }                
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
}