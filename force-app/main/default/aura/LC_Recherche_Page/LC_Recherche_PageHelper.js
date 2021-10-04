({
	resetBasic: function(component) {
		component.set('v.search', {});
	},
	resetEtab: function(component) {
		component.set('v.searchEtab', {
			'typeRecherche':0
		});
	},
	resetAsso: function(component) {
		component.set('v.searchAsso', {});
	},
	handleSearch:function(component, helper){
		var isAdvencedSearch = component.get('v.isAdvencedSearch');
		var selectedSearch = component.get('v.selectedSearch');

		switch (true) {
			case !isAdvencedSearch:
				if(component.find("validBasic").every(function(cmp) {
					cmp.showHelpMessageIfInvalid();
					return cmp.get("v.validity").valid;
				})){
					helper.searchBasic(component, helper);
				}
				break;
			case isAdvencedSearch && selectedSearch === 'etablissement':
				var concatEtab = component.find("validEtab").reduce(function(obj, item){
					return obj + (item.get("v.value") === undefined || item.get("v.value") === null?'':item.get("v.value"));
				}, "");
				if(concatEtab.length !== 0){
					component.find("validEtab").forEach(function(item){
						item.setCustomValidity("");
						item.reportValidity();
					});
					helper.searchEtab(component, helper);
				}else{
					component.find("validEtab").forEach(function(item){
						item.setCustomValidity($A.get("$Label.c.Recherche_Erreur_remplir_au_moins_un_champ"));
						item.reportValidity();
					});
				}
				break;
			case isAdvencedSearch && selectedSearch === 'association':
				var concatAsso = component.find("validAsso").reduce(function(obj, item){
					return obj + (item.get("v.value") === undefined || item.get("v.value") === null?'':item.get("v.value"));
				}, "");
				if(concatAsso.length !== 0){
					component.find("validAsso").forEach(function(item){
						item.setCustomValidity("");
						item.reportValidity();
					});
					helper.searchAsso(component, helper);
				}else{
					component.find("validAsso").forEach(function(item){
						item.setCustomValidity($A.get("$Label.c.Recherche_Erreur_remplir_au_moins_un_champ"));
						item.reportValidity();
					});
				}
				break;
			default:
			break;
		}
	},
	searchBasic:function(component, helper) {
		var action = component.get("c.searchSimple");
		action.setParams(component.get("v.search"));
        action.setCallback(this, function(result) {
			var state = result.getState();
			component.set('v.isLoading', false);
			switch (state) {
				case 'SUCCESS':
					var values = result.getReturnValue();
					component.set("v.nbMatch", values.nbMatch);
					component.set("v.nbResult", values.nbResult);
					helper.handleResultEtablissement(component, values.results);
					break;
				default:
					helper.handleErrors(component, result.getError());
			}
		});
		component.set('v.isLoading', true);
        $A.enqueueAction(action);
	},
	searchEtab:function(component, helper) {
		var action = component.get("c.searchEtablissement");
		action.setParams(component.get("v.searchEtab"));
        action.setCallback(this, function(result) {
			var state = result.getState();
			component.set('v.isLoading', false);
			switch (state) {
				case 'SUCCESS':
					var values = result.getReturnValue();
					component.set("v.nbMatch", values.nbMatch);
					component.set("v.nbResult", values.nbResult);
					helper.handleResultEtablissement(component, values.results);
					break;
				default:
					helper.handleErrors(component, result.getError());
			}
		});
		component.set('v.isLoading', true);
        $A.enqueueAction(action);
	},
	searchAsso:function(component, helper) {
		var action = component.get("c.searchAssociation");
		action.setParams(component.get("v.searchAsso"));
        action.setCallback(this, function(result) {
			var state = result.getState();
			component.set('v.isLoading', false);
			switch (state) {
				case 'SUCCESS':
					var values = result.getReturnValue();
					component.set("v.nbMatch", values.nbMatch);
					component.set("v.nbResult", values.nbResult);
					helper.handleResultAssociation(component, values.results);
					break;
				default:
					helper.handleErrors(component, result.getError());
			}
		});
		component.set('v.isLoading', true);
        $A.enqueueAction(action);
	},
	handleResultEtablissement: function(component, results){
		if(component.get('v.typeRecherche') !== $A.get('$Label.c.Recherche_tablissements')){
			component.set('v.columns', [
				{label: $A.get('$Label.c.recherche_colonne_siret'), fieldName: 'siret', type: 'text', initialWidth:150},
				{label: $A.get('$Label.c.recherche_colonne_nom'), fieldName: 'raisonSociale', type: 'text'},
				{label: $A.get('$Label.c.recherche_colonne_adresse'), fieldName: 'address', type: 'text'},
				{label: $A.get('$Label.c.recherche_colonne_siege'), fieldName: 'siege', type: 'text', initialWidth:250},
				{label: $A.get('$Label.c.recherche_colonne_actif'), fieldName: 'actif', type: 'text', initialWidth:150},
				{type:  'button', initialWidth:200,
					typeAttributes:
					{
						iconName: 'utility:adduser',
						name: 'addEtab',
						label: component.get('v.buttonLabel'),
						variant: 'brand'
					}}
			]);
			component.set('v.typeRecherche', $A.get('$Label.c.Recherche_tablissements'));
		}

		var data = results.map(function(item){

			var adresseTab = [];
			if(item.rue){
				adresseTab.push(item.rue);
			}
			if(item.codePostal){
				adresseTab.push(item.codePostal);
			}
			if(item.ville){
				adresseTab.push(item.ville);
			}

			return {
				'siret': item.siret,
				'raisonSociale': item.raisonSociale,
				'address': adresseTab.join(' '),
				'siege': (item.siege ? $A.get('$Label.c.recherche_value_siege') : $A.get('$Label.c.recherche_value_etab')),
				'actif': (item.actif ? $A.get('$Label.c.recherche_value_actif') : $A.get('$Label.c.recherche_value_inactif'))
				};
		});
		component.set("v.data", data);
	},
	handleResultAssociation: function(component, results){
		if(component.get('v.typeRecherche') !== $A.get('$Label.c.Recherche_associations')){
			component.set('v.columns', [
				{label: $A.get('$Label.c.recherche_colonne_nra'), fieldName: 'siret', type: 'text', initialWidth:150},
				{label: $A.get('$Label.c.recherche_colonne_titre'), fieldName: 'titre', type: 'text'},
				{label: $A.get('$Label.c.recherche_colonne_adresse'), fieldName: 'address', type: 'text'},
				{label: $A.get('$Label.c.recherche_colonne_actif'), fieldName: 'actif', type: 'text', initialWidth:150},
				{type:  'button', initialWidth:200,
					typeAttributes:
					{
						iconName: 'utility:adduser',
						name: 'addAsso',
						label: component.get('v.buttonLabel'),
						variant: 'brand'
					}}
			]);
			component.set('v.typeRecherche', $A.get('$Label.c.Recherche_associations'));
		}

		var data = results.map(function(item){
			return {
				'siret': item.rna,
				'titre': item.titre,
				'address': item.adresse,
				'actif': item.etatLabel
				};
		});
		component.set("v.data", data);
	},
	checkDoublon: function(component, helper, siret){
		var action = component.get("c.findDoublon");
		action.setParams({
			'siret':siret,
			'sObjectName': component.get('v.sObjectName')
		});
        action.setCallback(this, function(result) {
			var state = result.getState();
			component.set('v.isLoading', false);
			switch (state) {
				case 'SUCCESS':
					component.set('v.siretSelected', siret);
					var values = result.getReturnValue();
					if(values.length > 0){
						helper.handleResultDoublon(component, values);
					}else{
						helper.createEtab(component, helper);
					}
					break;
				default:
					helper.handleErrors(component, result.getError());
			}
		});
		component.set('v.isLoading', true);
        $A.enqueueAction(action);
	},
	handleResultDoublon: function(component, results){
		var data = results.map(function(item){
			return {
				'id' : item.Id,
				'siret': item.SIRET__c,
				'raisonSociale': item.Raison_sociale__c,
				'address': ((item.Adresse__c || '') + ' ' + (item.Code_postal__c || '') + ' ' + (item.Ville__c || '')).trim(),
				'siege': item.Siege__c === 'Oui' ?$A.get('$Label.c.recherche_value_siege') : $A.get('$Label.c.recherche_value_etab'),
				'actif': item.Etablissement_actif__c === 'Oui' ? $A.get('$Label.c.recherche_value_actif') : $A.get('$Label.c.recherche_value_inactif')
				};
		});
		component.set("v.doublons", data);
		component.find('modalDoublon').show();
	},
	createEtab:function(component, helper){
		var action = component.get("c.createRecord");
		action.setParams({
			'siret':component.get('v.siretSelected'),
			'sObjectName': component.get('v.sObjectName')
		});
        action.setCallback(this, function(result) {
			var state = result.getState();
			component.set('v.isLoading', false);
			switch (state) {
				case 'SUCCESS':
					var id = result.getReturnValue();
					var navEvt = $A.get("e.force:navigateToSObject");
					if(navEvt){
						navEvt.setParams({
							"recordId": id
						});
						navEvt.fire();
					}else{
						location.href="/"+id;
					}
					break;
				default:
					helper.handleErrors(component, result.getError());
			}
		});
		component.set('v.isLoading', true);
        $A.enqueueAction(action);
	}

});