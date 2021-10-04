/*
------------------------------------------------------------------------------------
-- - Name          : BA04_EventEmailRappelRDV
-- - Author        : Khaoula MOUMEN
-- - Description   : BATCH Event - Envoi des emails de rappel RDV aux prospects/clients
--    
-- Maintenance History:
--
-- Date         Name                Version     Remarks 
-- -----------  -----------         --------    ---------------------------------------
-- 28-09-2021   K.M                 1.0         Init
---------------------------------------------------------------------------------------
*/
global class BA04_EventEmailRappelRDV implements Database.Batchable<sObject> {

    Date dateTomorrow = (Date.today()).addDays(1);

    String clientRT_Id = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Adhérent').getRecordTypeId(); 
    String prospectRT_Id = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Prospect').getRecordTypeId();     
	Set<Id> accountIds = new Set<Id>();
    List<ContactPointTypeConsent> consentPoints = new List<ContactPointTypeConsent>();
    Map<Id, List<ContactPointTypeConsent>> mapConsentsByAccount = new Map<Id, List<ContactPointTypeConsent>>();
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        system.debug('[BA04_EventEmailRappelRDV] Started'); 
        // Get all events/RDV due tomorrow related to prospects or clients
        String query = 'SELECT Id,Type, Subject, StartDateTime, Location, WhatId FROM Event WHERE (What.RecordTypeId = :prospectRT_Id OR What.RecordTypeId = :clientRT_Id) AND ActivityDate =:dateTomorrow';
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<Event> scope) { 
        
        for(Event rdv : scope) {
        	accountIds.add(rdv.WhatId);
        }
        
       List<ContactPointTypeConsent> consentments = [SELECT Id, Type_de_contact__c FROM ContactPointTypeConsent WHERE Compte__c IN :accountIds];
       
    }   
    
    global void finish(Database.BatchableContext BC) {
        system.debug('[BA04_EventEmailRappelRDV] Finished'); 
    }
    
}