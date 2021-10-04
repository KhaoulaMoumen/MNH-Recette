public without sharing class CTRL08_listViewController {
     public class GroupWrapper{
        @AuraEnabled
        public String message;
        @AuraEnabled
        public List<CollaborationGroup> groupList;
        @AuraEnabled
        public Boolean success;
    }
    
    //Return account records and message to be displayed in toast
    @AuraEnabled
    public static GroupWrapper getGroups(String username){
        Network n = [select id from network where name like 'My Synerciel'];
        list<CollaborationGroupMember> CollabrationGroupMemberList = [select CollaborationGroupId from CollaborationGroupMember where Member.username =: username];
        set<Id> groupIds = new set<Id>();
        for(CollaborationGroupMember rec:CollabrationGroupMemberList){
	groupIds.add(rec.CollaborationGroupId);
}

        GroupWrapper groupWrapper = new GroupWrapper();
        try{
            groupWrapper.groupList = [SELECT Id, Name, MemberCount, SmallPhotoUrl, Owner.Name,  LastFeedModifiedDate FROM CollaborationGroup where id IN : groupIds and NetworkId =:n.id and IsArchived = false ];
            groupWrapper.message = 'Group records are retrieved ';
            groupWrapper.success = true;
        }
        catch(Exception e){
            groupWrapper.message = e.getMessage();
            groupWrapper.success = false;
        }
        system.debug(groupWrapper.groupList);
        return groupWrapper;
    }
    
}