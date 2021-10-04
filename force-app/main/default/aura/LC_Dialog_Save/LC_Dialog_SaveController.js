({
	handleSaveClick : function(component) {
		component.getEvent("onSave").fire();
	},
	handleCancelClick : function(component) {
		component.getEvent("onCancel").fire();
	}
})