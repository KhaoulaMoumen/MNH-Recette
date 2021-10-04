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
                var action2 = component.get("c.SendNow");
                
                if(a.getReturnValue().RecordTypeId == $A.get("$Label.c.LABS_SF_Offre_PEE") && a.getReturnValue().Avancement_du_dossier__c == $A.get("$Label.c.LABS_SF_Envoi_du_Contrat")) 
                {
                    console.log('1');
                    action2.setParams({
                        "offreID":  component.get('v.recordId'),
                        "signatureQualif" : false
                    }); 
                }
                if(a.getReturnValue().RecordTypeId == $A.get("$Label.c.LABS_SF_Coup_de_Pouce")) 
                {
                    console.log('2');
                    action2.setParams({
                        "offreID":  component.get('v.recordId'),
                        "signatureQualif" : true
                    }); 
                }
                
                action2.setCallback(this,function(response){
                    
                    component.set("v.resultMessage", response.getReturnValue());
                }); 
                $A.enqueueAction(action2);  
                
                window.setTimeout(
                    $A.getCallback(function() {
                        var dismissActionPanel = $A.get("e.force:closeQuickAction");
                        dismissActionPanel.fire();
                    }), 8000
                );
            }  
            
        });
        $A.enqueueAction(action);  
    }
    
})