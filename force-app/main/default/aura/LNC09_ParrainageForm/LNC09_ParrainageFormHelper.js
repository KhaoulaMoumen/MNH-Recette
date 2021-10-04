({
	
    launchFlow : function(component, event, helper) {
        console.log('start');
        console.log(component.get("v.username"));
        var action = component.get("c.launchFlowParrainage");
        action.setParams({
            "userID" : component.get("v.currentUser.Id"),
            "parrainage" : component.get("v.parrainage"),
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                if(result == 'success'){
                    component.set("v.showForm", "false");
                    component.set("v.showError", "false");
                    component.set("v.showSuccess", "true");
                    window.scrollTo(0, 0);
                }                 
                else if (result == 'error'){
                    component.set("v.showForm", "false");
                    component.set("v.showError", "true");
                    component.set("v.showSuccess", "false");
                    window.scrollTo(0, 0);
                }
            } 
            else if (state === "INCOMPLETE") {
               		component.set("v.showForm", "false");
                    component.set("v.showError", "true");
                    component.set("v.showSuccess", "false");
            }
                else if (state === "ERROR") {
                    
                    component.set("v.showForm", "false");
                    component.set("v.showError", "true");
                    component.set("v.showSuccess", "false");
                    
                    var errors = response.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            console.log("Error message: " + 
                                        errors[0].message);
                        }
                    } else {
                        console.log("Unknown error");
                    }
                }
        });
        $A.enqueueAction(action);
    },
})