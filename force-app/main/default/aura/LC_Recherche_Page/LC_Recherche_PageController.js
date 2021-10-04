({
	init : function(component, event, helper) {
		var myPageRef = component.get("v.pageReference");
		if(myPageRef && myPageRef.state.sObjectName !== undefined){
			component.set('v.sObjectName', myPageRef.state.sObjectName);
		}

		var titleLabel = {
			'Account':$A.get("$Label.c.Recherche_de_Account"),
			'Lead':$A.get("$Label.c.Recherche_de_Lead")
		};
		component.set('v.title', titleLabel[component.get('v.sObjectName')]);

		component.set('v.typeRechercheOptions', [
			{'label': $A.get('$Label.c.Recherche_type_0'), 'value': 0},
			{'label': $A.get('$Label.c.Recherche_type_1'), 'value': 1},
			{'label': $A.get('$Label.c.Recherche_type_2'), 'value': 2},
			{'label': $A.get('$Label.c.Recherche_type_3'), 'value': 3}]);

		var buttonLabel = {
			'Account':$A.get("$Label.c.Recherche_Ajouter_Account"),
			'Lead':$A.get("$Label.c.Recherche_Ajouter_Lead")
		};
		component.set('v.buttonLabel', buttonLabel[component.get('v.sObjectName')]);

		var doublonLabel = {
			'Account': $A.get("$Label.c.Recherche_Doublon_Account"),
			'Lead': $A.get("$Label.c.Recherche_Doublon_Lead")
		};
		component.set('v.titleDoublon', doublonLabel[component.get('v.sObjectName')]);

		component.set('v.columnsDoublon', [
			{label: $A.get('$Label.c.recherche_colonne_siret'), fieldName: 'siret', type: 'text', initialWidth:150},
			{label: $A.get('$Label.c.recherche_colonne_nom'), fieldName: 'raisonSociale', type: 'text'},
			{label: $A.get('$Label.c.recherche_colonne_adresse'), fieldName: 'address', type: 'text'},
			{label: $A.get('$Label.c.recherche_colonne_siege'), fieldName: 'siege', type: 'text', initialWidth:250},
			{label: $A.get('$Label.c.recherche_colonne_actif'), fieldName: 'actif', type: 'text', initialWidth:150},
			{type:  'button', initialWidth:200,
				typeAttributes:
				{
					iconName: 'utility:forward',
					name: 'showEtab',
					label: $A.get('$Label.c.Recherche_voir'),
					variant: 'brand'
				}}
		]);

		component.find('modalDoublon').set('v.size', 'large');

		helper.resetBasic(component);
		helper.resetEtab(component);
		helper.resetAsso(component);
	},
	handleReset: function(component, event, helper) {
		var isAdvencedSearch = component.get('v.isAdvencedSearch');
		var selectedSearch = component.get('v.selectedSearch');

		switch (true) {
			case !isAdvencedSearch:
				helper.resetBasic(component);
				break;
			case isAdvencedSearch && selectedSearch === 'etablissement':
				helper.resetEtab(component);
				break;
			case isAdvencedSearch && selectedSearch === 'association':
				helper.resetAsso(component);
				break;
			default:
		}
	},
	keyCheck: function(component, event, helper) {
		if(event.keyCode === 13){
			helper.handleSearch(component, helper);
		}
	},
	handleSearch: function(component, event, helper) {
		helper.handleSearch(component, helper);
	},
	handleRowAction:function(component, event, helper){
		var action = event.getParam('action');
		var row = event.getParam('row');
		switch (action.name) {
			case 'addEtab':
				helper.checkDoublon(component, helper, row.siret);
				break;
			case 'addAsso':
				break;
			case 'showEtab':
				var navEvt = $A.get("e.force:navigateToSObject");
				navEvt.setParams({
					"recordId": row.id,
					"slideDevName": "detail"
				});
				navEvt.fire();
				break;
			default:
		}
	},
	handleCancelDoublon:function(component){
		component.set("v.doublons", []);
		component.find('modalDoublon').hide();
	},
	handleSaveDoublon:function(component, event, helper){
		component.set("v.doublons", []);
		component.find('modalDoublon').hide();
		helper.createEtab(component, helper);
	}
})