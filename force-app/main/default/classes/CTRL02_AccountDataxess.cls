public with sharing class CTRL02_AccountDataxess {
   
    public static void replicateDataxessToSynercielFields(List<Account> accounts) {

            List<Code_APE__c> codesAPE          = new List<code_APE__c>();
            List<String> lstCodeApe             = new List<String>();
            Map<String,Id> mapIdAPEbyCode       = new Map<String,Id>();
        
            Map<String,Code_APE__c> mapExistingCodeAPEBycode       = new Map<String,Code_APE__c>();

            for(account a : accounts) {
                if (a.Code_NAF_entreprise__c != null && !lstCodeApe.contains(a.Code_NAF_entreprise__c)){
                    lstCodeApe.add(a.Code_NAF_entreprise__c);
                }
            }

            List<Code_APE__c> listExistingCodeAPE = [SELECT ID, Code__c, Name FROM Code_APE__c WHERE Code__c in :lstCodeApe];  
            for (code_APE__c ca : listExistingCodeAPE){
                mapExistingCodeAPEBycode.put(ca.Code__c, ca);
            }
			
        	lstCodeApe.clear();
        
            for(account a : accounts) {
                if (a.Code_NAF_entreprise__c != null && !lstCodeApe.contains(a.Code_NAF_entreprise__c) ){
                  lstCodeApe.add(a.Code_NAF_entreprise__c);
                  if (mapExistingCodeAPEBycode.containsKey(a.Code_NAF_entreprise__c) ){
                    if ((a.Code_NAF_entreprise__c + '-' + a.Libelle_code_NAF_entreprise__c).length() <= 80){
                        Code_APE__c codeAPE = new code_APE__c(
                            Code__c = a.Code_NAF_entreprise__c,
                            Name    = a.Code_NAF_entreprise__c + '-' + a.Libelle_code_NAF_entreprise__c,
                            CompleteNameCodeAPE__c = a.Code_NAF_entreprise__c + '-' + a.Libelle_code_NAF_entreprise__c
                        );
                        codesAPE.add(codeAPE);
                    }
                    else{
                        Code_APE__c codeAPE = new code_APE__c(
                            Code__c = a.Code_NAF_entreprise__c,
                            CompleteNameCodeAPE__c = a.Code_NAF_entreprise__c + '-' + a.Libelle_code_NAF_entreprise__c
                        );
                        codesAPE.add(codeAPE);
                    }
                  }
                  else {
                    if ((a.Code_NAF_entreprise__c + '-' + a.Libelle_code_NAF_entreprise__c).length() <= 80){
                        Code_APE__c codeAPE = new code_APE__c(
                            Code__c = a.Code_NAF_entreprise__c,
                            Name    = a.Code_NAF_entreprise__c + '-' + a.Libelle_code_NAF_entreprise__c,
                            CompleteNameCodeAPE__c = a.Code_NAF_entreprise__c + '-' + a.Libelle_code_NAF_entreprise__c
                        );
                        codesAPE.add(codeAPE);
                    }else {
                        Code_APE__c codeAPE = new code_APE__c(
                            Code__c = a.Code_NAF_entreprise__c,
                            Name    = (a.Code_NAF_entreprise__c + '-' + a.Libelle_code_NAF_entreprise__c).subString(0,79),
                            CompleteNameCodeAPE__c = a.Code_NAF_entreprise__c + '-' + a.Libelle_code_NAF_entreprise__c
                        );
                        codesAPE.add(codeAPE);
                    }
                  }  
                }
            }    
        
            if (codesAPE.size() > 0){
                upsert codesAPE Code__c;
            }

            for (code_APE__c ca : codesAPE){
                mapIdAPEbyCode.put(ca.Code__c, ca.Id);
            }

            for(account a : accounts) {
                if(a.SIRET__c != null )	{a.sirenSiret__c = a.SIRET__c;}
                if(a.Date_creation_entreprise__c != null ){a.companyCreationDate__c = a.Date_creation_entreprise__c;}
                if(a.Enseigne__c != null ){a.Name2__c = a.Enseigne__c;}
                if(a.Capital_social__c != null ){a.Capital__c = a.Capital_social__c;}
                a.BillingCountry = Label.Altares_BillingCountry;
				a.Phone = (String.isBlank(a.Telephone__c))?'':a.Telephone__c.replace('+33','0');
                a.Code_APE__c =  mapIdAPEbyCode.get(a.Code_NAF_entreprise__c);
            }
    }


    public static void notifyOwnerChangeStateByBell(List<Account> accounts){
        // Get the Id for our custom notification type
        CustomNotificationType notificationType = 
        [SELECT Id, DeveloperName 
        FROM CustomNotificationType 
        WHERE DeveloperName='Notification_My_Synerciel'];

        for(Account a :accounts){
            // Create a new custom notification
            Messaging.CustomNotification notification = new Messaging.CustomNotification();

            // Set the contents for the notification
            notification.setTitle(Label.Dataxess_Notification_title);
            notification.setBody(a.name);

            // Set the notification type and target
            notification.setNotificationTypeId(notificationType.Id);
            notification.setTargetId(a.Id);

            // Actually send the notification
            try {
                notification.send(new Set<String> {a.OwnerID});
            }
            catch (Exception e) {
                System.debug('Dataxess : Problem sending notification: ' + e.getMessage());
            }
        }
    }

    public static void notifyOwnerChangeStateByMail(List<Account> accounts){


            Messaging.SingleEmailMessage[] mails = new Messaging.SingleEmailMessage[]{};
            EmailTemplate emailTemplate = [Select Id,Subject,Description,HtmlValue,DeveloperName,Body from EmailTemplate where DeveloperName = 'Dataxess_AccountChangeState'];
 
            List<String> listCCmails  = Util_Dataxess_Mails.getMailAddresses('Altares_Notifications_Mails');
            
            for (Account acc : accounts) {    
                Messaging.SingleEmailMessage message = new  Messaging.SingleEmailMessage();
                message.setTargetObjectId(acc.OwnerID); 
                if (listCCmails.size() > 0){
                    message.setCcAddresses(listCCmails);
                }
                
                message.setSenderDisplayName(Label.Dataxess_Notification_SenderName);
                message.setReplyTo(Label.Dataxess_Notification_NoReply);
                message.setUseSignature(false); 
                message.setBccSender(false); 
                message.setSaveAsActivity(false); 
                message.setTemplateID(emailTemplate.Id); 
                message.setWhatId(acc.Id);
                mails.add(message);
            }
        if(Label.Dataxess_SendMailActive == 'Yes'){
				Messaging.sendEmail(mails);

            for (Messaging.SendEmailResult result : Messaging.sendEmail(mails)){
                    
                if (!result.isSuccess()){
                    System.debug('Dataxess : Problem sending mail: ' + result.getErrors());
                } 

            }
        }
    }
 
}