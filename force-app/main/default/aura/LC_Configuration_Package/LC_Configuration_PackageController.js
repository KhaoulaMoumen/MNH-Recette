({
	init : function(component, event, helper) {
		helper.getPackageBundle(component, helper);
		helper.resetPackage(component, helper);
	},
	openEditModal : function(component) {
		component.find("modal").show();
	},
	handleSave : function(component, event, helper) {
		helper.saveConfig(component, helper);
	},
	handleCancel : function(component, event, helper) {
		helper.resetPackage(component, helper);
		component.find("modal").hide();
	}
})