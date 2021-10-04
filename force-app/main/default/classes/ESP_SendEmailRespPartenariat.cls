public with sharing class ESP_SendEmailRespPartenariat {
    
    @InvocableMethod(label='Send email to user')
    public static void SendEmail (Request[] inputs) {
        
            for (Request curInput : inputs) {
                
                if (curInput.respPartenariatID == null) {
                    throw new FlowCustomException('You need to provide an ID  as input to this Flow action.');
                }
                else {
                    EmailTemplate templateParrainage = [SELECT id FROM EmailTemplate WHERE name = :'CEP commande partenaire' LIMIT 1];
                    OrgWideEmailAddress owea = [SELECT Id FROM OrgWideEmailAddress WHERE Address = 'administratif@synerciel.fr' LIMIT 1];
                    Commande_partenaire_recue__c cp = [SELECT Id,Partenaire__r.Name FROM Commande_partenaire_recue__c WHERE Id = :curInput.commandepartenaireID LIMIT 1];
                    
                    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                    /*mail.setTargetObjectId(curInput.respPartenariatID);
                    mail.setWhatId(curInput.commandepartenaireID);
                    mail.setTemplateId(templateParrainage.Id);*/
                    mail = Messaging.renderStoredEmailTemplate(templateParrainage.Id, curInput.respPartenariatID, curInput.commandepartenaireID);
                    mail.setOrgWideEmailAddressId(owea.Id);
                    mail.setSubject('Salesforce : Reception d\'un nouveau fichier de commandes partenaire '+cp.Partenaire__r.Name);
                    mail.saveAsActivity = false;
                    Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
                                        
                }            
            }
    }
    
    public class FlowCustomException extends Exception{}   
    
    public class Request{
        
        @InvocableVariable(label='Id responsable partenariat' required=true)
        public Id respPartenariatID;
       
        @InvocableVariable(label='Id commande partenaire' required=true)
        public Id commandepartenaireID;
        
    }
    
    public class Response{
        @InvocableVariable(label='message returned')
        public String result;
    }
}