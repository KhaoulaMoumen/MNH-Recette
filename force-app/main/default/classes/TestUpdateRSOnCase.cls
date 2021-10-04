/*
* Edited by Khaoula MOUMEN <khaoula.moumen@talan.com>, June 2020
*/
@isTest

private class TestUpdateRSOnCase{
    
    @isTest static void TestUpdateRS(){

        // CREATE USER WITH PROFIL SYSTEM ADMINISTRATOR 
        List<User> usersTest = DataFactory.createUsers(1, Label.Profile_Systeme_Administrateur_Name, false, false, false, true);

        // CREATE ACCOUNTS
        List<Account> accountsTest = DataFactory.createAccounts(3, 'Adhérent', 'Accepté', true);
        
        // CREATE CASES 
        List<Case> casesTest1 = DataFactory.createCases(1, accountsTest[0].Id, 'CEE', 'Email', 'Standard', true);
        
                     
        casesTest1[0].Status='Reçue';

        Test.startTest();
        
        update casesTest1[0];
        
        List<Case> casesTest2 = DataFactory.createCases(1, accountsTest[0].Id, 'PRIME', 'Courrier', 'VIR', true);
        
        Test.stopTest();

        Case caseUpdated = [SELECT Id, Status  FROM Case WHERE Id =:casesTest1[0].Id LIMIT 1];
        
        System.assertEquals(caseUpdated.Status, 'Reçue');
        System.assertNotEquals(casesTest2[0].Id, NULL);
    

        Account c = [Select Id, assistanteCommerciale__c, OwnerId, salespersonCode__c, groupRegion__c from Account where Id = :accountsTest[0].Id LIMIT 1];
        Account d = [Select Id, assistanteCommerciale__c, OwnerId, salespersonCode__c, groupRegion__c from Account where Id = :accountsTest[1].Id LIMIT 1];
        Account e = [Select Id, assistanteCommerciale__c, OwnerId, salespersonCode__c, groupRegion__c from Account where Id = :accountsTest[2].Id LIMIT 1];
        
        Case c1 = [Select Id, Nom_du_RS__c, Nom_du_RR__c from Case where Id = :casesTest1[0].Id LIMIT 1];
        Case c2 = [Select Id, Nom_du_RS__c, Nom_du_RR__c from Case where Id = :casesTest2[0].Id LIMIT 1];
        
        ObjectTerritory2AssignmentRuleItem otar1 = [Select Id, RuleId from ObjectTerritory2AssignmentRuleItem where Value = '13' LIMIT 1];
        ObjectTerritory2AssignmentRuleItem otar2 = [Select Id, RuleId from ObjectTerritory2AssignmentRuleItem where Value = '14' LIMIT 1];
        
        List<ObjectTerritory2AssignmentRuleItem> otarList = new List<ObjectTerritory2AssignmentRuleItem>();
        otarList.add(otar1);
        otarList.add(otar2);
        
        Map<Integer,User> rsList = new Map<Integer,User>();
        Map<Integer,User> rrList = new Map<Integer,User>();
        //List<Territory2> terrList = new List<Territory2>();
        List<Boolean> noRs = new List<Boolean>();
        List<Boolean> noRr = new List<Boolean>();
        
        Integer i = 0;
        
        for (ObjectTerritory2AssignmentRuleItem otar : otarList) {
        
            RuleTerritory2Association rta = [Select Id, Territory2Id from RuleTerritory2Association where RuleId = :otar.RuleId LIMIT 1];
            Territory2 terr = [Select Id, Name from Territory2 where Id = :rta.Territory2Id LIMIT 1];
            System.debug('terr*****'+terr);

            List<UserTerritory2Association> rsUta = [Select Id, UserId from UserTerritory2Association where Territory2Id = :terr.Id and RoleInTerritory2 = 'Responsable de Secteur'];
            if (rsUta.size() > 0) {
                User rs = [Select Id from User where Id = :rsUta[0].UserId LIMIT 1];
                rsList.put(i,rs);
                noRs.add(false);
            }
            else {
                noRs.add(true);
            }
            
            List<UserTerritory2Association> rrUta = [Select Id, UserId from UserTerritory2Association where Territory2Id = :terr.Id and RoleInTerritory2 = 'Responsable de région'];
            if (rrUta.size() > 0) {
                User rr = [Select Id, Email from User where Id = :rrUta[0].UserId LIMIT 1];
                rrList.put(i,rr);
                noRr.add(false);
            }
            else {
                noRr.add(true);
            }
            
            i++;
        }
        
        System.debug('rslist:' + rsList);
        System.debug('rrlist:' + rrList);

        system.debug('******c1.Nom_du_RS__c'+c1.Nom_du_RS__c);
        system.debug('******rsList.get(0).Id'+rsList.get(0).Id);

        system.debug('******c1.Nom_du_RR__c '+c1.Nom_du_RR__c );
        system.debug('******rrList.get(0).Id'+rrList.get(0).Id);
        
        //System.assert(noRs[0] || c1.Nom_du_RS__c == rsList.get(0).Id);
        //System.assert(noRr[0] || c1.Nom_du_RR__c == rrList.get(0).Id);
        
        //System.assert(noRs[1] || c2.Nom_du_RS__c == rsList.get(1).Id);
        //System.assert(noRr[1] || c2.Nom_du_RR__c == rrList.get(1).Id);
        
   }
   
}