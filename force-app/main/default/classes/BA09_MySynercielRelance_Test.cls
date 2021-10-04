/*
TEST CLASS

CreatedBy : MOUMEN Khaoula
@Email : khaoula.moumen@talan.com
CreateDate : 15/05/2020

EditedBy : MOUMEN Khaoula
@Email : khaoula.moumen@talan.com
Date : 05/06/2020

*/
@isTest(SeeAllData=true)
public class BA09_MySynercielRelance_Test {
    
    static testMethod void testBatch() {
        
        
        // CREATE USER WITH PROFIL SYSTEM ADMINISTRATOR
        List<User> usersTest = DataFactory.createUsers(1, Label.Profile_Systeme_Administrateur_Name, true, true, true, true);
        
        Profile p = [SELECT Id, Name FROM Profile WHERE Id =:Label.Profile_Adherent_Id LIMIT 1];
        
        // CREATE USER WITH PROFIL Adherent
        List<User> usersList = DataFactory.createUsers(100, p.Name, false, false, false, false);
        List<Id> userIds = new List<Id>();
        for(User u : usersList) userIds.add(u.Id);
        
        List<User> users = [SELECT Id, Tech_PortailRelance__c FROM User WHERE Id IN :userIds];
        for(User u : users) u.Tech_PortailRelance__c = true;
        update users;
        
        System.runAs(usersTest[0]){ 
            
            // --- Testing ---
            Test.startTest();
            
            BA09_MySynercielRelance ba = new BA09_MySynercielRelance();
            DataBase.executeBatch(ba, 50); 
            
            Test.stopTest();
        }
    }
}