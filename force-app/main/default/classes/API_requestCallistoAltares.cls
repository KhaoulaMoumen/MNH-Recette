public with sharing class API_requestCallistoAltares {
	public with sharing class SirenRequest {
		public String identification;
		public String refClient;
		private String[] identification_type_info = new String[]{'identification','http://request.callisto.newsys.altares.fr/xsd','string','0','1','true'};
		private String[] refClient_type_info = new String[]{'refClient','http://request.callisto.newsys.altares.fr/xsd','string','0','1','true'};
		public String siren;
		private String[] siren_type_info = new String[]{'siren','http://request.callisto.newsys.altares.fr/xsd','string','0','1','true'};
		private String[] apex_schema_type_info = new String[]{'http://request.callisto.newsys.altares.fr/xsd','true','false'};
		private String[] field_order_type_info = new String[]{'identification','refClient','siren'};
	}
	public with sharing class SirenRnaRequest {
		public String identification;
		public String refClient;
		private String[] identification_type_info = new String[]{'identification','http://request.callisto.newsys.altares.fr/xsd','string','0','1','true'};
		private String[] refClient_type_info = new String[]{'refClient','http://request.callisto.newsys.altares.fr/xsd','string','0','1','true'};
		public String sirenRna;
		private String[] sirenRna_type_info = new String[]{'sirenRna','http://request.callisto.newsys.altares.fr/xsd','string','0','1','true'};
		private String[] apex_schema_type_info = new String[]{'http://request.callisto.newsys.altares.fr/xsd','true','false'};
		private String[] field_order_type_info = new String[]{'identification','refClient','sirenRna'};
	}
	public with sharing class SirenSiretRequest {
		public String identification;
		public String refClient;
		private String[] identification_type_info = new String[]{'identification','http://request.callisto.newsys.altares.fr/xsd','string','0','1','true'};
		private String[] refClient_type_info = new String[]{'refClient','http://request.callisto.newsys.altares.fr/xsd','string','0','1','true'};
		public String sirenSiret;
		private String[] sirenSiret_type_info = new String[]{'sirenSiret','http://request.callisto.newsys.altares.fr/xsd','string','0','1','true'};
		private String[] apex_schema_type_info = new String[]{'http://request.callisto.newsys.altares.fr/xsd','true','false'};
		private String[] field_order_type_info = new String[]{'identification','refClient','sirenSiret'};
	}
	public with sharing class ListeDirigeantRequest {
		public String identification;
		public String refClient;
		private String[] identification_type_info = new String[]{'identification','http://request.callisto.newsys.altares.fr/xsd','string','0','1','true'};
		private String[] refClient_type_info = new String[]{'refClient','http://request.callisto.newsys.altares.fr/xsd','string','0','1','true'};
		public String siren;
		private String[] siren_type_info = new String[]{'siren','http://request.callisto.newsys.altares.fr/xsd','string','0','1','true'};
		public String typeDirigeant;
		private String[] typeDirigeant_type_info = new String[]{'typeDirigeant','http://request.callisto.newsys.altares.fr/xsd','string','0','1','true'};
		private String[] apex_schema_type_info = new String[]{'http://request.callisto.newsys.altares.fr/xsd','true','false'};
		private String[] field_order_type_info = new String[]{'identification','refClient','siren','typeDirigeant'};
	}
		public with sharing class RechercheAssociationRequest {
		public String identification;
		public String refClient;
		private String[] identification_type_info = new String[]{'identification','http://request.callisto.newsys.altares.fr/xsd','string','0','1','true'};
		private String[] refClient_type_info = new String[]{'refClient','http://request.callisto.newsys.altares.fr/xsd','string','0','1','true'};
		public Boolean categorieItemADeselectionner;
		public String categorieItemId;
		public String contexteRecherche;
		public Integer debutResultat;
		public String departement;
		public Integer nbElt;
		public String objet;
		public String rna;
		public String theme;
		public String titre;
		private String[] categorieItemADeselectionner_type_info = new String[]{'categorieItemADeselectionner','http://request.callisto.newsys.altares.fr/xsd','boolean','0','1','false'};
		private String[] categorieItemId_type_info = new String[]{'categorieItemId','http://request.callisto.newsys.altares.fr/xsd','string','0','1','true'};
		private String[] contexteRecherche_type_info = new String[]{'contexteRecherche','http://request.callisto.newsys.altares.fr/xsd','string','0','1','true'};
		private String[] debutResultat_type_info = new String[]{'debutResultat','http://request.callisto.newsys.altares.fr/xsd','int','0','1','false'};
		private String[] departement_type_info = new String[]{'departement','http://request.callisto.newsys.altares.fr/xsd','string','0','1','true'};
		private String[] nbElt_type_info = new String[]{'nbElt','http://request.callisto.newsys.altares.fr/xsd','int','0','1','false'};
		private String[] objet_type_info = new String[]{'objet','http://request.callisto.newsys.altares.fr/xsd','string','0','1','true'};
		private String[] rna_type_info = new String[]{'rna','http://request.callisto.newsys.altares.fr/xsd','string','0','1','true'};
		private String[] theme_type_info = new String[]{'theme','http://request.callisto.newsys.altares.fr/xsd','string','0','1','true'};
		private String[] titre_type_info = new String[]{'titre','http://request.callisto.newsys.altares.fr/xsd','string','0','1','true'};
		private String[] apex_schema_type_info = new String[]{'http://request.callisto.newsys.altares.fr/xsd','true','false'};
		private String[] field_order_type_info = new String[]{'identification','refClient','categorieItemADeselectionner','categorieItemId','contexteRecherche','debutResultat','departement','nbElt','objet','rna','theme','titre'};
	}
	public with sharing class RechercheEntrepriseRequest {
		public String identification;
		public String refClient;
		private String[] identification_type_info = new String[]{'identification','http://request.callisto.newsys.altares.fr/xsd','string','0','1','true'};
		private String[] refClient_type_info = new String[]{'refClient','http://request.callisto.newsys.altares.fr/xsd','string','0','1','true'};
		public Boolean categorieItemADeselectionner;
		public String categorieItemId;
		public String codePostal;
		public String contexteRecherche;
		public Integer debutResultat;
		public String duns;
		public String enseigne;
		public String formeJuridique;
		public String ft;
		public String naf;
		public Integer nbElt;
		public String raisonSociale;
		public String rcs;
		public Boolean rechercheActif;
		public Boolean rechercheSiege;
		public String rue;
		public String sigle;
		public String siren;
		public String siret;
		public String statutEirl;
		public String telephone;
		public Integer typeRecherche;
		public String ville;
		private String[] categorieItemADeselectionner_type_info = new String[]{'categorieItemADeselectionner','http://request.callisto.newsys.altares.fr/xsd','boolean','0','1','false'};
		private String[] categorieItemId_type_info = new String[]{'categorieItemId','http://request.callisto.newsys.altares.fr/xsd','string','0','1','true'};
		private String[] codePostal_type_info = new String[]{'codePostal','http://request.callisto.newsys.altares.fr/xsd','string','0','1','true'};
		private String[] contexteRecherche_type_info = new String[]{'contexteRecherche','http://request.callisto.newsys.altares.fr/xsd','string','0','1','true'};
		private String[] debutResultat_type_info = new String[]{'debutResultat','http://request.callisto.newsys.altares.fr/xsd','int','0','1','false'};
		private String[] duns_type_info = new String[]{'duns','http://request.callisto.newsys.altares.fr/xsd','string','0','1','true'};
		private String[] enseigne_type_info = new String[]{'enseigne','http://request.callisto.newsys.altares.fr/xsd','string','0','1','true'};
		private String[] formeJuridique_type_info = new String[]{'formeJuridique','http://request.callisto.newsys.altares.fr/xsd','string','0','1','true'};
		private String[] ft_type_info = new String[]{'ft','http://request.callisto.newsys.altares.fr/xsd','string','0','1','true'};
		private String[] naf_type_info = new String[]{'naf','http://request.callisto.newsys.altares.fr/xsd','string','0','1','true'};
		private String[] nbElt_type_info = new String[]{'nbElt','http://request.callisto.newsys.altares.fr/xsd','int','0','1','false'};
		private String[] raisonSociale_type_info = new String[]{'raisonSociale','http://request.callisto.newsys.altares.fr/xsd','string','0','1','true'};
		private String[] rcs_type_info = new String[]{'rcs','http://request.callisto.newsys.altares.fr/xsd','string','0','1','true'};
		private String[] rechercheActif_type_info = new String[]{'rechercheActif','http://request.callisto.newsys.altares.fr/xsd','boolean','0','1','false'};
		private String[] rechercheSiege_type_info = new String[]{'rechercheSiege','http://request.callisto.newsys.altares.fr/xsd','boolean','0','1','false'};
		private String[] rue_type_info = new String[]{'rue','http://request.callisto.newsys.altares.fr/xsd','string','0','1','true'};
		private String[] sigle_type_info = new String[]{'sigle','http://request.callisto.newsys.altares.fr/xsd','string','0','1','true'};
		private String[] siren_type_info = new String[]{'siren','http://request.callisto.newsys.altares.fr/xsd','string','0','1','true'};
		private String[] siret_type_info = new String[]{'siret','http://request.callisto.newsys.altares.fr/xsd','string','0','1','true'};
		private String[] statutEirl_type_info = new String[]{'statutEirl','http://request.callisto.newsys.altares.fr/xsd','string','0','1','true'};
		private String[] telephone_type_info = new String[]{'telephone','http://request.callisto.newsys.altares.fr/xsd','string','0','1','true'};
		private String[] typeRecherche_type_info = new String[]{'typeRecherche','http://request.callisto.newsys.altares.fr/xsd','int','0','1','false'};
		private String[] ville_type_info = new String[]{'ville','http://request.callisto.newsys.altares.fr/xsd','string','0','1','true'};
		private String[] apex_schema_type_info = new String[]{'http://request.callisto.newsys.altares.fr/xsd','true','false'};
		private String[] field_order_type_info = new String[]{'identification','refClient','categorieItemADeselectionner','categorieItemId','codePostal','contexteRecherche','debutResultat','duns','enseigne','formeJuridique','ft','naf','nbElt','raisonSociale','rcs','rechercheActif','rechercheSiege','rue','sigle','siren','siret','statutEirl','telephone','typeRecherche','ville'};
	}
	public with sharing class RechercheSimpleRequest {
		public String identification;
		public String refClient;
		private String[] identification_type_info = new String[]{'identification','http://request.callisto.newsys.altares.fr/xsd','string','0','1','true'};
		private String[] refClient_type_info = new String[]{'refClient','http://request.callisto.newsys.altares.fr/xsd','string','0','1','true'};
		public Boolean categorieItemADeselectionner;
		public String categorieItemId;
		public String contexteRecherche;
		public Integer debutResultat;
		public Boolean elargie;
		public Integer nbElt;
		public String ou;
		public String qui;
		public Boolean rechercheActif;
		public Boolean rechercheSiege;
		private String[] categorieItemADeselectionner_type_info = new String[]{'categorieItemADeselectionner','http://request.callisto.newsys.altares.fr/xsd','boolean','0','1','false'};
		private String[] categorieItemId_type_info = new String[]{'categorieItemId','http://request.callisto.newsys.altares.fr/xsd','string','0','1','true'};
		private String[] contexteRecherche_type_info = new String[]{'contexteRecherche','http://request.callisto.newsys.altares.fr/xsd','string','0','1','true'};
		private String[] debutResultat_type_info = new String[]{'debutResultat','http://request.callisto.newsys.altares.fr/xsd','int','0','1','false'};
		private String[] elargie_type_info = new String[]{'elargie','http://request.callisto.newsys.altares.fr/xsd','boolean','0','1','false'};
		private String[] nbElt_type_info = new String[]{'nbElt','http://request.callisto.newsys.altares.fr/xsd','int','0','1','false'};
		private String[] ou_type_info = new String[]{'ou','http://request.callisto.newsys.altares.fr/xsd','string','0','1','true'};
		private String[] qui_type_info = new String[]{'qui','http://request.callisto.newsys.altares.fr/xsd','string','0','1','true'};
		private String[] rechercheActif_type_info = new String[]{'rechercheActif','http://request.callisto.newsys.altares.fr/xsd','boolean','0','1','false'};
		private String[] rechercheSiege_type_info = new String[]{'rechercheSiege','http://request.callisto.newsys.altares.fr/xsd','boolean','0','1','false'};
		private String[] apex_schema_type_info = new String[]{'http://request.callisto.newsys.altares.fr/xsd','true','false'};
		private String[] field_order_type_info = new String[]{'identification','refClient','categorieItemADeselectionner','categorieItemId','contexteRecherche','debutResultat','elargie','nbElt','ou','qui','rechercheActif','rechercheSiege'};
	}
}