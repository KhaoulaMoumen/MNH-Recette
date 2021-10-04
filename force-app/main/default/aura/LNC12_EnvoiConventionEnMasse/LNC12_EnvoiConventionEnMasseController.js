({

    doInit : function (cmp){
        var action = cmp.get("c.executeBatchJob");
        action.setCallback(this, function(response) {
            var state = response.getState();
            
            if (state === "SUCCESS") {
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "type": "success",
                    "title": "Success!",
                    "message": "Le batch a été lancé. Un email sera envoyé dès qu'il aura fini."
                });
                toastEvent.fire();
                $A.get("e.force:closeQuickAction").fire();
            }      
            else if (state === "ERROR") {
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "type": "error",
                    "title": "Error!",
                    "message": "Une erreur s'est produite lors du lancement du batch de l'envoi en masse des conventions"
                });
                toastEvent.fire();
                $A.get("e.force:closeQuickAction").fire();
            }
        });
        $A.enqueueAction(action);
    }


});