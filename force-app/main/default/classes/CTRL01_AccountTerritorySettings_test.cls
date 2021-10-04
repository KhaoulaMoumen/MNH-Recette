@isTest
public class CTRL01_AccountTerritorySettings_test {
        @testSetup 
    static void setup() {
        list<Account> accs = Datafactory.createAccounts(1, 'Adhérent', 'Accepté', true);
        /*List<Territory2Model> terssModel =  Datafactory.createTerritoryModels(1, true);
        list<Territory2> terrs = Datafactory.createTerritories(1, Id terrModelID, Id terrTypeID, Boolean doInsert)*/
        
    }
    static testmethod void test() {
        Set<ID> accIds= new Set<ID>();
        Id accId = [select id from account where recordtype.name = 'Adhérent' limit 1].id;
        accIds.add(accId);
        test.startTest();
        CTRL01_AccountTerritorySettings.manageAccTerritories(accIds);
        test.stopTest();
    }

}