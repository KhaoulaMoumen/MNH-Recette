({
	uuid : function() {
		 return Math.random().toString(36).substring(2, 15) + Math.random().toString(36).substring(2, 15);
	},
	removeToast: function(component, key){
		var toasts = component.get("v.toasts");
		if(toasts && toasts.length > 0){
			var index = this.findIndexByKey(toasts, key);
			if( index === null ) {
				return;
			}
			toasts.splice(index, 1);
			component.set("v.toasts", toasts);
		}
	},
	findIndexByKey: function(list, key){
		var idx = null;
		for (var index = 0; index < list.length; index+=1) {
			if (list[index].key === key){
				idx = index;
				break;
			}
		}
		return idx;
	}
})