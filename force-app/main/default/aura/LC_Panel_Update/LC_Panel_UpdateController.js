({
	openUpdateModal : function(component) {
		$A.createComponent(
            "c:LC_Action_Update",
            {
                "recordId": component.get("v.recordId"),
                "sObjectName": component.get("v.sObjectName")
            },
            function(quickAction, status){
                //Add the new button to the body array
                if (status === "SUCCESS") {
					var modal = component.find("modal");
					quickAction.addEventHandler("closeModal", component.getReference("c.cleanModal"));
					modal.set('v.body', [quickAction] );
					modal.show();
                } else if (status === "INCOMPLETE") {
                } else if (status === "ERROR") {
                }
            }
        );
	},
	cleanModal : function(component){
		var modal = component.find("modal");
		modal.set('v.body', []);
		modal.hide();
	}
})