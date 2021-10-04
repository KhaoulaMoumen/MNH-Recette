@isTest(seeAllData=false)

private class cchaCheckTriggerTest {
    
 @isTest   Static void MethodeInsert (){
                   
         List<User> usersTest = DataFactory.createUsers(2, Label.Profile_Systeme_Administrateur_Name, false, false, false, true);
        List<Cercle_Confort_Habitat__c> cchTest1 = DataFactory.createCCHs(1, usersTest[0].Id, 'CCH-PARIS', true);
         List<Account> accountsTest = DataFactory.createAccounts(3, 'Adhérent', 'Accepté', true);
     //List<Account> accountsTest1 = DataFactory.createAccounts(2, 'Adhérent', 'Accepté', true);
             Test.startTest();
         List<Cercle_confort_habitat_adh_rent__c> cchATest1 = DataFactory.createCCHAdhrents(1, accountsTest[0].Id, cchTest1[0].Id, usersTest[0].Id, true);
            Test.stopTest();
        Account acct = [Select id ,Club_CCH__c FROM Account where id = :accountsTest[0].id ];
       // Account acct2 = [Select id ,Club_CCH__c FROM Account where id = :accountsTest1[0].id ];
            
        System.assertEquals(True,acct.Club_CCH__c);   
    //  System.assertEquals(False,acct2.Club_CCH__c);  
    }
   @isTest   Static void MethodeDelete (){
                   
         List<User> usersTest = DataFactory.createUsers(2, Label.Profile_Systeme_Administrateur_Name, false, false, false, true);
        List<Cercle_Confort_Habitat__c> cchTest1 = DataFactory.createCCHs(1, usersTest[0].Id, 'CCH-PARIS', true);
         List<Account> accountsTest = DataFactory.createAccounts(3, 'Adhérent', 'Accepté', true);
     
             Test.startTest();
         List<Cercle_confort_habitat_adh_rent__c> cchATest1 = DataFactory.createCCHAdhrents(1, accountsTest[0].Id, cchTest1[0].Id, usersTest[0].Id, true);
            Test.stopTest();
       delete cchATest1;
       
        Account acct = [Select id ,Club_CCH__c FROM Account where id = :accountsTest[0].id ];
       
        System.assertEquals(False,acct.Club_CCH__c);   
      
    } 
}