/* 

* Copyright (C) EuraNov -- All Rights Reserved
* Unauthorized copying of this file, via any medium is strictly prohibited
* Proprietary and confidential
* Written by Catherine DELEGLISE <catherine@euranov.com>, July 2019

*/

public with sharing class SendToDocuSignController {
    private ApexPages.StandardSetController standardController;
    
    // GET DOCUSIGN SIGNER PARAMS FROM METADATA
    public ParamDocusignApi__mdt param = [Select integratorsKey__c, Password__c , UserId__c, AccountId__c,Recipient2Email__c,Recipient2Name__c from ParamDocusignApi__mdt limit 1];
    public String envelopeId {get;set;}
    //private String accountId = '';
    //private String userId = '';
    //private String password = '';
    //private String integratorsKey = '';
    private String webServiceUrl 
        = 'https://demo.docusign.net/api/3.0/dsapi.asmx';
    
    public SendToDocuSignController (ApexPages.StandardSetController standardController ){
        this.standardController = standardController;
    }
    
    public PageReference Prev() {
        // RETURN OPPORTUNITIES LIST VIEW
        PageReference pg = new PageReference('/lightning/o/Opportunity/list?filterName=Recent');
        pg.setRedirect(true);
        return pg;
    }
    
    
    public PageReference SendDataToDocusign()
    {
        // GET SELECTED OPPRTUNITY INFOS
        List<Opportunity> selectedOpp = (List<Opportunity>) standardController.getSelected();
        List<Opportunity> myopps = [select Id, Annee__c, AccountId, Name, Account.Name from Opportunity where id IN:selectedOpp];
        envelopeId = 'Not sent yet';
        for (Opportunity opp : myopps){
            // SEND EMAIL DOCUSIGN + CONTACT
            SendNow(opp);
        }
        return null;
    }
    
    public void SendNow(Opportunity opport)
    {
        DocuSignAPI.APIServiceSoap dsApiSend 
            = new DocuSignAPI.APIServiceSoap();
        dsApiSend.endpoint_x = webServiceUrl;
        
        //Set Authentication
        String auth = '<DocuSignCredentials><Username>'+ param.UserId__c
            +'</Username><Password>' + param.Password__c
            + '</Password><IntegratorKey>' + param.integratorsKey__c
            + '</IntegratorKey></DocuSignCredentials>';
        System.debug('Setting authentication to: ' + auth);
        System.debug('Opportunity: ' + opport);
        
        dsApiSend.inputHttpHeaders_x = new Map<String, String>();
        dsApiSend.inputHttpHeaders_x.put('X-DocuSign-Authentication', 
                                         auth);
        //CREATE ENVELOPPE 
        DocuSignAPI.Envelope envelope = new DocuSignAPI.Envelope();
        envelope.Subject = 'Votre contrat synerciel ' + opport.Annee__c;
        envelope.EmailBlurb = '<p>Chère Adhérente, cher Adhérent,</p><p>Vous trouverez, ci-dessus le lien qui vous permettra<strong>, en un seul clic, de signer votre convention SynerCiel 2020</strong>.</p><p>&nbsp;</p><p>Nous nous employons à renforcer toujours plus notre offre pour votre satisfaction.</p><p><strong>L’année 2020 sera riche en nouveautés&nbsp;! Nous comptons sur votre engagement.</strong></p><p>&nbsp;</p><p><em>SynerCiel est à votre disposition pour répondre à vos questions et vous accompagner dans la démarche au&nbsp;<strong>0 805 850&nbsp;450</strong> (appel et service gratuits) ou&nbsp;</em>  <a href="mailto:administratif@synerciel.fr"><em>administratif@synerciel.fr</em></a></p><p>&nbsp;</p><p>&nbsp;</p><p>Bien cordialement,</p><p><strong>Le Service Adhérent SynerCiel</strong></p><p>&nbsp;</p>';
        envelope.AccountId  = param.AccountId__c; 
        
        
        // Récupère la convention générée au préalable par S-Docs
        List<ContentDocumentLink> linkedDocument = [Select id, ContentDocumentId, ContentDocument.LatestPublishedVersionId from ContentDocumentLink where LinkedEntityId=:opport.Id ORDER BY ContentDocument.ContentModifiedDate  DESC];
        ContentVersion contentVersion = [SELECT Id, Title, ContentDocumentId, VersionData FROM ContentVersion WHERE Id = :linkedDocument[0].ContentDocument.LatestPublishedVersionId LIMIT 1];
        Blob pdfBlob = contentVersion.VersionData;
        
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
        Contact contact = new Contact();
        try{
            contact = [SELECT Email, FirstName, LastName from Contact where AccountId=:opport.AccountId AND Fonction__c ='Gérant / Directeur Général' LIMIT 1];
        }catch(Exception e){
            System.debug('Exception - ' + e );
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Problème de récupération du Gérant / Directeur Général pour le compte '+opport.Account.Name));
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
        
        if(!Test.isRunningTest()){
            System.debug('Calling the API');
            try {
                // CREATE AND SEND DOCUSIGN ENVELOPPE
                DocuSignAPI.EnvelopeStatus es = dsApiSend.CreateAndSendEnvelope(envelope);
                envelopeId = es.EnvelopeID;
                // SUCCESS MESSAGE
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.CONFIRM,'envoi docusign du reconventionnement '+opport.Name+' pour le compte ' + opport.Account.Name +': OK')); 
            } catch ( CalloutException e) {
                System.debug('Exception - ' + e );
                envelopeId = 'Exception - ' + e;
                // ERROR MESSAGE
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'envoi docusign du reconventionnement '+opport.Name+' pour le compte ' + opport.Account.Name +': KO . Transmettez cette erreur à votre  : '+ e)); 
                
            }
        }
        
    }
}