({
	refreshRecord: function(component, helper){
		component.set('v.isLoading', true);
		var action = component.get("c.updateRecord");
		action.setParams({
			'recordId': component.get("v.recordId"),
			'sObjectName': component.get("v.sObjectName")
		});
        action.setCallback(this, function(result) {
			var state = result.getState();
			switch (state) {
				case 'SUCCESS':
					helper.handleSaveSuccess(component, $A.get("$Label.c.Action_Update_Success"));
					if($A.get('e.force:refreshView')){
						$A.get('e.force:refreshView').fire();
					}else{
						location.href='/'+component.get("v.recordId");
					}
					break;
				default:
					helper.handleErrors(component, result.getError());
			}
			if($A.get("e.force:closeQuickAction")){
				$A.get("e.force:closeQuickAction").fire();
			} else {
				component.getEvent("closeModal").fire();
			}
		});
        $A.enqueueAction(action);
	}
});