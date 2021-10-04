global class BA01_UpdateAccountProfil implements Database.Batchable<sObject>, Database.Stateful {
    
    public String query;
    private List<Account> accountList;
    List<Account> accountToUpdate = new List<Account>();
    Date TODAY = Date.today();
    Id packRecordTypeId = Label.Contract_Pack_RecordTypeId;
    Id csRecordTypeId = Label.Contract_Synerciel_RecordTypeId;
    
    global Database.QueryLocator start(Database.BatchableContext bc){
        
        this.accountList = new List<Account>();
        
        this.query = 'SELECT Id, administrativeStatus__c,Profil__c, Type, (SELECT Id, EndDate__c, RecordTypeId FROM Conventions_annuelle__r WHERE RecordTypeId = :packRecordTypeId OR RecordTypeId = NULL OR RecordTypeId = :csRecordTypeId ORDER BY EndDate__c DESC) FROM Account';
        
        return Database.getQueryLocator(this.query);
    }
    
    global void execute(Database.BatchableContext BC, List<Account> scope){
        
        // FOR ALL ACCOUNTS RELATED TO AT LEAST ONE CONVENTION ANNUELLE
        for(Account acc : scope){
            if (!acc.Conventions_annuelle__r.isEmpty()){
					system.debug('I am here *****');                
                // PASS ACCOUNT TYPE AND PROFIL TO ADHERENT = IF CONVENTION IS VALID AND IT'S STATUS IS ACCEPTE/ACCEPTE SS SURVEILLANCE/EN ATT COMITE                
                if (acc.Conventions_annuelle__r[0].EndDate__c >= TODAY  && (acc.administrativeStatus__c == 'Accepté' || acc.administrativeStatus__c == 'Accepté sous surveillance' || acc.administrativeStatus__c == 'En attente comité risque')) {
                    if(acc.Type != 'Adhérent' || acc.Profil__c != 'Adhérent') accountToUpdate.add(new Account(id = acc.id, Type = 'Adhérent',Profil__c = 'Adhérent'));
                }
                // PASS ACCOUNT TYPE AND PROFIL TO ANCIEN ADHERENT = IF CONVENTION HAS EXPIRED IN LAST 3 YEARS AND IT'S STATUS IS ACCEPTE/ACCEPTE SS SURVEILLANCE/EN ATT COMITE  
                else if (acc.Conventions_annuelle__r[0].EndDate__c < TODAY && acc.Conventions_annuelle__r[0].EndDate__c >= TODAY.addYears(-3) && (acc.administrativeStatus__c == 'Accepté' || acc.administrativeStatus__c == 'Accepté sous surveillance' || acc.administrativeStatus__c == 'En attente comité risque')) {
                    if(acc.Type != 'Ancien adhérent' || acc.Profil__c != 'Ancien adhérent') accountToUpdate.add(new Account(id = acc.id, Type = 'Ancien adhérent',Profil__c = 'Ancien adhérent'));
                }
                // PASS ACCOUNT TYPE AND PROFIL TO ANCIEN ADHERENT AND ADMIN STATUS TO CLOS = IF CONVENTION HAS EXPIRED IN MORE 3 YEARS AND IT'S STATUS IS ACCEPTE/ACCEPTE SS SURVEILLANCE/EN ATT COMITE  
                else if (acc.Conventions_annuelle__r[0].EndDate__c < TODAY.addYears(-3) && acc.administrativeStatus__c == 'Accepté') {
                    if(acc.Type != 'Ancien adhérent' || acc.Profil__c != 'Ancien adhérent' || acc.administrativeStatus__c != 'Clos') accountToUpdate.add(new Account(id = acc.id, Type = 'Ancien adhérent',Profil__c = 'Ancien adhérent', administrativeStatus__c = 'Clos' ));
                }
            }
            // PASS ACCOUNT TYPE AND PROFIL TO ANCIEN ADHERENET = IF ACCOUNT HAS NO RELATED CONVENTION AND IT'S STATUS IS ACCEPTE/ACCEPTE SS SURVEILLANCE/EN ATT COMITE 
            else if (acc.Conventions_annuelle__r.isEmpty() && acc.administrativeStatus__c == 'Accepté' || acc.administrativeStatus__c == 'Accepté sous surveillance' || acc.administrativeStatus__c == 'En attente comité risque'){
                if(acc.Type != 'Ancien adhérent' || acc.Profil__c != 'Ancien adhérent') accountToUpdate.add(new Account(id = acc.id, Type = 'Ancien adhérent',Profil__c = 'Ancien adhérent'));
            }
        }
        
        

    }
    
    global void finish(Database.BatchableContext BC){
        // UPDATE THE ACCOUNTS
        Set<Account> accountToUpdateSet = new Set<Account>(accountToUpdate);
        List<Account> comptesToUpdate = new List<Account>(accountToUpdateSet);
        
        System.debug('comptesToUpdate :' + comptesToUpdate);
        if(comptesToUpdate.size() > 0) System.enqueueJob(new QueueClass(comptesToUpdate));
        
    }
    
    public class QueueClass implements Queueable {
        List<Account> comptesToUpdate;
        public QueueClass(List<Account> comptesToUpdate) {
            this.comptesToUpdate = comptesToUpdate;
        }
        public void execute(QueueableContext context) {
            
            try {
                System.debug('comptesToUpdate :' + comptesToUpdate);
                update comptesToUpdate;
            } catch (Exception e) {
                System.debug('Error update :' + e );
            }
        }
    }
}