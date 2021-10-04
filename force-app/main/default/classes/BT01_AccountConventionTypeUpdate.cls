/*
----------------------------------------------------------------------
-- - Nom          : BT01_AccountConventionTypeUpdate
-- - Auteur        : ASA
-- - Description   : Le batch permet de mettre à jour le champ Type de convention de l'objet Compte, s'il existe une ligne de convention annuelle 
sur l'année en cours avec une "Date fin contrat" >= date du jour
ET qu'il existe une offre PSH sur l'année en cours avec une "date de fin contrat" >= date du jour
-- Version:
--
-- Date         Nom                Version     Remarques
-- -----------  -----------         --------    ---------------------------------------
-- 12-12-2019   ASA                 1.0         Init
---------------------------------------------------------------------------------------
-- 03-02-2020   MOUMEN              2.0         Maintenance corrective du batch
---------------------------------------------------------------------------------------
*/

global class BT01_AccountConventionTypeUpdate implements Database.Batchable<sObject>
{
    
    global Database.QueryLocator start(Database.BatchableContext BC)
    {
        String query = 'SELECT Id, Type_de_Convention_new__c FROM Account';
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<Account> scope)
    {
        system.debug('scope '+scope.size());
        Set<id> accIds = new Set<id>();
        Set<id> offresinaccs = new Set <id>();
        Set<id> offresAchieved = new Set <id>();
        Set<id> Convinaccs = new Set <id>();        
        Set<id> accIdstoupdateSynPPE = new Set<id>();
        Set<id> accIdstoupdatePPE = new Set<id>();
        List <Account> acctsoupdate = new list <Account>();
        Map<Id, Account> mapAccounts = new Map<Id, Account>();
        
        date myDate = date.today();
        Integer currentYear = System.Today().year();
        list <Offre_PSH__c> offresPSHtoupdate = new list <Offre_PSH__c>();
        for ( Account acc : scope)
        {
            accIds.add(acc.id);
            mapAccounts.put(acc.id, acc);
        }   
        //Recherche des offre PSH sur l'année en cours avec une date de fin contrat >= date du jour
        list <Offre_PSH__c> offresPSH = [select id ,Annee__c, Date_de_fin_contrat__c , Compte__r.Type_de_Convention_new__c, Compte__r.id, Avancement_du_dossier__c
                                         from Offre_PSH__c
                                         where Compte__c in : accIds
                                         and  Date_de_fin_contrat__c >= :myDate
                                         and Annee__c = :String.valueof(currentYear)
                                         and Avancement_du_dossier__c =: 'Terminé'
                                        ];
        
        //Recherche des Conventions annuelles sur l'année en cours avec une Date fin contrat >= date du jour
        list <Convention_annuelle__c> convAnnuelles = [select id ,Ann_e__c, EndDate__c, Adherent__c, Adherent__r.id
                                                       from Convention_annuelle__c
                                                       where Adherent__c in : accIds
                                                       and EndDate__c >= :myDate 
                                                       and Ann_e__c = :currentYear];
        
        if(!convAnnuelles.isEmpty()) {
            for(Convention_annuelle__c convA : convAnnuelles) Convinaccs.add(convA.Adherent__r.id);
        }
        
        for (Offre_PSH__c offrePSH : offresPSH ){
            offresAchieved.add(offrePSH.Compte__r.id);
        }
        
        for (id  accId : accIds){
            Account acc = mapAccounts.get(accId);
            //Si pour un comptes, il existe une ligne de convention annuelle sur l'année en cours avec une "Date fin contrat" >= date du jour et au moins une Offre PSH et au moins une offre sur l'année en cours avec un Avancement du Dossier = "Terminé"
            if ( Convinaccs.contains(accId) && offresAchieved.contains(accId)){
                if(acc.Type_de_Convention_new__c != 'SYNERCIEL + PEE') acctsoupdate.add(new account(Id=accId, Type_de_Convention_new__c= 'SYNERCIEL + PEE'));
            }
            else
                // Si il n'a pas de ligne de convention annuelle sur l'année en cours avec une "Date fin contrat" >= date du jour ET qu'il existe une offre PSH sur l'année en cours avec une "date de fin contrat" >= date du jour et au moins une offre sur l'année en cours avec un Avancement du Dossier = "Terminé"
                if ( !(Convinaccs.contains(accId)) &&  offresAchieved.contains(accId)){
                    if(acc.Type_de_Convention_new__c != 'PEE') acctsoupdate.add(new account(Id=accId, Type_de_Convention_new__c= 'PEE'));
                }                
            else
                // Si il existe une ligne de convention annuelle sur l'année en cours avec une "Date fin contrat" >= date du jour ET qu'il n'y a aucune offre PSH sur l'année en cours avec une "date de fin contrat" >= date du jour et aucune offre sur l'année en cours avec un Avancement du Dossier = "Terminé"
                if ( (Convinaccs.contains(accId)) && !(offresAchieved.contains(accId))){
                    if(acc.Type_de_Convention_new__c != 'SYNERCIEL') acctsoupdate.add(new account(Id=accId, Type_de_Convention_new__c= 'SYNERCIEL'));
                }
            else
                // S'il n'y a pas de ligne de convention annuelle sur l'année en cours avec une "Date fin contrat" >= date du jour ET qu'il n'y a pas d'offre PSH sur l'année en cours avec une "date de fin contrat" >= date du jour et aucune offre sur l'année en cours avec un Avancement du Dossier = "Terminé"               
                if ( !(Convinaccs.contains(accId)) && !(offresAchieved.contains(accId))) {
                    if(acc.Type_de_Convention_new__c != '') acctsoupdate.add(new account(Id=accId, Type_de_Convention_new__c= ''));  
                }
        }
        // UPDATE ACCOUNTS
        update acctsoupdate;
    }  
    
    global void finish(Database.BatchableContext BC)
    {
    }
}