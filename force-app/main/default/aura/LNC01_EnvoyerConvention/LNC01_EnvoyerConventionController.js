({
    doInit : function(component, event, helper) {
        var action = component.get("c.getOppDetails");
        action.setParams({
            "oppId":  component.get('v.recordId')
        }); 
        action.setCallback(this, function(a) {
            
            if(a.getReturnValue() != null && a.getReturnValue().StageName != $A.get("$Label.c.LABS_SF_Envoi_de_la_convention_Stage") && a.getReturnValue().RecordType.Name == $A.get("$Label.c.LABS_SF_Recrutement"))
            {            
                component.set("v.resultMessage",  $A.get("$Label.c.LABS_SF_Error_Message_for_Envoyer_une_convention"));
            }
            if( a.getReturnValue() != null && a.getReturnValue().StageName != $A.get("$Label.c.LABS_SF_Step_Cree") && a.getReturnValue().RecordType.Name == $A.get("$Label.c.LABS_SF_Reconventionnement")){
                component.set("v.resultMessage",  $A.get("$Label.c.LABS_SF_Error_Message_for_Envoyer_une_convention2"));
                
            }
            
            else{
                var action2 = component.get("c.getDocusignUrl");
                action2.setParams({
                    "SourceID":  a.getReturnValue().Id,
                    "CRL" : $A.get("$Label.c.LABS_SF_CRL_Attribute_for_Docusign"),
                    "CCRM" : 'Signataire~Signataire;Synerciel~Synerciel',
                    "CCTM" : 'Signataire~Signer;Synerciel~Signer',
                    "LA" : '0',
                    "LF" : '1'
                }); 
                action2.setCallback(this,function(response){
                    
                    component.set("v.docusignpageUrl",response.getReturnValue());
                    
                    var urlEvent = $A.get("e.force:navigateToURL");
                    urlEvent.setParams({                    
                        "url" : component.get("v.docusignpageUrl")          
                        
                    });
                    urlEvent.fire();
                    
                }); 
                $A.enqueueAction(action2);  
            }  
            
        });
        $A.enqueueAction(action);  
    }
    
})