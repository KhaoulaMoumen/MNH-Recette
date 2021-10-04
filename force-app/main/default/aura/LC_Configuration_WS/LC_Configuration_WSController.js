({
	init : function(component, event, helper) {
		helper.getConfigBundle(component, helper);
		helper.resetConfig(component, helper);
	},
	openEditModal : function(component) {
		component.find("modal").show();
	},
	handleSave : function(component, event, helper) {

		var formValid = component.find('form').get('v.body').every(function(cmp){
			cmp.showHelpMessageIfInvalid();
			return cmp.get("v.validity").valid;
		});

		if(formValid){
			helper.saveConfig(component, helper);
		}
	},
	handleCancel : function(component, event, helper) {
		helper.resetConfig(component, helper);
		component.find("modal").hide();
	}
})