public with sharing class Util_Dataxess_Mails {

    public static List<String> getMailAddresses(string apiNameGroupe){
        List<String> idList = new List<String>();
        List<String> mailToAddresses = new List<String>(); 
         
        Group gp = [SELECT (SELECT UserOrGroupId FROM GroupMembers) FROM Group WHERE DeveloperName = :apiNameGroupe];
        for (GroupMember gm : gp.GroupMembers) {
            idList.add(gm.UserOrGroupId);
        }
        List<User> userList = [SELECT Email FROM User WHERE Id IN :idList];
        for(User u : userList) {
            mailToAddresses.add(u.email);
        } 
        return mailToAddresses;
    }

}