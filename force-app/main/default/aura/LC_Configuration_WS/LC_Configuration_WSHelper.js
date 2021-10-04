({
	getConfigBundle : function(component, helper) {
		var action = component.get("c.getConfiguration");
        action.setCallback(this, function(result) {
			var state = result.getState();
			switch (state) {
				case 'SUCCESS':
					var values = result.getReturnValue();
					component.set("v.refClientReadOnly", values.refClient);
					component.set("v.loginReadOnly", values.login);
					component.set("v.passwordReadOnly", values.password);
					helper.resetConfig(component);
					break;
				default:
				helper.handleErrors(result.getError());
			}
        });
        $A.enqueueAction(action);
	},
	saveConfig : function(component, helper){

		var action = component.get("c.setConfiguration");
		action.setParams({
			'refClient':component.get("v.refClient"),
			'login':component.get("v.login"),
			'password':component.get("v.password")
		});
        action.setCallback(this, function(result) {
			var state = result.getState();
			switch (state) {
				case 'SUCCESS':
					helper.getConfigBundle(component, helper);
					component.find("modal").hide();
					helper.handleSaveSuccess(component);
					break;
				default:
					helper.handleErrors(component, result.getError());
			}
        });
        $A.enqueueAction(action);

	},
	resetConfig : function(component) {
		component.set("v.refClient", component.get("v.refClientReadOnly"));
		component.set("v.login", component.get("v.loginReadOnly"));
		component.set("v.password", '');
	}
});