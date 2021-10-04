/*
----------------------------------------------------------------------
-- - Name          : BatchUpdateCompteQualite
-- - Author        : RDB
-- - Description   : Batch qui met à jour les champs Qualité Assurances, Qualité qualifications et 
--                      et Qualité situation financière sur le compte
--
-- Maintenance History:
--
-- Date         Name                Version     Remarks 
-- -----------  -----------         --------    ---------------------------------------
-- 17-12-2019   RDB                 1.0         Init
---------------------------------------------------------------------------------------
*/
global class BatchUpdateCompteQualite implements Database.Batchable<sObject> {
	
	
	global Database.QueryLocator start(Database.BatchableContext BC) {
        System.debug('[BatchUpdateCompteQualite][start] start');

		return Database.getQueryLocator([SELECT Id, Qualite_assurances__c, Qualite_qualifications__c, Qualite_situation_financiere__c, Situation_financiere__c,
                                                    (SELECT Compte__c, Date_de_fin__c, Statut__c FROM Account.Assurance__r), 
                                                    (SELECT Compte__c, Date_de_fin__c FROM Account.Qualifications_prospect_adh_rent__r)
                                        FROM Account]);
	}

   	global void execute(Database.BatchableContext BC, List<Account> listComptes) {
		System.debug('[BatchUpdateCompteQualite][execute] Lancement du traitement');

        //Set<Account> listComptesDistincts = new Set<Account>();
        Map<Id, Account> mapComptesDistincts = new Map<Id, Account>();
        for (Account compte : listComptes) {
            
            // 1 //
            // on s'occupe du champ Qualité assurances
            String statutActuel = compte.Qualite_assurances__c;
            compte.Qualite_assurances__c = 'PAS OK';
            for (Assurances__c assur : compte.Assurance__r) {
                        
        system.debug('assurance*********'+assur.Statut__c);

                // ASSURANCE VALID AND STATUS AUTORISEE/TOLEREE
                if(assur.Date_de_fin__c > System.now() && (assur.Statut__c.equals('Autorisée') || assur.Statut__c.equals('Tolérée'))) {
                    compte.Qualite_assurances__c = 'OK';
                }
            }
            
            // ACCOUNTS WITH QUALITE ASSURANCE OK
            if(!statutActuel.equals(compte.Qualite_assurances__c)) {
                System.debug('#');
                mapComptesDistincts.put(compte.Id,compte);
                //listComptesDistincts.add(compte);
            }

            // 2 //
            // on s'occupe du champ Qualité qualifications
            statutActuel = compte.Qualite_qualifications__c;
            compte.Qualite_qualifications__c = 'PAS OK';
            for (Qualification_prospect_adherent__c qualif : compte.Qualifications_prospect_adh_rent__r) {
                // VALID QUALIFICATIONS
                if(qualif.Date_de_fin__c > System.now()) {
                    compte.Qualite_qualifications__c = 'OK';
                }
            }
            if(!statutActuel.equals(compte.Qualite_qualifications__c)) {
                System.debug('##');
                mapComptesDistincts.put(compte.Id,compte);
                //listComptesDistincts.add(compte);
            }

            // 3 //
            // on s'occupe du champ Qualité situation financière
            statutActuel = compte.Qualite_situation_financiere__c;
            compte.Qualite_situation_financiere__c = 'PAS OK';
            // SITUATION FINANCIERE DU COMPTE EN REGLE ON PASSE LA QUALITE A OK
            if(compte.Situation_financiere__c == 'En règle'){
                compte.Qualite_situation_financiere__c = 'OK';
            }
            if(!statutActuel.equals(compte.Qualite_situation_financiere__c)) {
                System.debug('###');
                mapComptesDistincts.put(compte.Id,compte);
                //listComptesDistincts.add(compte);
            }
        }

        System.debug('[BatchUpdateCompteQualite][execute] Nb de comptes à MAJ : ' + mapComptesDistincts.size());
        System.debug('[BatchUpdateCompteQualite][execute] Comptes à MAJ : ' + mapComptesDistincts);
        
        // UPDATE DISTINCT ACCOUNTS 
        Database.update(mapComptesDistincts.values(), false);

        System.debug('[BatchUpdateCompteQualite][execute] Fin du traitement');
	}
	
	global void finish(Database.BatchableContext BC) {
        System.debug('[BatchUpdateCompteQualite][finish] finish');
	}

}