global class LNC14_EnvoyerContratController {

    @AuraEnabled
    public static Offre_PSH__c getOffreDetails(String offreID){
        // RETURN OFFRE STAGE AND ID 
        return [SELECT Id , Avancement_du_dossier__c, RecordTypeId FROM Offre_PSH__c WHERE Id =: offreID];
    }
    
     @AuraEnabled(cacheable=true)
	public static String SendNow(Id offreID, Boolean signatureQualif) {
        String envelopeId;
        String response;
        String webServiceUrl = 'https://www.docusign.net/api/3.0/dsapi.asmx';
        ParamDocusignApi__mdt param = [SELECT integratorsKey__c, Password__c , UserId__c, AccountId__c,Recipient2Email__c,Recipient2Name__c 
                                          FROM ParamDocusignApi__mdt WHERE DeveloperName = 'Bulk1' LIMIT 1];

        Offre_PSH__c offre = [SELECT Id, Compte__c, Annee__c, Compte__r.Name FROM Offre_PSH__c WHERE id =:offreID LIMIT 1];
        
        DocuSignAPI.APIServiceSoap dsApiSend = new DocuSignAPI.APIServiceSoap();
        dsApiSend.endpoint_x = webServiceUrl;
        
        //Set Authentication
        String auth = '<DocuSignCredentials><Username>'+ param.UserId__c
            +'</Username><Password>' + param.Password__c
            + '</Password><IntegratorKey>' + param.integratorsKey__c
            + '</IntegratorKey></DocuSignCredentials>';
        System.debug('Setting authentication to: ' + auth);
        System.debug('Offre: ' + offre);
        
        dsApiSend.inputHttpHeaders_x = new Map<String, String>();
        dsApiSend.inputHttpHeaders_x.put('X-DocuSign-Authentication', 
                                         auth);
        //CREATE ENVELOPPE 
        DocuSignAPI.Envelope envelope = new DocuSignAPI.Envelope();
        envelope.Subject = 'Votre contrat synerciel ' + offre.Annee__c;
        envelope.EmailBlurb = '<p>Madame, Monsieur,</p><p>Vous trouverez ci-dessous le lien qui vous permettra, en un seul clic, de signer électroniquement, dans un espace sécurisé, votre contrat SynerCiel 2021.</p><p>Nous vous engageons, avant de signer, à relire le contrat et les conditions particulières.</p><p>Cette année, vous allez bénéficier d’une offre d’accompagnement plus complète et de services pensés pour vous.</p><p>&nbsp;</p><p><em>SynerCiel est à votre disposition pour répondre à vos questions et vous accompagner dans la démarche au&nbsp;<strong>0 805 850&nbsp;450</strong ou &nbsp;</em>  <a href="mailto:service-adherent@synerciel.fr"><em>service-adherent@synerciel.fr</em></a></p><p>Merci de contribuer à améliorer l’efficacité de tous en utilisant cette démarche de dématérialisation.</p><p>&nbsp;</p><p>Bien cordialement,</p><p><strong>Le Service Adhérent SynerCiel</strong></p><p>&nbsp;</p>';        envelope.AccountId  = param.AccountId__c; 
        
        
        // Récupère la convention générée au préalable par S-Docs
        List<ContentDocumentLink> linkedDocument = [Select id, ContentDocumentId, ContentDocument.LatestPublishedVersionId from ContentDocumentLink where LinkedEntityId=:offre.Id ORDER BY ContentDocument.ContentModifiedDate  DESC];
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
            contact = [SELECT Email, FirstName, LastName FROM Contact WHERE AccountId=:offre.Compte__c AND Fonction__c ='Gérant / Directeur Général' LIMIT 1];
        }catch(Exception e){
            System.debug('Exception - ' + e );
            response =+ 'Problème de récupération du Gérant / Directeur Général pour le compte '+offre.Compte__r.Name;
        }
        
        // SET DOCUSIGN RECIPIENTS 
        // CONTACT WITH FONCTION GERANT/DIRECTEUR GENERAL
        DocuSignAPI.Recipient recipient1 = new DocuSignAPI.Recipient();
        recipient1.ID = 1;
        recipient1.Type_x = 'Signer';
        recipient1.RoutingOrder = 1;
        recipient1.Email = contact.Email;
        recipient1.UserName = contact.FirstName + ' ' + contact.LastName;

		 if(signatureQualif) {
             /*
             DocuSignAPI.RecipientSignatureProviders recipientP = new DocuSignAPI.RecipientSignatureProviders();
             recipientP.signatureProviderName = 'UniversalSignaturePen_IDNow_TSP';
             recipient1.recipientSignatureProviders = recipientP;
             
            recipient1.signNow = true;
            
			 recipient1.SignatureInfo.SignatureName = 'UniversalSignaturePen_IDNow_TSP'; */
             
            DocuSignAPI.RecipientSignatureInfo recipientSignature = new DocuSignAPI.RecipientSignatureInfo();
            recipientSignature.SignatureName = 'IDnow - EU Qualified';
        }        
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
        myCustomField.Name = '##SFOffrePEE'; 
        myCustomField.Value = offre.id;
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
                system.debug('envelopeId'+envelopeId);
                // SUCCESS MESSAGE
                response = 'Le contrat a été bien envoyé.';
            } catch ( CalloutException e) {
                System.debug('Exception - ' + e );
                envelopeId = 'Exception - ' + e;
                // ERROR MESSAGE
				response = 'une erreur a été rencontrée lors de l\'envoi du contrat.';                
            }
        }
        return response;
    }
        
}