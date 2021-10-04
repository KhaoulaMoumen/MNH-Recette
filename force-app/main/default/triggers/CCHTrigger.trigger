trigger CCHTrigger on Cercle_Confort_Habitat__c (before update, after update) {
    Map<Id, List<Cercle_Confort_Habitat__c>> mChgtOwnership = new Map<Id, List<Cercle_Confort_Habitat__c>>();
    Set<Id> setChgtOwnership = new Set<Id>();
    for(Cercle_Confort_Habitat__c aCCH : Trigger.New) {
        if(Trigger.isAfter) {
            if(Trigger.isUpdate) {
                //Le propritétaire de CCHA doit être celui de CCH
                if(aCCH.OwnerId != null && Trigger.oldMap.get(aCCH.Id).OwnerId != aCCH.OwnerId) {
                    setChgtOwnership.add(aCCH.Id);
                }
            }
        }
    }
    if(setChgtOwnership.size() > 0) {
        AP01_GestionCCH.changeOwnerFromCCH(setChgtOwnership);
    }
}