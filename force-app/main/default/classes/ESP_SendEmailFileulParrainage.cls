public without sharing class ESP_SendEmailFileulParrainage {
    
    @InvocableMethod(label='Send email to lead')
    public static void SendEmail (Request[] inputs) {
        
        for (Request curInput : inputs) {
            
            if (curInput.sponsoredLead == null) {
                throw new FlowCustomException('You need to provide either a lead as input to this Flow action.');
            }
            else {
                EmailTemplate templateParrainage = [SELECT id FROM EmailTemplate WHERE name = :Label.ESP_Filleul_ET LIMIT 1];
                OrgWideEmailAddress owea = [SELECT Id FROM OrgWideEmailAddress WHERE Address = 'administratif@synerciel.fr' LIMIT 1];
                
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                mail.setTargetObjectId(curInput.sponsoredLead);
                mail.setTemplateId(templateParrainage.Id);
                mail.setOrgWideEmailAddressId(owea.Id);
                mail.saveAsActivity = false;
                Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
            }            
        }
    }
    
    public class FlowCustomException extends Exception{}   
    
    public class Request{
        
        @InvocableVariable(label='Id Lead sponsored' required=true)
        public Id sponsoredLead;
        
    }
    
    public class Response{
        @InvocableVariable(label='message returned')
        public String result;
    }
    
}