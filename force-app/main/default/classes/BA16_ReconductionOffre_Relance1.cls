/*----------------------------------------------------------------------
-- - Name          : BA16_ReconductionOffre_Relance1
-- - Author        : KM
-- - Description   : à J-2 mois, on envoie un mail pour avis d'échéance et le client a 1 mois pour se retirer // s'il se retire, il nous en informe, nos users cochent la case 'Reconduction non souhaitee'
--   
-- Maintenance History:
--
-- Date         Name                Version     Remarks 
-- -----------  -----------         --------    ---------------------------------------
-- 08-03-2021   KM                  1.0         Init
---------------------------------------------------------------------------------------
*/
global  class BA16_ReconductionOffre_Relance1 implements Database.Batchable<sObject>, Database.Stateful {
    public String query;
    private List<Account> accountList;
    List<Account> accountToUpdate = new List<Account>();
    Map<Id,User> mapClients = new Map<Id,User>();
    
    Date TODAY = Date.today();
    String offreRecordTypeId = Label.LABS_SF_Contract_OffreId;
    String profileClient = System.Label.ESP_Client_Profil_ID;
    
    EmailTemplate templateRelanceClient = [SELECT id FROM EmailTemplate WHERE name = :'CEP Relance Reconduction OPTIM\'ACHAT' LIMIT 1];
    OrgWideEmailAddress owea = [SELECT Id FROM OrgWideEmailAddress WHERE Address = 'administratif@synerciel.fr' LIMIT 1];
    List<User> clients = [SELECT Id,Name, Email, AccountId, ContactId FROM User WHERE isActive = TRUE AND ProfileId =: profileClient];
    String accClient = 'Client';
    
    global Database.QueryLocator start(Database.BatchableContext bc){
        
        this.accountList = new List<Account>();
        
        this.query = 'SELECT Id,Profil__c, Type,email__c, (SELECT Id, Date_de_reconduction__c, Statut__c, RecordTypeId, Date_de_relance__c FROM Conventions_annuelle__r WHERE RecordTypeId = :offreRecordTypeId ORDER BY EndDate__c DESC) FROM Account WHERE Profil__c = :accClient';
        
        return Database.getQueryLocator(this.query);
    }
    
    global void execute(Database.BatchableContext BC, List<Account> scope){
        for(User c : clients) mapClients.put(c.AccountId, c);
        
        for(Account acc : scope){
            if (!acc.Conventions_annuelle__r.isEmpty()){
                if (acc.Conventions_annuelle__r[0].Statut__c == 'Actif' && acc.Conventions_annuelle__r[0].Date_de_reconduction__c == TODAY.addMonths(2) && acc.Conventions_annuelle__r[0].Date_de_relance__c == TODAY) {                    
                    User client = mapClients.get(acc.Id);
                    
                    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                    mail.setTargetObjectId(client.ContactId);
                    mail.setWhatId(acc.Conventions_annuelle__r[0].Id);
                    mail.setTemplateId(templateRelanceClient.Id);
                    mail.setOrgWideEmailAddressId(owea.Id);
                    mail.saveAsActivity = false;
                     Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
                }
            }
        }
    }
    
    global void finish(Database.BatchableContext BC){
        
    }
}