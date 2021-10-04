({
	init: function(component, event, helper) {
        
        console.log(component.get("v.recordId"));
        
        var action = component.get("c.getAccountInfos");
        //action.setParams({ userId : component.get("v.recordId") });
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            console.log('response='+JSON.stringify(response));

            if (state === "SUCCESS") {
                var resp = response.getReturnValue();
                console.log('response=' + JSON.stringify(resp));
                
                var obj = JSON.parse(resp);
                console.log('pp=' + obj.proprietaire);
				console.log('rp=' + obj.reponsablePartenariat);
                
                component.set("v.proprietaire", obj.proprietaire);
                component.set("v.respPart", obj.reponsablePartenariat);
                var ownerMPh = component.get("v.proprietaire.MobilePhone");
                var ownerPh = component.get("v.proprietaire.Phone");
                var respMP = component.get("v.respPart.MobilePhone");

                if(ownerMPh != null) component.set("v.proprietaireMPH",'+33'+ownerMPh);
                if(ownerPh != null) component.set("v.proprietairePH",'+33'+ownerPh);
                if(respMP != null) component.set("v.respPartMPH",'+33'+respMP);

            }
            else if (state === "ERROR") {
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