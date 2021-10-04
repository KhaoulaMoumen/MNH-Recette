/* 

* Copyright (C) EuraNov -- All Rights Reserved
* Unauthorized copying of this file, via any medium is strictly prohibited
* Proprietary and confidential
* Written by Catherine DELEGLISE <catherine@euranov.com>, July 2019

*/

@isTest
global class DocusignApiTest {
    static testMethod void testNewClass() {
        DocusignApi.SSN4InformationInput ds01 = new DocusignApi.SSN4InformationInput();
        DocusignApi.EventNotification ds02 = new DocusignApi.EventNotification();
        DocusignApi.ArrayOfServerTemplate ds03 = new DocusignApi.ArrayOfServerTemplate();
        DocusignApi.ArrayOfTemplateReferenceFieldDataDataValue ds04 = new DocusignApi.ArrayOfTemplateReferenceFieldDataDataValue();
        DocusignApi.CreateEnvelopeResponse_element ds05 = new DocusignApi.CreateEnvelopeResponse_element();
        DocusignApi.SendEnvelopeResponse_element ds06 = new DocusignApi.SendEnvelopeResponse_element();
        DocusignApi.ArrayOfTemplateReferenceRoleAssignment ds07 = new DocusignApi.ArrayOfTemplateReferenceRoleAssignment();
        DocusignApi.Attachment ds08 = new DocusignApi.Attachment();
        DocusignApi.SSN4Information ds09 = new DocusignApi.SSN4Information();
        DocusignApi.IDCheckInformation ds10 = new DocusignApi.IDCheckInformation();
        DocusignApi.Document ds11 = new DocusignApi.Document();
        DocusignApi.ArrayOfTemplateReference ds12 = new DocusignApi.ArrayOfTemplateReference();
        DocusignApi.RecipientStatus ds13 = new DocusignApi.RecipientStatus();
        DocusignApi.ArrayOfCompositeTemplate ds14 = new DocusignApi.ArrayOfCompositeTemplate();
        DocusignApi.CreateEnvelope_element ds15 = new DocusignApi.CreateEnvelope_element();
        DocusignApi.Reminders ds16 = new DocusignApi.Reminders();
        DocusignApi.CreateEnvelopeFromTemplates_element ds17 = new DocusignApi.CreateEnvelopeFromTemplates_element();
        DocusignApi.ArrayOfCustomField ds18 = new DocusignApi.ArrayOfCustomField();
        DocusignApi.ArrayOfRecipient1 ds20 = new DocusignApi.ArrayOfRecipient1();
        DocusignApi.FormData ds21 = new DocusignApi.FormData();
        DocusignApi.ArrayOfTab ds22 = new DocusignApi.ArrayOfTab();
        DocusignApi.RequestRecipientToken_element ds23 = new DocusignApi.RequestRecipientToken_element();
        DocusignApi.EnvelopeEvent ds24 = new DocusignApi.EnvelopeEvent();
        DocusignApi.Recipient ds25 = new DocusignApi.Recipient();  
        DocusignApi.FormDataXfdf ds26 = new DocusignApi.FormDataXfdf();
          DocusignApi.RecipientCaptiveInfo ds27 = new DocusignApi.RecipientCaptiveInfo();
          DocusignApi.ArrayOfRecipientStatus ds28 = new DocusignApi.ArrayOfRecipientStatus();
          DocusignApi.AuthenticationStatus ds29 = new DocusignApi.AuthenticationStatus();
          DocusignApi.ArrayOfFormDataXfdfField ds30 = new DocusignApi.ArrayOfFormDataXfdfField();
          DocusignApi.RecipientPhoneAuthentication ds31 = new DocusignApi.RecipientPhoneAuthentication();
          DocusignApi.TemplateReferenceFieldDataDataValue ds32 = new DocusignApi.TemplateReferenceFieldDataDataValue();
          DocusignApi.CreateEnvelopeFromTemplatesAndFormsResponse_element ds33 = new DocusignApi.CreateEnvelopeFromTemplatesAndFormsResponse_element();
          DocusignApi.ArrayOfString1 ds34 = new DocusignApi.ArrayOfString1();
          DocusignApi.ArrayOfDocumentStatus ds35 = new DocusignApi.ArrayOfDocumentStatus();
          DocusignApi.CreateEnvelopeFromTemplatesResponse_element ds36 = new DocusignApi.CreateEnvelopeFromTemplatesResponse_element();
          DocusignApi.SendEnvelope_element ds37 = new DocusignApi.SendEnvelope_element();
          DocusignApi.DOBInformationInput ds38 = new DocusignApi.DOBInformationInput();
          DocusignApi.RequestSenderTokenResponse_element ds39 = new DocusignApi.RequestSenderTokenResponse_element();
          DocusignApi.InlineTemplate ds40 = new DocusignApi.InlineTemplate();
          DocusignApi.RecipientSignatureInfo ds41 = new DocusignApi.RecipientSignatureInfo();
          DocusignApi.AddressInformationInput ds42 = new DocusignApi.AddressInformationInput();
          DocusignApi.ArrayOfRecipient ds43 = new DocusignApi.ArrayOfRecipient();
          DocusignApi.CreateEnvelopeFromTemplatesAndForms_element ds44 = new DocusignApi.CreateEnvelopeFromTemplatesAndForms_element();
        DocusignApi.EnvelopeInformation ds45 = new DocusignApi.EnvelopeInformation();
        DocusignApi.AddressInformation ds46 = new DocusignApi.AddressInformation();
        DocusignApi.ArrayOfTabStatus ds47 = new DocusignApi.ArrayOfTabStatus();
        DocusignApi.TemplateReferenceRoleAssignment ds48 = new DocusignApi.TemplateReferenceRoleAssignment();
        DocusignApi.Envelope ds49 = new DocusignApi.Envelope();
        DocusignApi.ArrayOfAttachment ds50 = new DocusignApi.ArrayOfAttachment();
        DocusignApi.Notification ds51 = new DocusignApi.Notification();
        DocusignApi.RequestSenderToken_element ds52 = new DocusignApi.RequestSenderToken_element();
        DocusignApi.CreateAndSendEnvelopeResponse_element ds53 = new DocusignApi.CreateAndSendEnvelopeResponse_element();
        DocusignApi.RequestRecipientTokenAuthenticationAssertion ds54 = new DocusignApi.RequestRecipientTokenAuthenticationAssertion();
        DocusignApi.SSN9InformationInput ds55 = new DocusignApi.SSN9InformationInput();
        DocusignApi.ServerTemplate ds56 = new DocusignApi.ServerTemplate();
        DocusignApi.RequestRecipientTokenResponse_element ds57 = new DocusignApi.RequestRecipientTokenResponse_element();
        DocusignApi.IDCheckInformationInput ds58 = new DocusignApi.IDCheckInformationInput();
        DocusignApi.TabStatus ds59 = new DocusignApi.TabStatus();
        DocusignApi.ArrayOfMatchBox ds60 = new DocusignApi.ArrayOfMatchBox();
        DocusignApi.SSN9Information ds61 = new DocusignApi.SSN9Information();
        DocusignApi.EnvelopeStatus ds62 = new DocusignApi.EnvelopeStatus();
        DocusignApi.ArrayOfEnvelopeEvent ds63 = new DocusignApi.ArrayOfEnvelopeEvent();
        DocusignApi.MatchBox ds64 = new DocusignApi.MatchBox();
        DocusignApi.TemplateReferenceFieldData ds65 = new DocusignApi.TemplateReferenceFieldData();
        DocusignApi.TemplateReference ds66 = new DocusignApi.TemplateReference();
        DocusignApi.CompositeTemplate ds67 = new DocusignApi.CompositeTemplate();
        DocusignApi.DOBInformation ds68 = new DocusignApi.DOBInformation();
        DocusignApi.DocumentStatus ds69 = new DocusignApi.DocumentStatus();
        DocusignApi.AnchorTab ds70 = new DocusignApi.AnchorTab();
        DocusignApi.EventResult ds71 = new DocusignApi.EventResult();
        DocusignApi.FormDataXfdfField ds72 = new DocusignApi.FormDataXfdfField();
        DocusignApi.PDFMetaDataTemplate ds73 = new DocusignApi.PDFMetaDataTemplate();
        DocusignApi.Tab ds74 = new DocusignApi.Tab();
        DocusignApi.ArrayOfInlineTemplate ds75 = new DocusignApi.ArrayOfInlineTemplate();
        DocusignApi.VaultingDetails ds76 = new DocusignApi.VaultingDetails();
        DocusignApi.CustomField ds77 = new DocusignApi.CustomField();
        DocusignApi.Expirations ds78 = new DocusignApi.Expirations();
        DocusignApi.RecipientStatusEsignAgreementInformation ds79 = new DocusignApi.RecipientStatusEsignAgreementInformation();
        DocusignApi.VaultingOptions ds80 = new DocusignApi.VaultingOptions();
        DocusignApi.RequestRecipientTokenClientURLs ds81 = new DocusignApi.RequestRecipientTokenClientURLs();
        DocusignApi.CreateAndSendEnvelope_element ds82 = new DocusignApi.CreateAndSendEnvelope_element();
        DocusignApi.APIServiceSoap ds83 = new DocusignApi.APIServiceSoap();
        DocusignApi.CustomField ds84 = new DocusignApi.CustomField();
        DocusignApi.CustomField ds85 = new DocusignApi.CustomField();
    }
    
/*     static testMethod void testAPIService() {

        DocuSignAPI.APIServiceSoap apiService = new DocuSignAPI.APIServiceSoap();
        apiService.CreateEnvelopeFromTemplates(Null, Null, Null, False);
        apiService.CreateAndSendEnvelope(Null);
        apiService.RequestRecipientToken('', '', '', '', Null, Null);
        apiService.CreateEnvelopeFromTemplatesAndForms(Null, Null, False);
        apiService.RequestSenderToken('', '', '');
        apiservice.SendEnvelope('', '');
    }*/
}