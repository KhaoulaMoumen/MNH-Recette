({
    doInit : function(component, event, helper) {
        var action = component.get("c.getOffreDetails");
        action.setParams({
            "offreID":  component.get('v.recordId')
        }); 
        action.setCallback(this, function(a) {
            
            if(a.getReturnValue() != null && a.getReturnValue().Avancement_du_dossier__c != $A.get("$Label.c.LABS_SF_Envoi_du_Contrat") && a.getReturnValue().RecordTypeId == $A.get("$Label.c.LABS_SF_Offre_PEE")){
                component.set("v.resultMessage",  $A.get("$Label.c.LABS_SF_Error_Message_for_Envoyer_contrat"));
            }
            else{
                var urlEvent = $A.get("e.force:navigateToURL");
                
                var urlDocusign = '?SourceID='+a.getReturnValue().Id+'&CRL=FirstName~Grégoire;LastName~HAMON;Role~Synerciel;RoutingOrder~2;Email~gregoire.hamon@synerciel.fr&CCRM=Signataire~Signataire;Synerciel~Synerciel&CCTM=Signataire~Signer;Synerciel~Signer&LA=0&LF=1';
                
                if(a.getReturnValue().RecordTypeId == $A.get("$Label.c.LABS_SF_Offre_PEE") && a.getReturnValue().Avancement_du_dossier__c == $A.get("$Label.c.LABS_SF_Envoi_du_Contrat")) 
                {
                    console.log('https://synerciel.lightning.force.com/apex/dsfs__DocuSign_CreateEnvelope'+urlDocusign); 
                    // window.location('https://synerciel.lightning.force.com/apex/dsfs__DocuSign_CreateEnvelope'+urlDocusign);
                     window.open('{!URLFOR("https://synerciel.lightning.force.com/apex/dsfs__DocuSign_CreateEnvelope?SourceID="+a.getReturnValue().Id+"&CRL=FirstName~Grégoire;LastName~HAMON;Role~Synerciel;RoutingOrder~2;Email~gregoire.hamon@synerciel.fr&CCRM=Signataire~Signataire;Synerciel~Synerciel&CCTM=Signataire~Signer;Synerciel~Signer&LA=0&LF=1")}');
                    /*var pageUrl = '{!URLFOR($Page.dsfs__DocuSign_CreateEnvelope,null)}';
                    var parameters = '?SourceID='+a.getReturnValue().Id+'&CRL=FirstName~Grégoire;LastName~HAMON;Role~Synerciel;RoutingOrder~2;Email~gregoire.hamon@synerciel.fr&CCRM=Signataire~Signataire;Synerciel~Synerciel&CCTM=Signataire~Signer;Synerciel~Signer&LA=0&LF=1';
                    var link = pageUrl + parameters;
                    window.open(link);*/
                }
                if(a.getReturnValue().RecordTypeId == $A.get("$Label.c.LABS_SF_Coup_de_Pouce")) 
                {
                    urlEvent.setParams({
                        'url' : '/apex/dsfs__DocuSign_CreateEnvelope?SourceID='+a.getReturnValue().Id+'&CRL=FirstName~Grégoire;LastName~HAMON;Role~Synerciel;RoutingOrder~2;Email~gregoire.hamon@synerciel.fr&CCRM=Signataire~Signataire;Synerciel~Synerciel&CCTM=Signataire~Signer;Synerciel~Signer&LA=0&LF=1'
                    });
                }
               // urlEvent.fire(); 
            }  
            
        });
        $A.enqueueAction(action);  
    }
    
})