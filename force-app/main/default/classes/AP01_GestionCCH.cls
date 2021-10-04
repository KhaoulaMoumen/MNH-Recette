public without sharing class AP01_GestionCCH {
    // UPDATE CCHA OWNERS 
    public static void changeOwner(Map<Id, List<Cercle_confort_habitat_adh_rent__c>> mCCHA) {
        Map<Id, Id> mCCHOwners = new Map<Id, Id>();
        List<Cercle_Confort_Habitat__c> l = [SELECT Id, OwnerId FROM Cercle_Confort_Habitat__c WHERE ID in :mCCHA.KeySet()];
        for(Cercle_Confort_Habitat__c aCCH : l) {
            //IF CCH IS NOT IN THE MAP
            if(!mCCHOwners.containsKey(aCCH.Id)) {
                mCCHOwners.put(aCCH.Id, aCCH.OwnerId);
            }
        }
		System.debug('### AP01 ChangeOwner ### List of CCHA to update '+l);
        for(Id mCCHId : mCCHA.keySet()) {
            for(Cercle_confort_habitat_adh_rent__c aCCHA : mCCHA.get(mCCHId)) {
                System.debug('### AP01 ChangeOwner ### current Owner is ' + aCCHA.OwnerId + ' of CCHA ' + aCCHA);
                System.debug('### AP01 ChangeOwner ### new Owner is ' + mCCHOwners.get(mCCHId) + ' of CCHA ' + aCCHA);
                aCCHA.OwnerId = mCCHOwners.get(mCCHId);
            }
        }
    }

    // UPDATE CCH OWNERS
    public static void changeOwnerFromCCH(Set<Id> sCCH) {
        Map<Id, List<Cercle_confort_habitat_adh_rent__c>> mChgtOwnership = new Map<Id, List<Cercle_confort_habitat_adh_rent__c>>();        
        List<Cercle_confort_habitat_adh_rent__c> lCCHA  = [SELECT Id, OwnerId, Cercle_Confort_Habitat__r.OwnerId FROM Cercle_confort_habitat_adh_rent__c WHERE Cercle_Confort_Habitat__c in :sCCH];
        for(Cercle_confort_habitat_adh_rent__c aCCHA : lCCHA) {
            if(aCCHA.Cercle_Confort_Habitat__c != null && aCCHA.Cercle_Confort_Habitat__r.OwnerId != null) {
                aCCHA.OwnerId = aCCHA.Cercle_Confort_Habitat__r.OwnerId;
            }            
        }
        update lCCHA;
    }
    
    // ADD TEAM MEMBERS TO CCHA 
    public static void addTeamMembers(List<Cercle_confort_habitat_adh_rent__c> lCCHA) {
        List<AccountTeamMember> accountTeamMembersList =  new List<AccountTeamMember>();
        List<Id> lCCHA_Ids = new List<Id>();
        
        // CREATE TEAM MEMBERS TO CCHA WITH ROLE 'Propriétaire CCHA' AND EDIT ACCESS
        for(Cercle_confort_habitat_adh_rent__c aCCHA : lCCHA) {
            accountTeamMembersList.add(
                new AccountTeamMember(
                    AccountId=aCCHA.Compte__c,
                    UserId = aCCHA.OwnerId,
                    TeamMemberRole = 'Propriétaire CCHA',
                    AccountAccessLevel = 'Edit'));
            lCCHA_Ids.add(aCCHA.Id);
        }
        insert accountTeamMembersList;
        
        List<Cercle_confort_habitat_adh_rent__c> lCCHA_Owners = [SELECT Id, Compte__r.OwnerId,OwnerId FROM Cercle_confort_habitat_adh_rent__c where Id in:lCCHA_Ids];
        List<Cercle_confort_habitat_adh_rent__Share> lCCHAShare = new List<Cercle_confort_habitat_adh_rent__Share>();
        
        // CREATE RECORD SHARINGS
        for(Cercle_confort_habitat_adh_rent__c aCCHA : lCCHA_Owners) {
            if(aCCHA.Compte__r.OwnerId != aCCHA.OwnerId) {            
                Cercle_confort_habitat_adh_rent__Share aCCHA_Share = new Cercle_confort_habitat_adh_rent__Share();
                System.debug(aCCHA.Id);
                aCCHA_Share.ParentId = aCCHA.Id;
                System.debug(aCCHA.Compte__r.OwnerId);            
                aCCHA_Share.UserOrGroupId = aCCHA.Compte__r.OwnerId;
                aCCHA_Share.AccessLevel = 'Edit';
                aCCHA_Share.RowCause = 'Manual';
                lCCHAShare.add(aCCHA_Share);
            }
        }
        insert lCCHAShare;
    }
    
    // REMOVE CCHA TEAM MEMBERS
    public static void removeTeamMembers(List<Cercle_confort_habitat_adh_rent__c> lCCHA) {
        Set<String> lUniqueTeamMembers = new Set<String>();
        List<AccountTeamMember> lAccTeamMembersToDelete = new List<AccountTeamMember>();
        Set<String> setOwners = new Set<String>();
        Set<String> setComptes = new Set<String>();
        for(Cercle_confort_habitat_adh_rent__c aCCHA : lCCHA) {
            lUniqueTeamMembers.add(aCCHA.OwnerId+''+aCCHA.Compte__c);
            setOwners.add(aCCHA.OwnerId);
            setComptes.add(aCCHA.Compte__c);
        }
        List<AccountTeamMember> lAccTeamMembers = [SELECT ID,UserId,AccountId FROM AccountTeamMember WHERE UserId in :setOwners and AccountId in :setComptes and TeamMemberRole = 'Propriétaire CCHA'];
        for(AccountTeamMember anAccTM : lAccTeamMembers) {
            if(lUniqueTeamMembers.contains(anAccTM.UserId+''+anAccTM.AccountId)) {
                lAccTeamMembersToDelete.add(anAccTM);
            }
        }
        if(lAccTeamMembersToDelete.size() > 0) {
            delete lAccTeamMembersToDelete;
        }
    }
}