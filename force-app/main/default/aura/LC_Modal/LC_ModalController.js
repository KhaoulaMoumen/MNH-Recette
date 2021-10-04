({
	init : function(component) {
		var newValue = component.get("v.size");
		// Refactor
		var modal = component.find("modal");

		if (newValue === "large") {
			$A.util.addClass(modal, "slds-modal_large");
			$A.util.removeClass(modal, "slds-modal_medium");

		} else if (newValue === "medium") {
			$A.util.removeClass(modal, "slds-modal_large");
			$A.util.addClass(modal, "slds-modal_medium");
		} else {
			$A.util.removeClass(modal, "slds-modal_medium");
			$A.util.addClass(modal, "slds-modal_small");
		}
    },
	handleSizeChange : function(component, event) {
		var newValue = event.getParam("value");
		// Refactor
		var modal = component.find("modal");

		if (newValue === "large") {
			$A.util.addClass(modal, "slds-modal_large");
			$A.util.removeClass(modal, "slds-modal_medium");
		} else {
			$A.util.removeClass(modal, "slds-modal_large");
			$A.util.addClass(modal, "slds-modal_medium");
		}
    },
    show : function(component) {
        var modal = component.find("modal");
        $A.util.addClass(modal, "slds-fade-in-open");

        var backdrop = component.find("backdrop");
        $A.util.addClass(backdrop, "slds-backdrop_open");

    },
    hide : function(component) {

		var modal = component.find("modal");
		$A.util.removeClass(modal, "slds-fade-in-open");

        var backdrop = component.find("backdrop");
		$A.util.removeClass(backdrop, "slds-backdrop_open");
	}
})