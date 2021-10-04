trigger CCHATriggerBeforeDelete on Cercle_confort_habitat_adh_rent__c (before delete) {
    List<Cercle_confort_habitat_adh_rent__c> lCCHARemoveTeamMembers = new List<Cercle_confort_habitat_adh_rent__c>();
    if(Trigger.isDelete) {
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