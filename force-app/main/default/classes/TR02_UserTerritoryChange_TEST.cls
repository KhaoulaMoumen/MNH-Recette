/*
* Edited by Khaoula MOUMEN <khaoula.moumen@talan.com>, June 2020
 */
@isTest
public class TR02_UserTerritoryChange_TEST {
    
	 private static final Id adherentRT = [SELECT Id, DeveloperName FROM RecordType WHERE sObjectType='Account' AND DeveloperName='Adherent' LIMIT 1].Id;

    private static testMethod void territorryAssignmentToAccountsByTrigger() {

        Test.startTest();
    // CREATE USER WITH PROFIL SYSTEM ADMINISTRATOR 
    List<User> usersTest = DataFactory.createUsers(2, Label.Profile_Systeme_Administrateur_Name, false, false, false, true);
    
    // CREATE LIST OF USER IDs TO PASS IN PARAM 
    List<Id> userIds = new List<Id>();
    userIds.add(usersTest[0].Id);
    userIds.add(usersTest[1].Id);
    
    // CREATE ACCOUNTS 
    List<Account> accountsTest = DataFactory.createAccounts(1, 'Adhérent', 'Accepté', true);
        System.RunAs(usersTest[0])
        {
            insertTestTerritory(accountsTest[0].Id, userIds);
        }
        Test.stopTest();
    }

    //@future
    private static void insertTestTerritory(Id AccId, List<Id> users)
    {

        
        // GET TERRITORY TYPE
        List<Territory2Type> terriType   = [SELECT id, DeveloperName from Territory2Type where  DeveloperName = 'Departement' LIMIT 1];

        // CREATE TERRITORY MODEL
        List<Territory2Model> terrModelsTest = DataFactory.createTerritoryModels(1, true);

        // CREATE TERRITORY
        List<Territory2> territoryTest = DataFactory.createTerritories(1, terrModelsTest[0].Id, terriType[0].Id, true);
        
        // CREATE USER TERRITORY ASSOCIATIONS
        List<UserTerritory2Association> objUserTerritory2Association1 = DataFactory.createTerritoryAssociations(1, territoryTest[0].Id, users[0], 'Responsable de Secteur', true);
        List<UserTerritory2Association> objUserTerritory2Association2 = DataFactory.createTerritoryAssociations(1, territoryTest[0].Id, users[1], 'Responsable de région', true);

    }
}