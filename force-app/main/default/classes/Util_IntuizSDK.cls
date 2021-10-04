public with sharing class Util_IntuizSDK {

	private String identification;
	private String refClient;
	private Integer nbElt;

	public Util_IntuizSDK(){
		if (!Util_CrudFLS.isAccessible('Altares_Configuration__c', new List<String>{
				'Login__c', 'Mot_de_passe__c','Reference_client__c' , 'Nombre_de_resultat__c'
		})){
			throw new AuraHandledException(Label.Erreur_Permissions_insuffisante);
		}

		Map<String,String> mapConfig = new Map<String,String>();
		
		Altares_Configuration__c config = Altares_Configuration__c.getOrgDefaults();

		if(String.isBlank(config.Login__c) || String.isBlank(config.Reference_client__c) || String.isBlank(config.Mot_de_passe__c)){
			throw new AuraHandledException(Label.Erreur_Identifiant_incomplet);
		}

		this.refClient = config.Reference_client__c;
		this.nbElt = Integer.valueOf(config.Nombre_de_resultat__c);
		if(this.nbElt == null)
			this.nbElt = 20;
		
		this.identification = config.Login__c + '|' + EncodingUtil.convertToHex(Crypto.generateDigest('SHA1',Blob.valueOf(config.Mot_de_passe__c)));

		System.debug(this);
	}

	public API_responseCallistoAltares.RechercheSimpleResponse doRechercheSimple(String qui, String ou) {
		
		API_serviceCallistoAltares.CallistoIdentiteSecureHttpsSoap11Endpoint client = new API_serviceCallistoAltares.CallistoIdentiteSecureHttpsSoap11Endpoint();

		API_requestCallistoAltares.RechercheSimpleRequest request = new API_requestCallistoAltares.RechercheSimpleRequest();
		request.identification = this.identification;
		request.refClient = this.refClient;
		request.qui = qui;
		request.ou = ou;
		request.nbElt = this.nbElt;
		request.elargie = true;
		request.rechercheSiege = false;
		request.rechercheActif = false;
		request.debutResultat = (Integer) 0;
		request.contexteRecherche = '';
		request.categorieItemId = '';
		request.categorieItemADeselectionner = false;

		API_responseCallistoAltares.RechercheSimpleResponse response = client.doRechercheSimple(request);
        system.debug(response.exception_x);
		
		if(!response.correct){
			throw new AuraHandledException(response.exception_x.erreur + ' | ' + response.exception_x.description);
		}else{
			return response;
		}
	}

	public API_responseCallistoAltares.RechercheAssociationResponse doRechercheAssociation(String titre, String rna, String departement) {
		
		API_serviceCallistoAltares.CallistoIdentiteSecureHttpsSoap11Endpoint client = new API_serviceCallistoAltares.CallistoIdentiteSecureHttpsSoap11Endpoint();

		API_requestCallistoAltares.RechercheAssociationRequest request = new API_requestCallistoAltares.RechercheAssociationRequest();
		request.identification = this.identification;
		request.refClient = this.refClient;
		request.rna = rna;
		request.titre = titre;
		request.nbElt = this.nbElt;
		request.departement = departement;
		request.debutResultat = (Integer) 0;
		request.theme = '';
		request.objet = '';
		request.contexteRecherche = '';
		request.categorieItemId = '';
		request.categorieItemADeselectionner = false;

		API_responseCallistoAltares.RechercheAssociationResponse response = client.doRechercheAssociation(request);
		
		if(!response.correct){
			throw new AuraHandledException(response.exception_x.erreur);
		}else{
			return response;
		}
	}

	public API_responseCallistoAltares.RechercheEntrepriseResponse doRechercheEntreprise(Integer typeRecherche, String raisonSociale, String siren, String siret, String enseigne, String rcs,String rue, String ville, String codePostal ) {
		
		API_serviceCallistoAltares.CallistoIdentiteSecureHttpsSoap11Endpoint client = new API_serviceCallistoAltares.CallistoIdentiteSecureHttpsSoap11Endpoint();

		API_requestCallistoAltares.RechercheEntrepriseRequest request = new API_requestCallistoAltares.RechercheEntrepriseRequest();
		request.identification = this.identification;
		request.refClient = this.refClient;
		request.nbElt = this.nbElt;
		request.raisonSociale = raisonSociale;
		request.siren = siren;
		request.siret = siret;
		request.enseigne = enseigne;
		request.rcs = rcs;
		request.rue = rue;
		request.ville = ville;
		request.codePostal = codePostal;
		request.typeRecherche = typeRecherche;
		request.sigle = '';
		request.telephone = '';
		request.naf = '';
		request.ft = '';
		request.contexteRecherche = '';
		request.statutEirl = '';
		request.categorieItemId = '';
		request.duns = '';
		request.formeJuridique = '';
		request.rechercheSiege = false;
		request.rechercheActif = false;
		request.categorieItemADeselectionner = false;
		request.debutResultat = 0;

		API_responseCallistoAltares.RechercheEntrepriseResponse response = client.doRechercheEntreprise(request);
		
		if(!response.correct){
			throw new AuraHandledException(response.exception_x.erreur);
		}else{
			return response;
		}
	}

	//ajout d'une methode invocable dans la classe LCCTRL_Action_Update
	public Id upsertRecord(String sObjectName,String siret, Id recordId){
		
		sObject record = upsertRecord(sObjectName,siret,recordId, false).get(sObjectName)[0];

		return record.id;
	}	


	public Map<String,List<sObject>> upsertRecord(String sObjectName,String siret, Id recordId, boolean byBatch){

		Map<String,List<sObject>> recordsByObjType = new Map<String,List<sObject>>();

		if(!Util_CrudFLS.isUpsertable(sObjectName, new List<String>{
			'Adresse__c',
			'Capital_social__c',
			'Chiffre_d_affaire__c',
			'Code_forme_juridique__c',
			'Code_NAF_entreprise__c',
			'Code_NAF_etablissement__c',
			'Code_postal__c',
			'Complement_adresse__c',
			'Date_creation_entreprise__c',
			'Date_creation_etablissement__c',
			'Derniere_mise_jour_Altares__c',
			'Effectif_entreprise__c',
			'Effectif_etablissement__c',
			'Encours_preconise__c',
			'Enseigne__c',
			'Entreprise_active__c',
			'Etablissement_actif__c',
			'Forme_Juridique_Alt__c',
			'Libelle_code_NAF_entreprise__c',
			'Libelle_code_NAF_etab__c',
			'Moyenne_Score_secteur__c',
			'Niveau_de_risque__c',
			'Procedure_collective__c',
			'Raison_sociale__c',
			'Raison_sociale_tete_groupe__c',
			'Score_sur_20__c',
			'SIREN_Alt__c',
			'Siren_tete_de_groupe__c',
			'sirenSiret__c',
			'Siege__c',
			'Telephone__c',
			'Ville__c',
			'DUNS_Etablissement__c',
			'DUNS_Siege__c',
			'No_TVA__c',
			'succSiret__c'
		})){
			throw new AuraHandledException(Label.Erreur_Permissions_insuffisante);
		}

		String[] fieldDirigeant = new List<String>{
			'Name',
			'Compte__c',
			'Fonction__c',
			'Genre__c',
			'Piste__c',
			'Prenom__c',
			'Raison_sociale_dirigeant__c',
			'Order__c'
		};

		if(!Util_CrudFLS.isFullRight('Dirigeant_et_decideur__c', fieldDirigeant)){
			throw new AuraHandledException(Label.Erreur_Permissions_insuffisante);
		}

		String[] fieldActionaire = new List<String>{
			'Name',
			'Compte__c',
			'Piste__c',
			'Type__c',
			'Pays__c',
			'Pourcentage__c',
			'SIREN_Alt__c'
		};

		if(!Util_CrudFLS.isFullRight('Actionnaire__c',fieldActionaire)){
			throw new AuraHandledException(Label.Erreur_Permissions_insuffisante);
		}

		String[] fieldParticipation = new List<String>{
			'Name',
			'Compte__c',
			'Piste__c',
			'Type__c',
			'Pays__c',
			'Pourcentage__c',
			'SIREN_Alt__c'
		};

		if(!Util_CrudFLS.isFullRight('Participation__c', fieldParticipation)){
			throw new AuraHandledException(Label.Erreur_Permissions_insuffisante);
		}


		if(sObjectName == 'Account'){
			if(!Util_CrudFLS.isUpsertable(sObjectName, new List<String>{'Name','BillingStreet','BillingPostalCode','BillingCity'})){
				throw new AuraHandledException(Label.Erreur_Permissions_insuffisante);
			}
		}

		if(sObjectName == 'Lead'){
			if(!Util_CrudFLS.isUpsertable(sObjectName, new List<String>{'LastName','Company','Street','PostalCode','City'})){
				throw new AuraHandledException(Label.Erreur_Permissions_insuffisante);
			}
		}

		Schema.SObjectType targetType = Schema.getGlobalDescribe().get(sObjectName);
		targetType.newSObject();

		Dirigeant_et_decideur__c[] dirigeants = new List<Dirigeant_et_decideur__c>();
		Actionnaire__c[] actionaires = new List<Actionnaire__c>();
		Participation__c[] participations = new List<Participation__c>();
		
		Dirigeant_et_decideur__c[] dirigeantsNew = new List<Dirigeant_et_decideur__c>();
		Actionnaire__c[] actionairesNew = new List<Actionnaire__c>();
		Participation__c[] participationsNew = new List<Participation__c>();

		Dirigeant_et_decideur__c[] dirigeantsDel = new List<Dirigeant_et_decideur__c>();
		Actionnaire__c[] actionairesDel = new List<Actionnaire__c>();
		Participation__c[] participationsDel = new List<Participation__c>();

		sObject record = targetType.newSObject();
		record.Id = recordId;

		String nomRelation = (sObjectName == 'Account')?'Compte__c':'Piste__c';

		if(recordId != null){
			dirigeants = (Dirigeant_et_decideur__c[])  Database.query('SELECT '+ String.join(fieldDirigeant,' , ') +' From Dirigeant_et_decideur__c WHERE '+nomRelation+' = :recordId');
			actionaires = (Actionnaire__c[])  Database.query('SELECT '+ String.join(fieldActionaire,' , ') +' From Actionnaire__c WHERE '+nomRelation+' = :recordId');
			participations = (Participation__c[])  Database.query('SELECT '+ String.join(fieldParticipation,' , ') +' From Participation__c WHERE '+nomRelation+' = :recordId');
		}

		Map<String,Dirigeant_et_decideur__c> dirigeantsMap = new Map<String,Dirigeant_et_decideur__c>();
		Map<String,Actionnaire__c> actionairesMap = new Map<String,Actionnaire__c>();
		Map<String,Participation__c> participationsMap = new Map<String,Participation__c>();

		for (Dirigeant_et_decideur__c item : dirigeants) {
			String key = item.Name+'|'+item.Prenom__c+'|'+item.Fonction__c;
			if(!dirigeantsMap.containsKey(key))
		  		dirigeantsMap.put(key,item);
			else
				dirigeantsDel.add(item);
		}

		for (Actionnaire__c item : actionaires) {	
		   	String key = item.SIREN_Alt__c+'|'+item.Name;
			if(!actionairesMap.containsKey(key))
		  		actionairesMap.put(key,item);
			else
				actionairesDel.add(item);
		}

		for (Participation__c item : participations) {
		    String key = item.SIREN_Alt__c+'|'+item.Name;
			if(!participationsMap.containsKey(key))
		  		participationsMap.put(key,item);
			else
				participationsDel.add(item);
		}
		  

		API_serviceCallistoAltares.CallistoAlerteObjectHttpSoap11Endpoint AlertClient = new API_serviceCallistoAltares.CallistoAlerteObjectHttpSoap11Endpoint();

		//getIdentiteAltaN4Etablissement
		API_voCallistoAltares.IdentiteAltaN4EtablissementInfo etabInfo = getIdentiteAltaN4Etablissement(siret);

		if(etabInfo != null){
		
			Util_CURules.getInstance().synchro(record,'Raison_sociale__c',etabInfo.raisonSociale);
			Util_CURules.getInstance().synchro(record,'SIRET__c',etabInfo.siret);
			Util_CURules.getInstance().synchro(record,'Telephone__c',(String.isBlank(etabInfo.telephone))?'':'+33'+etabInfo.telephone.removeStart('0'));
			Util_CURules.getInstance().synchro(record,'Siege__c',etabInfo.siege?'Oui':'Non');
			Util_CURules.getInstance().synchro(record,'Code_NAF_etablissement__c',etabInfo.Naf5Code);
			Util_CURules.getInstance().synchro(record,'Libelle_code_NAF_etab__c',etabInfo.Naf5Libelle);
			Util_CURules.getInstance().synchro(record,'Etablissement_actif__c',etabInfo.actif?'Oui':'Non');
			Util_CURules.getInstance().synchro(record,'Date_creation_etablissement__c',etabInfo.dateCreation);
			Util_CURules.getInstance().synchro(record,'Effectif_etablissement__c',etabInfo.trEffectifEtab);

			Util_CURules.getInstance().synchro(record,'Adresse__c',etabInfo.rue);
			Util_CURules.getInstance().synchro(record,'Complement_adresse__c',etabInfo.complementRue);

			Util_CURules.getInstance().synchro(record,'Code_postal__c',etabInfo.codePostal);
			Util_CURules.getInstance().synchro(record,'Ville__c',etabInfo.ville);
			Util_CURules.getInstance().synchro(record,'Enseigne__c',etabInfo.enseigne);

			Util_CURules.getInstance().synchro(record,'DUNS_Etablissement__c',etabInfo.duns);
			Util_CURules.getInstance().synchro(record,'succSiret__c',etabInfo.succSiret);
			
			String[] streetTab = new List<String>();

			if(!String.isBlank(etabInfo.rue)){
				streetTab.add(etabInfo.rue);
			}

			if(!String.isBlank(etabInfo.complementRue)){
				streetTab.add(etabInfo.complementRue);
			}

			String street = String.join(streetTab,'\n');

			if(sObjectName == 'Account'){
				
				Util_CURules.getInstance().synchro(record,'Name',etabInfo.raisonSociale);
				Util_CURules.getInstance().synchro(record,'BillingStreet',street);
				Util_CURules.getInstance().synchro(record,'BillingPostalCode',etabInfo.codePostal);
				Util_CURules.getInstance().synchro(record,'BillingCity',etabInfo.ville);
			}

			if(sObjectName == 'Lead'){
				Util_CURules.getInstance().synchro(record,'LastName',etabInfo.raisonSociale);
				Util_CURules.getInstance().synchro(record,'Company',etabInfo.raisonSociale);
				Util_CURules.getInstance().synchro(record,'Street',street);
				Util_CURules.getInstance().synchro(record,'PostalCode',etabInfo.codePostal);
				Util_CURules.getInstance().synchro(record,'City',etabInfo.ville);
			}
		}

		//getIdentiteAltaN4Entreprise
		API_voCallistoAltares.IdentiteAltaN4EntrepriseInfo entreInfo = getIdentiteAltaN4Entreprise(siret);

		if(entreInfo != null){
			Util_CURules.getInstance().synchro(record,'SIREN_Alt__c',entreInfo.siret.left(9));
			Util_CURules.getInstance().synchro(record,'Capital_social__c',entreInfo.capital);
			Util_CURules.getInstance().synchro(record,'Chiffre_d_affaire__c',entreInfo.chiffreAffaire);
			Util_CURules.getInstance().synchro(record,'Effectif_entreprise__c',entreInfo.trEffectifEntre);
			Util_CURules.getInstance().synchro(record,'Code_NAF_entreprise__c',entreInfo.naf5EntreCode);
			Util_CURules.getInstance().synchro(record,'Libelle_code_NAF_entreprise__c',entreInfo.naf5EntreLibelle);
			Util_CURules.getInstance().synchro(record,'Forme_Juridique_Alt__c',entreInfo.formeJuridique);
			Util_CURules.getInstance().synchro(record,'Code_forme_juridique__c',entreInfo.formeJuridique);
			Util_CURules.getInstance().synchro(record,'Procedure_collective__c',entreInfo.procedureCollective);
			Util_CURules.getInstance().synchro(record,'Entreprise_active__c',entreInfo.etat == '1'?'Oui':'Non');//TOCHECK
			Util_CURules.getInstance().synchro(record,'Date_creation_entreprise__c',entreInfo.dateCreation);
			Util_CURules.getInstance().synchro(record,'DUNS_Siege__c',entreInfo.dunsSiege);
			Util_CURules.getInstance().synchro(record,'No_TVA__c',entreInfo.numTVAIntraCom);
		}

		
		//getScore
		API_voCallistoAltares.ScoreInfo scoreinfo =  getScore(siret);

		if(scoreinfo != null){
			Util_CURules.getInstance().synchro(record,'Score_sur_20__c',scoreinfo.scoreVingt);
			Util_CURules.getInstance().synchro(record,'Moyenne_Score_secteur__c',scoreinfo.scoreSectorielVingt);
			Util_CURules.getInstance().synchro(record,'Encours_preconise__c',scoreinfo.encours);
			Util_CURules.getInstance().synchro(record,'Niveau_de_risque__c',scoreinfo.niveauRisque);
		}

		
		//getLiensCapitalistiques
		API_voCallistoAltares.LiensCapitalistiquesInfo lienCapInfo =  getLiensCapitalistiques(siret);

		if(lienCapInfo != null){
			Util_CURules.getInstance().synchro(record,'Raison_sociale_tete_groupe__c',lienCapInfo.raisonSocialeTeteGroupe25);
			Util_CURules.getInstance().synchro(record,'Siren_tete_de_groupe__c',lienCapInfo.sirenTeteGroupe25);
		}


		//getListeDecideurs
		API_voCallistoAltares.DecideurInfo[] decideurInfos = getListeDecideurs(siret);


		//getListeDirigeantsStatutaires
		API_voCallistoAltares.DirigeantsStatutaireInfo dirigeanInfo = getListeDirigeantsStatutaires(siret);

		record.put('Derniere_mise_jour_Altares__c',Datetime.now());

		setPortfolioItem(siret);
		if (!byBatch) {
			Database.UpsertResult upsertRes = Database.upsert(record);
		}
		recordsByObjType.put(sObjectName,new List<sObject>{record} );

		if(lienCapInfo != null){
			System.debug('actionaire');
			if(lienCapInfo.actionnairesList != null)
			for (API_lienVoCallistoAltares.Actionnaire item : lienCapInfo.actionnairesList) {
				System.debug(item);
				if(!String.isBlank(item.raisonSociale)){
					Actionnaire__c sObj = actionairesMap.get(item.siren+'|'+item.raisonSociale);
					if(sObj == null)
						sObj = new Actionnaire__c();
					else
						actionairesMap.remove(item.siren+'|'+item.raisonSociale);
					Util_CURules.getInstance().synchro_actionaire(sObj,'Name',item.raisonSociale);
					Util_CURules.getInstance().synchro_actionaire(sObj,'Pays__c',item.pays);
					Util_CURules.getInstance().synchro_actionaire(sObj,'Pourcentage__c',item.pourcentage == null?'-':item.pourcentage+' %');
					Util_CURules.getInstance().synchro_actionaire(sObj,'SIREN_Alt__c',item.siren);
					Util_CURules.getInstance().synchro_actionaire(sObj,'Type__c',item.type_x);
					sObj.put(''+nomRelation,record.Id);

					actionairesNew.add(sObj);
				}
			}

			actionairesDel.addAll(actionairesMap.values());
			if (!byBatch){
				  delete actionairesDel;
				  upsert actionairesNew;
			}	  
			else{
				

				recordsByObjType.put('Del_Actionnaire__c', actionairesDel);
				recordsByObjType.put('Actionnaire__c', actionairesNew);
			}

			System.debug('participation');
			if(lienCapInfo.ParticipationsList != null)
			for (API_lienVoCallistoAltares.Participation item : lienCapInfo.ParticipationsList) {
				System.debug(item);
				if(!String.isBlank(item.raisonSociale)){
					Participation__c sObj = participationsMap.get(item.siren+'|'+item.raisonSociale);
					if(sObj == null)
						sObj = new Participation__c();
					else
						participationsMap.remove(item.siren+'|'+item.raisonSociale);
					Util_CURules.getInstance().synchro_participation(sObj,'Name',item.raisonSociale);
					Util_CURules.getInstance().synchro_participation(sObj,'Pays__c',item.pays);
					Util_CURules.getInstance().synchro_participation(sObj,'Pourcentage__c',item.pourcentage == null?'-':item.pourcentage+' %');
					Util_CURules.getInstance().synchro_participation(sObj,'SIREN_Alt__c',item.siren);
					Util_CURules.getInstance().synchro_participation(sObj,'Type__c',item.type_x);
					sObj.put(''+nomRelation,record.Id);

					participationsNew.add(sObj);
				}
			}
			participationsDel.addAll(participationsMap.values());

			if (!byBatch){
				delete participationsDel;
				upsert participationsNew;
			}	  
			else{
				recordsByObjType.put('Del_Participation__c', participationsDel);
				recordsByObjType.put('Participation__c', participationsNew);
			}

		}


		System.debug('decideur');
		if(decideurInfos != null)
		for (API_voCallistoAltares.DecideurInfo item : decideurInfos) {
			System.debug(item);

				Dirigeant_et_decideur__c sObj = dirigeantsMap.get(item.nom+'|'+item.prenom+'|'+item.fonction);
				if(sObj == null)
					sObj = new Dirigeant_et_decideur__c();
				else
					dirigeantsMap.remove(item.nom+'|'+item.prenom+'|'+item.fonction);
				Util_CURules.getInstance().synchro_dirigeant(sObj,'Name',String.isBlank(item.nom)?'-':item.nom);
				Util_CURules.getInstance().synchro_dirigeant(sObj,'Prenom__c',String.isBlank(item.prenom)?'-':item.prenom);
				Util_CURules.getInstance().synchro_dirigeant(sObj,'Genre__c',item.civilite);
				Util_CURules.getInstance().synchro_dirigeant(sObj,'Fonction__c',item.fonction);
				
				sObj.put('Order__c',decimal.valueOf(item.fonctionCode));
				sObj.put(''+nomRelation,record.Id);

				dirigeantsNew.add(sObj);
		}

		Date now = Date.today();
		System.debug('dirigean');
		if(dirigeanInfo != null && dirigeanInfo.dirigeantStatutaire != null)
		for (API_voCallistoAltares.DirigeantStatutaireInfo item : dirigeanInfo.dirigeantStatutaire) {
			
			System.debug(item);
			if((item.dateFinFonction == null || item.dateFinFonction > now)){
				Dirigeant_et_decideur__c sObj = dirigeantsMap.get(item.nom+'|'+item.prenom+'|'+item.fonction);
				if(sObj == null)
					sObj = new Dirigeant_et_decideur__c();
				else
					dirigeantsMap.remove(item.nom+'|'+item.prenom+'|'+item.fonction);
				Util_CURules.getInstance().synchro_dirigeant(sObj,'Name',String.isBlank(item.nom)?'-':item.nom);
				Util_CURules.getInstance().synchro_dirigeant(sObj,'Prenom__c',String.isBlank(item.prenom)?'-':item.prenom);
				Util_CURules.getInstance().synchro_dirigeant(sObj,'Raison_sociale_dirigeant__c',item.raisonSocialeDirigeantMoral);
				Util_CURules.getInstance().synchro_dirigeant(sObj,'Genre__c',item.civilite);
				Util_CURules.getInstance().synchro_dirigeant(sObj,'Fonction__c',item.fonction);
				
				sObj.put('Order__c',decimal.valueOf(item.fonctionCode));
				sObj.put(''+nomRelation,record.Id);
		
				dirigeantsNew.add(sObj);
			}

		}
		dirigeantsDel.addAll(dirigeantsMap.values());
	

		if (!byBatch){
			delete participationsDel;
			upsert participationsNew;
		}	  
		else{
			recordsByObjType.put('Del_Dirigeant_et_decideur__c', dirigeantsDel);
			recordsByObjType.put('Dirigeant_et_decideur__c', dirigeantsNew);
		}
		return recordsByObjType;
	}

	private API_voCallistoAltares.IdentiteAltaN4EtablissementInfo getIdentiteAltaN4Etablissement(String siret){
		
		API_serviceCallistoAltares.CallistoIdentiteSecureHttpsSoap11Endpoint IdentiteClient = new API_serviceCallistoAltares.CallistoIdentiteSecureHttpsSoap11Endpoint();
		API_requestCallistoAltares.SirenSiretRequest sirenSiretRequest = new API_requestCallistoAltares.SirenSiretRequest();
		sirenSiretRequest.identification = this.identification;
		sirenSiretRequest.refClient = this.refClient;
		sirenSiretRequest.sirenSiret = siret;

		API_identiteResponseCallistoAltares.IdentiteAltaN4EtResponse response = IdentiteClient.getIdentiteAltaN4Etablissement(sirenSiretRequest);

		if(response.correct){
			return response.myInfo;
		}else{
			return null;
		}
	}

	private API_voCallistoAltares.IdentiteAltaN4EntrepriseInfo getIdentiteAltaN4Entreprise(String siret){
		
		API_serviceCallistoAltares.CallistoIdentiteSecureHttpsSoap11Endpoint IdentiteClient = new API_serviceCallistoAltares.CallistoIdentiteSecureHttpsSoap11Endpoint();
		API_requestCallistoAltares.SirenRnaRequest sirenRnaRequest = new API_requestCallistoAltares.SirenRnaRequest();
		sirenRnaRequest.identification = this.identification;
		sirenRnaRequest.refClient = this.refClient;
		sirenRnaRequest.sirenRna = siret.left(9);

		API_identiteResponseCallistoAltares.IdentiteAltaN4EnResponse response =  IdentiteClient.getIdentiteAltaN4Entreprise(sirenRnaRequest);

		if(response.correct){
			return response.myInfo;
		}else{
			return null;
		}
	}
		

	private API_voCallistoAltares.ScoreInfo getScore(String siret){

		API_serviceCallistoAltares.CallistoRisqueObjectHttpsSoap11Endpoint RisqueClient = new API_serviceCallistoAltares.CallistoRisqueObjectHttpsSoap11Endpoint();

		API_requestCallistoAltares.SirenRequest sirenRequest = new API_requestCallistoAltares.SirenRequest();
		sirenRequest.identification = this.identification;
		sirenRequest.refClient = this.refClient;
		sirenRequest.siren = siret.left(9);

		API_responseCallistoAltares.ScoreResponse response =  RisqueClient.getScore(sirenRequest);

		if(response.correct){
			return response.myInfo;
		}else{
			return null;
		}
	}

	private API_voCallistoAltares.LiensCapitalistiquesInfo getLiensCapitalistiques(String siret){

		API_serviceCallistoAltares.CallistoIdentiteSecureHttpsSoap11Endpoint IdentiteClient = new API_serviceCallistoAltares.CallistoIdentiteSecureHttpsSoap11Endpoint();

		API_requestCallistoAltares.SirenRequest sirenRequest = new API_requestCallistoAltares.SirenRequest();
		sirenRequest.identification = this.identification;
		sirenRequest.refClient = this.refClient;
		sirenRequest.siren = siret.left(9);
		API_responseCallistoAltares.LiensCapitalistiquesResponse response =  IdentiteClient.getLiensCapitalistiques(sirenRequest);

		if(response.correct){
			return response.myInfo;
		}else{
			return null;
		}

	}

	private API_voCallistoAltares.DecideurInfo[] getListeDecideurs(String siret){

		API_serviceCallistoAltares.CallistoIdentiteSecureHttpsSoap11Endpoint IdentiteClient = new API_serviceCallistoAltares.CallistoIdentiteSecureHttpsSoap11Endpoint();

		API_requestCallistoAltares.SirenRequest sirenRequest = new API_requestCallistoAltares.SirenRequest();
		sirenRequest.identification = this.identification;
		sirenRequest.refClient = this.refClient;
		sirenRequest.siren = siret.left(9);
		API_responseCallistoAltares.ListeDecideursResponse response =  IdentiteClient.getListeDecideurs(sirenRequest);

		if(response.correct){
			return response.myInfo;
		}else{
			return new List<API_voCallistoAltares.DecideurInfo>();
		}

	}

	private API_voCallistoAltares.DirigeantsStatutaireInfo getListeDirigeantsStatutaires(String siret){

		API_serviceCallistoAltares.CallistoIdentiteSecureHttpsSoap11Endpoint IdentiteClient = new API_serviceCallistoAltares.CallistoIdentiteSecureHttpsSoap11Endpoint();

		API_requestCallistoAltares.ListeDirigeantRequest dirigRequest = new API_requestCallistoAltares.ListeDirigeantRequest();
		dirigRequest.identification = this.identification;
		dirigRequest.refClient = this.refClient;
		dirigRequest.typeDirigeant = 'DIR';
		dirigRequest.siren = siret.left(9);

		API_responseCallistoAltares.ListeDirigeantsStatutairesResponse response =  IdentiteClient.getListeDirigeantsStatutaires(dirigRequest);
		
		if(response.correct){
			return response.myInfo;
		}else{
			return null;
		}
	}

	private Boolean setPortfolioItem(String siret){

		API_serviceCallistoAltares.CallistoAlerteObjectHttpSoap11Endpoint AlertClient = new API_serviceCallistoAltares.CallistoAlerteObjectHttpSoap11Endpoint();

		API_alerteRequestCallistoAltares.PortfolioSetExtendedRequest portfolioRequest = new API_alerteRequestCallistoAltares.PortfolioSetExtendedRequest();
		portfolioRequest.identification = this.identification;
		portfolioRequest.refClient = this.refClient;
		portfolioRequest.siren = siret.left(9);
		portfolioRequest.ajoutAlerte = true;
		portfolioRequest.operation = 1;

		API_responseCallistoAltares.CallistoResponse response =  AlertClient.setPortfolioItem(portfolioRequest);
		
		return response.correct;
	}

}