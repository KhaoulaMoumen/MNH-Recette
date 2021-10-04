global class Batch_Dataxess_UpdateAccounts implements Database.Batchable<sObject>, Database.AllowsCallouts  {

    global Database.QueryLocator start (Database.BatchableContext bc) {
        return Database.getQueryLocator('select id, SIRET__c, sirenSiret__c from Account WHERE sirenSiret__c != null and profil__c =\'Adhérent\' and Derniere_mise_jour_Altares__c < N_DAYS_AGO:7');
    }
    global void execute(Database.BatchableContext bc, List<Account> scope){

      Util_IntuizSDK intuiz = new Util_IntuizSDK();

      List<SObject> accountToUpsert = new List<SObject> ();

      List<SObject> actionaireToUpsert = new List<SObject>();
      List<SObject> actionaireToDelete = new List<SObject>();

      List<SObject> participationToUpsert = new List<SObject>();
      List<SObject> participationToDelete = new List<SObject>();

      List<SObject> dirigeantEtDecideurToUpsert = new List<SObject>();
      List<SObject> dirigeantEtDecideurToDelete = new List<SObject>();

      Map<String,List<sObject>> recordToUpsert = new Map<String,List<sObject>>();
    
      for( Account a : scope){

         
          recordToUpsert= intuiz.upsertRecord('Account',a.sirenSiret__c, a.id, true);
          List<sObject> controlListToUpdate = recordToUpsert.get('Account');
          
          if (controlListToUpdate != null && ((Account) controlListToUpdate[0]).SIRET__c != null){
              accountToUpsert.addAll(recordToUpsert.get('Account'));
              if (recordToUpsert.containsKey('Actionnaire__c')){ actionaireToUpsert.addAll(recordToUpsert.get('Actionnaire__c'));}
              if (recordToUpsert.containsKey('Del_Actionnaire__c')){ actionaireToDelete.addAll(recordToUpsert.get('Del_Actionnaire__c'));}
              if (recordToUpsert.containsKey('Participation__c')){ participationToUpsert.addAll(recordToUpsert.get('Participation__c'));}
              if (recordToUpsert.containsKey('Del_Participation__c')){ participationToDelete.addAll(recordToUpsert.get('Del_Participation__c'));}
              if (recordToUpsert.containsKey('Dirigeant_et_decideur__c')){ dirigeantEtDecideurToUpsert.addAll(recordToUpsert.get('Dirigeant_et_decideur__c'));}
              if (recordToUpsert.containsKey('Del_Dirigeant_et_decideur__c')){ dirigeantEtDecideurToDelete.addAll(recordToUpsert.get('Del_Dirigeant_et_decideur__c'));}

          }
      }

	  Database.update(accountToUpsert, false);

      delete actionaireToDelete;
      delete participationToDelete;
      delete dirigeantEtDecideurToDelete;

      upsert actionaireToUpsert;
      upsert participationToUpsert;
      upsert dirigeantEtDecideurToUpsert;

    }
    global void finish(Database.BatchableContext bc){
        
    }
}