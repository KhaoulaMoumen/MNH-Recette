/*----------------------------------------------------------------------
-- - Name          : CTRL06_UserProfile
-- - Author        : KM
-- - Description   : Controller des composants LWC lwc09_CarteAdherent et LNC04_COntactUs
--   
-- Maintenance History:
--
-- Date         Name                Version     Remarks 
-- -----------  -----------         --------    ---------------------------------------
-- XX-07-2020   KM                  1.0         Init
-- 03-08-2020   RDB                 1.1         corrections/modifications
---------------------------------------------------------------------------------------
*/
public without sharing class CTRL06_UserProfile {
    
    @AuraEnabled
    public static void sendEmailverification(Id accountId, Id contactId, String emailAddress){  
        System.debug('[CTRL06_UserProfile][sendEmailverification] start');
		
        
        Id templateId = System.Label.LABS_SF_EMAIL_TEMPLATE_ID_VERIF_ADHERENT;
        Id senderId = System.Label.LABS_SF_COMMUNITY_SENDER_ID;
        
        Messaging.SingleEmailMessage mailTemplate = Messaging.renderStoredEmailTemplate(templateId, contactId, accountId);
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setSubject(mailTemplate.getSubject());
        mail.setHtmlBody(mailTemplate.getHtmlBody());
        mail.setOrgWideEmailAddressId(senderId);
        mail.setToAddresses(new String[] { emailAddress});

        List<Messaging.SingleEmailMessage> messages = new List<Messaging.SingleEmailMessage> {mail};
        Messaging.SendEmailResult[] results = System.Messaging.sendEmail(messages);
        
        if (results[0].success) 
        {
            System.debug('The email was sent successfully.');
        } else {
            System.debug('The email failed to send: ' +  results[0].errors[0].message);
        }
    }
    
    @AuraEnabled
    public static String getAccountInfos(){
        System.debug('[CTRL06_UserProfile][getAccountInfos] start');
        
        User currentUser = [SELECT AccountId, Account.assistanteCommerciale__c, Account.Responsable_secteur__c, Account.Responsable_partenariat__c,Account.OwnerId FROM User WHERE Id= :UserInfo.getUserId() LIMIT 1];
        /*
        User respSect = null;
        User assistComm = null;
        User respPart = null;
        
        if(currentUser.Account.Responsable_secteur__c != null) {
            respSect = [SELECT Id, FirstName, LastName, Email, MobilePhone FROM User WHERE Id = :currentUser.Account.Responsable_secteur__c LIMIT 1];
        }
        if(currentUser.Account.assistanteCommerciale__c != null) {
            assistComm = [SELECT Id, FirstName, LastName, Email, MobilePhone FROM User WHERE Id = :currentUser.Account.assistanteCommerciale__c LIMIT 1];
        }
        if(currentUser.Account.Responsable_partenariat__c != null) {
            respPart = [SELECT Id, FirstName, LastName, Email, MobilePhone FROM User WHERE Id = :currentUser.Account.Responsable_partenariat__c LIMIT 1];
        }

        JSONGenerator gen = JSON.createGenerator(true);
        gen.writeStartObject(); 
        if(respSect != null) {
            gen.writeObjectField('responsableSecteur', respSect);
        } else {
            gen.writeNullField('responsableSecteur');
        }
        if(assistComm != null) {
            gen.writeObjectField('assistantCommercial', assistComm);
        } else {
            gen.writeNullField('assistantCommercial');
        }
        if(respPart != null) {
            gen.writeObjectField('reponsablePartenariat', respPart);
        } else {
            gen.writeNullField('reponsablePartenariat');
        }
*/
        User proprietaire = null;
        User respPart = null;
        
        if(currentUser.Account.OwnerId  != null) {
            proprietaire = [SELECT Id, FirstName, LastName, Email, MobilePhone,Phone,Title FROM User WHERE Id = :currentUser.Account.OwnerId LIMIT 1];
        }
        if(currentUser.Account.Responsable_partenariat__c != null) {
            respPart = [SELECT Id, FirstName, LastName, Email, MobilePhone FROM User WHERE Id = :currentUser.Account.Responsable_partenariat__c LIMIT 1];
        }

        JSONGenerator gen = JSON.createGenerator(true);
        gen.writeStartObject(); 
        if(proprietaire != null) {
            gen.writeObjectField('proprietaire', proprietaire);
        } else {
            gen.writeNullField('proprietaire');
        }
        if(respPart != null) {
            gen.writeObjectField('reponsablePartenariat', respPart);
        } else {
            gen.writeNullField('reponsablePartenariat');
        }
        gen.writeEndObject();
        
        return gen.getAsString();
    }

}