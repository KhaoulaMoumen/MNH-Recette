({
	addToast : function(component, event, helper) {
		var toasts = component.get("v.toasts");
		var toast = {};
		var params = event.getParam('arguments') || event.getParams();
		toast.message = params.message;
		toast.type = params.type || 'info';
		toast.duration = params.duration || 5000;
		toast.key = helper.uuid();
		toasts.push(toast);
		component.set("v.toasts", toasts);
		setTimeout(function(){
			helper.removeToast(component, toast.key);
		}, toast.duration);

	},
	closeToast: function(component, event, helper) {
		var key = event.getSource().get("v.name");
		helper.removeToast(component, key);
	}
})