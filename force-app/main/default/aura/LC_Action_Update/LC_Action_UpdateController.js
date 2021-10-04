({
	saveClick : function(component, event, helper) {
		helper.refreshRecord(component, helper);
	},
	cancelClick : function(component, event, helper) {
		$A.get("e.force:closeQuickAction").fire();
	}
});