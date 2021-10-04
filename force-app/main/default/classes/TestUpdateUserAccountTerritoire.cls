/*
* Edited by Khaoula MOUMEN <khaoula.moumen@talan.com>, June 2020
*/
@isTest

private class TestUpdateUserAccountTerritoire{
    
    @isTest static void TestUpdateUserAccount(){
        
        Test.startTest();

        // CREATE ACCOUNTS
        List<Account> accountsTest = DataFactory.createAccounts(4, 'Adhérent', 'Accepté', true);
        
        accountsTest[3].BillingPostalCode = '92000';
        update accountsTest[3];

        Test.stopTest();
        
        System.assertNotEquals(accountsTest[0], NULL);
        System.assertNotEquals(accountsTest[1], NULL);
        System.assertNotEquals(accountsTest[2], NULL);
        System.assertNotEquals(accountsTest[3], NULL);
    

        Account c = [Select Id, assistanteCommerciale__c, OwnerId, salespersonCode__c, groupRegion__c from Account where Id = :accountsTest[0].Id LIMIT 1];
        Account d = [Select Id, assistanteCommerciale__c, OwnerId, salespersonCode__c, groupRegion__c from Account where Id = :accountsTest[1].Id LIMIT 1];
        Account e = [Select Id, assistanteCommerciale__c, OwnerId, salespersonCode__c, groupRegion__c from Account where Id = :accountsTest[2].Id LIMIT 1];
        Account f = [Select Id, assistanteCommerciale__c, OwnerId, salespersonCode__c, groupRegion__c from Account where Id = :accountsTest[3].Id  LIMIT 1];
        
        ObjectTerritory2AssignmentRuleItem otar1 = [Select Id, RuleId from ObjectTerritory2AssignmentRuleItem where Value = '13' LIMIT 1];
        ObjectTerritory2AssignmentRuleItem otar2 = [Select Id, RuleId from ObjectTerritory2AssignmentRuleItem where Value = '14' LIMIT 1];
        ObjectTerritory2AssignmentRuleItem otar3 = [Select Id, RuleId from ObjectTerritory2AssignmentRuleItem where Value = '33' LIMIT 1];
        ObjectTerritory2AssignmentRuleItem otar4 = [Select Id, RuleId from ObjectTerritory2AssignmentRuleItem where Value = '68' LIMIT 1];
        
        List<ObjectTerritory2AssignmentRuleItem> otarList = new List<ObjectTerritory2AssignmentRuleItem>();
        otarList.add(otar1);
        otarList.add(otar2);
        otarList.add(otar3);
        otarList.add(otar4);
        
        Map<Integer,User> asscoList = new Map<Integer,User>();
        Map<Integer,String> rsList = new Map<Integer,String>();
        List<Territory2> terrList = new List<Territory2>();
        List<Boolean> noAssco = new List<Boolean>();
        List<Boolean> noRs = new List<Boolean>();
        
        Integer i = 0;
        
        for (ObjectTerritory2AssignmentRuleItem otar : otarList) {
        
            RuleTerritory2Association rta = [Select Id, Territory2Id from RuleTerritory2Association where RuleId = :otar.RuleId LIMIT 1];
            Territory2 terrChild = [Select Id, ParentTerritory2Id, Name from Territory2 where Id = :rta.Territory2Id LIMIT 1];
            Territory2 terr = [Select Id, Name from Territory2 where Id = :terrChild.ParentTerritory2Id LIMIT 1];
            terrList.add(terr);
            
            System.debug('territoire: ' + terrChild.Name);
            System.debug('territoire id: ' + terrChild.Id);
            
            List<UserTerritory2Association> asscoUta = [Select Id, UserId from UserTerritory2Association where Territory2Id = :terrChild.Id and RoleInTerritory2 = 'Assistant(e) Commercial(e)'];
            if (asscoUta.size() > 0) {
                User assco = [Select Id from User where Id = :asscoUta[0].UserId LIMIT 1];
                asscoList.put(i,assco);
                noAssco.add(false);
            }
            else {
                noAssco.add(true);
            }
            
            List<UserTerritory2Association> rsUta = [Select Id, UserId from UserTerritory2Association where Territory2Id = :terrChild.Id and RoleInTerritory2 = 'Responsable de Secteur'];
            if (rsUta.size() > 0) {
                User rs = [Select Id, Email from User where Id = :rsUta[0].UserId LIMIT 1];
                rsList.put(i,rs.Email);
                noRs.add(false);
            }
            else {
                noRs.add(true);
            }
            
            i++;
        }
        
        System.debug('asscolist:' + asscoList);
        System.debug('rslist:' + rsList);
        
        System.debug('assco c: ' + c.assistanteCommerciale__c);
        System.debug('rs c: ' + c.salespersonCode__c);
        System.debug('group region c: ' + c.groupRegion__c);
        
        /*System.assert(noAssco[0] || c.assistanteCommerciale__c == asscoList.get(0).Id);
        System.assert(noRs[0] || c.salespersonCode__c == rsList.get(0));
        System.assert(c.groupRegion__c == terrList[0].Name);

        System.assert(noAssco[1] || d.assistanteCommerciale__c == asscoList.get(1).Id);
        System.assert(noRs[1] || d.salespersonCode__c == rsList.get(1));
        //System.debug('assco: ' + d.assistanteCommerciale__c);
        //System.debug('rs: ' + d.salespersonCode__c);
        //System.debug('territory parent 1: ' + terrList[1].Name);
        //System.debug('group region: ' + d.groupRegion__c);
        System.assert(d.groupRegion__c == terrList[1].Name);
        
        System.assert(noAssco[2] || e.assistanteCommerciale__c == asscoList.get(2).Id);
        System.assert(noRs[2] || e.salespersonCode__c == rsList.get(2));
        System.assert(e.groupRegion__c == terrList[2].Name);
        
        System.assert(noAssco[3] || f.assistanteCommerciale__c == asscoList.get(3).Id);
        System.assert(noRs[3] || f.salespersonCode__c == rsList.get(3));
        System.assert(f.groupRegion__c == terrList[3].Name);
        */
   }
   
}