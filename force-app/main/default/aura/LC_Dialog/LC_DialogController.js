({
	hide : function(component) {
		(component.find('modal') || component.getSuper().find('modal')).hide();
	},
	show : function(component) {
		(component.find('modal') || component.getSuper().find('modal')).show();
	}
})