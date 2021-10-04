({
	getPackageBundle : function(component, helper) {
		var action = component.get("c.getPackageConf");
        action.setCallback(this, function(result) {
			var state = result.getState();
			switch (state) {
				case 'SUCCESS':
					var values = result.getReturnValue();
					component.set("v.nbResultReadOnly", values.nbResult || 20);
					component.set("v.synchroReadOnly", values.synchro);
					component.set("v.synchro_dirigeantReadOnly", values.synchro_dirigeant);
					component.set("v.synchro_participationReadOnly", values.synchro_participation);
					component.set("v.synchro_actionaireReadOnly", values.synchro_actionaire);

					helper.resetPackage(component);
					break;
				default:
					helper.handleErrors(result.getError());
			}
        });
        $A.enqueueAction(action);
	},
	saveConfig : function(component, helper){
		var action = component.get("c.setPackageConf");
		var params = {
			'nbResult':component.get("v.nbResult"),
			'synchroJSON': JSON.stringify(component.get("v.synchro")),
			'synchro_dirigeantJSON': JSON.stringify(component.get("v.synchro_dirigeant")),
			'synchro_participationJSON': JSON.stringify(component.get("v.synchro_participation")),
			'synchro_actionaireJSON': JSON.stringify(component.get("v.synchro_actionaire"))
		};
		action.setParams(params);
        action.setCallback(this, function(result) {
			var state = result.getState();
			switch (state) {
				case 'SUCCESS':
					helper.setPackage(component, helper);
					component.find("modal").hide();
					helper.handleSaveSuccess(component);
					break;
				default:
					helper.handleErrors(component, result.getError());
			}
        });
        $A.enqueueAction(action);
	},
	resetPackage : function(component) {
		component.set("v.nbResult", component.get("v.nbResultReadOnly"));
		component.set("v.synchro", component.get("v.synchroReadOnly"));
		component.set("v.synchro_dirigeant", component.get("v.synchro_dirigeantReadOnly"));
		component.set("v.synchro_participation", component.get("v.synchro_participationReadOnly"));
		component.set("v.synchro_actionaire", component.get("v.synchro_actionaireReadOnly"));
	},
	setPackage : function(component) {
		component.set("v.nbResultReadOnly", component.get("v.nbResult"));
		component.set("v.synchroReadOnly", component.get("v.synchro"));
		component.set("v.synchro_dirigeantReadOnly", component.get("v.synchro_dirigeant"));
		component.set("v.synchro_participationReadOnly", component.get("v.synchro_participation"));
		component.set("v.synchro_actionaireReadOnly", component.get("v.synchro_actionaire"));
	}
})