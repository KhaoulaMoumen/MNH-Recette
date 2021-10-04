/*----------------------------------------------------------------------
-- - Name          : BA05_SendConventionToSign
-- - Author        : 
-- - Description   : 
--   
-- Maintenance History:
--
-- Date         Name                Version     Remarks 
-- -----------  -----------         --------    ---------------------------------------
-- 12-10-2020   KM                    1.0         Init
-- 23-10-2020   RDB                   1.1         Optims
-- 29-10-2020   KM                    1.2         Correction
-- 09-09-2021   AL                    1.3         Test pour Reconventionnement 2022 (année dynamique, ajout de destinataires QSIT)
---------------------------------------------------------------------------------------
*/
global class BA05_SendConventionToSign implements Database.Batchable<sObject>, Database.Stateful, Database.AllowsCallouts {
    
    private String webServiceUrl = 'https://demo.docusign.net/api/3.0/dsapi.asmx';
    public Boolean sendIt = true;
    
    ParamDocusignApi__mdt param;
    String auth;

    Map<String, String> mapErrorsByOppName = new Map<String, String>();
    Integer nbOpportOk = 0;

    public class ContactNotFoundException extends Exception {
    }

    global BA05_SendConventionToSign() {
        param = [SELECT integratorsKey__c, Password__c , UserId__c, AccountId__c,Recipient2Email__c,Recipient2Name__c 
                                          FROM ParamDocusignApi__mdt WHERE DeveloperName = 'Bulk1' LIMIT 1
                                         ];

        //Set Authentication
        auth = '<DocuSignCredentials><Username>'+ param.UserId__c
            +'</Username><Password>' + param.Password__c
            + '</Password><IntegratorKey>' + param.integratorsKey__c
            + '</IntegratorKey></DocuSignCredentials>';

        System.debug('[BA05_SendConventionToSign] Setting authentication to: ' + auth);
    }                                     
    
    /**
     * 
     */    
    global Database.QueryLocator start(Database.BatchableContext bc){
        return Database.getQueryLocator([SELECT Id, Name, stageName, Annee__c, AccountId, Account.Name 
                                            FROM Opportunity 
                                            WHERE TECH_Envoi_en_masse__c = :sendIt]);
    }
    
    /**
     * 
     */
    global void execute(Database.BatchableContext BC, List<Opportunity> scope){
        List<DocuSignAPI.Envelope> envelopesToInsert = new List<DocuSignAPI.Envelope>();
        
        DocuSignAPI.APIServiceSoap dsApiSend  = new DocuSignAPI.APIServiceSoap();
        dsApiSend.endpoint_x = webServiceUrl;
        dsApiSend.inputHttpHeaders_x = new Map<String, String>();
        dsApiSend.inputHttpHeaders_x.put('X-DocuSign-Authentication', auth);
        
        
        // on récupère les contacts destinataires des documents
        List<Contact> listGerantDG = [SELECT Email, FirstName, LastName, AccountId 
                                        FROM Contact where AccountId = :getAccountId(scope) 
                                        AND Fonction__c ='Gérant / Directeur Général'];
        Map<Id,Contact> mapGerantDGByAccountId = groupContactByAccountId(listGerantDG);

        // on récupère les conventions des opportunités
        List<ContentDocumentLink> listDocuments = [SELECT LinkedEntityId, ContentDocument.LatestPublishedVersionId 
                                                        FROM ContentDocumentLink 
                                                        WHERE LinkedEntityId IN :getId(scope) 
                                                        ORDER BY ContentDocument.ContentModifiedDate DESC];
        Map<Id, ContentDocumentLink> mapDocByOppId = new Map<Id, ContentDocumentLink>();
        List<Id> listVersionId = new List<Id>();
        for (ContentDocumentLink doc : listDocuments) {
            // on récupère uniquement le dernier doc modifié
            if(!mapDocByOppId.containsKey(doc.LinkedEntityId)){
                mapDocByOppId.put(doc.LinkedEntityId, doc);
                listVersionId.add(doc.ContentDocument.LatestPublishedVersionId);
            }
        }

        Map<Id, ContentVersion> mapContentVersion = new Map<Id, ContentVersion>([SELECT Id, Title, ContentDocumentId, VersionData 
                                                    FROM ContentVersion 
                                                    WHERE Id IN :listVersionId]);


        // on parcourt les opportunités
        for(Opportunity opport : scope){
            System.debug('[BA05_SendConventionToSign] Opportunity: ' + opport);
            
            ContentDocumentLink doc = mapDocByOppId.get(opport.id);
            ContentVersion lastDocVersion = mapContentVersion.get(doc.ContentDocument.LatestPublishedVersionId);
            Blob pdfBlob = lastDocVersion.VersionData;

            try {
                DocuSignAPI.Envelope envelope = createEnvelope(opport, pdfBlob, mapGerantDGByAccountId);

                if(!Test.isRunningTest()){
                    System.debug('[BA05_SendConventionToSign] Calling the API');
                    // CREATE AND SEND DOCUSIGN ENVELOPPE
                    DocuSignAPI.EnvelopeStatus es = dsApiSend.CreateAndSendEnvelope(envelope);
                    System.debug('[BA05_SendConventionToSign] envoi docusign du reconventionnement '+ envelope.Subject +': OK');
                }

                nbOpportOk++;

            } catch (ContactNotFoundException e1) {
                mapErrorsByOppName.put(opport.Id + ' - ' + opport.Name, 'Aucun Gérant / Directeur Général n\'a été trouvé pour le compte : ' + opport.AccountId);
                
            } catch(CalloutException e2) {
                System.debug('[BA05_SendConventionToSign] Exception - ' + e2 );
                System.debug('[BA05_SendConventionToSign] envoi docusign du reconventionnement : KO'); 
                System.debug('[BA05_SendConventionToSign] error '+ e2.getCause());

                if( e2.getMessage() == 'System.CalloutException: IO Exception: Read timed out') mapErrorsByOppName.put(opport.Id + ' - ' + opport.Name, 'Erreur lors de l\'envoi à Docusign : Read timed out Exception');
                else mapErrorsByOppName.put(opport.Id + ' - ' + opport.Name, 'Erreur lors de l\'envoi à Docusign :' + e2.getCause());
            }
        }
    }
    
    /**
     * 
     */
    global void finish(Database.BatchableContext BC){   
        if(mapErrorsByOppName.keySet().size() > 0) {
            String mailContent = '';
            String mailContent2 = '';
            
            for (String oppName : mapErrorsByOppName.keySet()) {
                if((mapErrorsByOppName.get(oppName)).contains('Read timed out')){
                    mailContent2 += 'Opportunité : ' + oppName + '<br/>';
                    mailContent2 += 'Erreur : ' + mapErrorsByOppName.get(oppName) + '<br/><br/>';
                }
                else {
                    mailContent += 'Opportunité : ' + oppName + '<br/>';
                    mailContent += 'Erreur : ' + mapErrorsByOppName.get(oppName) + '<br/><br/>';
                }
            }
            System.debug('[BA05_SendConventionToSign] on envoie un email d\'alerte car ily a eu des erreurs');
            
            if(mailContent != NULL && mailContent != '') envoyerAlerte('Erreur dans l\'envoi en masse des conventions', mailContent);
            if(mailContent2 != NULL && mailContent2 != '')  envoyerAlerte('Erreur dans l\'envoi en masse des conventions', mailContent2);
        }
        else {
            String mailContent = nbOpportOk + ' contrats ont bien été envoyés';
            envoyerAlerte('Envoi en masse des conventions', mailContent);
            System.debug('[BA05_SendConventionToSign] Le batch a fini sans erreurs');
        }    
    }

    /**
     * Envoie un email
     */
    private static void envoyerAlerte(String subject, String content) {
        Messaging.SingleEmailMessage msg = new Messaging.SingleEmailMessage();
         String[] toAddresses = new String[] { 'salesforce-team@talan.com', 'Julie.leboyer@synerciel.fr','nicolas.maurice@synerciel.fr','estelle.hauteville@synerciel.fr','alexis.ly@synerciel.fr'}; 
        //String[] toAddresses = new String[] { 'salesforce-team@talan.com' }; 
            
        msg.setToAddresses(toAddresses);
        msg.setSubject(subject);
        msg.setHtmlBody(content);

        Messaging.SendEmailResult[] results = Messaging.sendEmail(new List<Messaging.SingleEmailMessage> {msg});
    }

    /**
     * Crée l'enveloppe Docusign pour l'opportunité
     */
    private DocuSignAPI.Envelope createEnvelope(Opportunity opport, Blob pdfBlob, Map<Id,Contact> mapGerantDGByAccountId) {
        //CREATE ENVELOPPE 
        DocuSignAPI.Envelope envelope = new DocuSignAPI.Envelope();
        envelope.Subject = 'Signez votre contrat SynerCiel ' + (Integer)opport.Annee__c;
        envelope.EmailBlurb = '<p>Madame, Monsieur,</p><p>Vous trouverez ci-dessous le lien qui vous permettra, en un seul clic, de signer électroniquement, dans un espace sécurisé, votre contrat SynerCiel ' + (Integer)opport.Annee__c + '.</p><p>Nous vous engageons, avant de signer, à relire le contrat et les conditions particulières.</p><p>Vous allez bénéficier d’une offre d’accompagnement complète et de services pensés pour vous.</p><p>&nbsp;</p><p><em>SynerCiel est à votre disposition pour répondre à vos questions et vous accompagner dans la démarche au&nbsp;<strong>0 805 850&nbsp;450</strong ou &nbsp;</em>  <a href="mailto:service-adherent@synerciel.fr"><em>service-adherent@synerciel.fr</em></a></p><p>Merci de contribuer à améliorer l’efficacité de tous en utilisant cette démarche de dématérialisation.</p><p>&nbsp;</p><p>Bien cordialement,</p><p><strong>Le Service Adhérent SynerCiel</strong></p><p>&nbsp;</p>';
        envelope.AccountId  = param.AccountId__c; 
        
        // CREATE FILE CONTRACT
        DocuSignAPI.Document document = new DocuSignAPI.Document();
        document.ID = 1;
        document.pdfBytes = EncodingUtil.base64Encode(pdfBlob);
        document.Name = 'Contract';
        document.FileExtension = 'pdf';
        envelope.Documents = new DocuSignAPI.ArrayOfDocument();
        envelope.Documents.Document = new DocuSignAPI.Document[1];
        envelope.Documents.Document[0] = document;
        
        // GET THE RECIPIENTS
        System.debug('getting the contact');
        Contact contact = mapGerantDGByAccountId.get(opport.AccountId);

        if(contact == null) {
            System.debug('[BA05_SendConventionToSign] Gérant/DG non trouvé pour l\'opportunité : ' + opport.Id + ' et le AccountId: ' + opport.AccountId);
            throw new ContactNotFoundException('Gérant/DG non trouvé pour l\'opportunité : ' + opport.Id + ' et le AccountId: ' + opport.AccountId);
        }
        
        // SET DOCUSIGN RECIPIENTS 
        // CONTACT WITH FONCTION GERANT/DIRECTEUR GENERAL
        DocuSignAPI.Recipient recipient1 = new DocuSignAPI.Recipient();
        recipient1.ID = 1;
        recipient1.Type_x = 'Signer';
        recipient1.RoutingOrder = 1;
        recipient1.Email = contact.Email;
        recipient1.UserName = contact.FirstName + ' ' + contact.LastName;
        
        // DOCUSIGN SECOND SIGNER - DG 
        DocuSignAPI.Recipient recipient2 = new DocuSignAPI.Recipient();
        recipient2.ID = 2;
        recipient2.Type_x = 'Signer';
        recipient2.RoutingOrder = 2;
        recipient2.Email = param.Recipient2Email__c;
        recipient2.UserName = param.Recipient2Name__c;
        
        // This setting seems required or you see the error:
        // "The string '' is not a valid Boolean value. 
        // at System.Xml.XmlConvert.ToBoolean(String s)" 
        recipient1.RequireIDLookup = false;      
        
        envelope.Recipients = new DocuSignAPI.ArrayOfRecipient();
        envelope.Recipients.Recipient = new DocuSignAPI.Recipient[2];
        envelope.Recipients.Recipient[0] = recipient1;
        envelope.Recipients.Recipient[1] = recipient2;
        
        // SET DOCUSIGN TABS
        DocuSignAPI.Tab tab1 = new DocuSignAPI.Tab();
        tab1.Type_x = 'SignHere';
        tab1.RecipientID = 1;
        tab1.DocumentID = 1;
        tab1.AnchorTabItem = new DocuSignAPI.AnchorTab();
        tab1.AnchorTabItem.AnchorTabString = '\\s1\\';
        
        // SET DOCUSIGN TABS        
        DocuSignAPI.Tab tab2 = new DocuSignAPI.Tab();
        tab2.Type_x = 'DateSigned';
        tab2.RecipientID = 1;
        tab2.DocumentID = 1;
        tab2.AnchorTabItem = new DocuSignAPI.AnchorTab();
        tab2.AnchorTabItem.AnchorTabString = '\\d1\\';
        
        // SET DOCUSIGN TABS        
        DocuSignAPI.Tab tab3 = new DocuSignAPI.Tab();
        tab3.Type_x = 'SignHere';
        tab3.RecipientID = 2;
        tab3.DocumentID = 1;
        tab3.AnchorTabItem = new DocuSignAPI.AnchorTab();
        tab3.AnchorTabItem.AnchorTabString = '\\s2\\';
        
        // ADD TABS TO DOCUSIGN ENVELOPPE
        envelope.Tabs = new DocuSignAPI.ArrayOfTab();
        envelope.Tabs.Tab = new DocuSignAPI.Tab[3];
        envelope.Tabs.Tab[0] = tab1;        
        envelope.Tabs.Tab[1] = tab2;  
        envelope.Tabs.Tab[2] = tab3;  
        
        //use custom field to store the id of the record that initiated the transaction    
        envelope.CustomFields = new DocuSignAPI.ArrayOfCustomField();
        envelope.CustomFields.CustomField = new DocuSignAPI.CustomField[2];
        DocuSignAPI.CustomField myCustomField = new DocuSignAPI.CustomField();
        myCustomField.Name = '##SFOpportunity'; 
        myCustomField.Value = opport.id;
        myCustomField.Show = 'False';
        myCustomField.Required = 'False';
        myCustomField.CustomFieldType = 'Text';
        envelope.CustomFields.CustomField[0] = myCustomField;

        return envelope;
    }

    /**
     * 
     */
    private List<Id> getAccountId(List<Opportunity> listOpp) {
        Set<Id> setAccountId = new Set<Id>();
        
        for (Opportunity opp : listOpp) {
            setAccountId.add(opp.AccountId);
        }

        List<Id> listAccountId = new List<Id>();
        listAccountId.addAll(setAccountId);

        return listAccountId;
    }

    /**
     * 
     */
    private List<Id> getId(List<Opportunity> listOpp) {
        Set<Id> setId = new Set<Id>();
        
        for (Opportunity opp : listOpp) {
            setId.add(opp.Id);
        }

        List<Id> listId = new List<Id>();
        listId.addAll(setId);

        return listId;
    }

    /**
     * 
     */
    private Map<Id, Contact> groupContactByAccountId(List<Contact> listContacts) {
        Map<Id, Contact> mapContactByAccountId = new Map<Id, Contact>();

        for (Contact contact : listContacts) {
            mapContactByAccountId.put(contact.AccountId, contact);
        }

        return mapContactByAccountId;
    }
}