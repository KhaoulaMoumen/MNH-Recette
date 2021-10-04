public with sharing class API_alerteRequestCallistoAltares {
	public with sharing class PortfolioSetExtendedRequest {
		public String identification;
		private String[] identification_type_info = new String[]{'identification','http://alerte.request.callisto.newsys.altares.fr/xsd','string','0','1','true'};
		public Boolean ajoutAlerte;
		public String commentaire;
		public Double encours;
		public String refClient;
		public String siren;
		private String[] ajoutAlerte_type_info = new String[]{'ajoutAlerte','http://alerte.request.callisto.newsys.altares.fr/xsd','boolean','0','1','false'};
		private String[] commentaire_type_info = new String[]{'commentaire','http://alerte.request.callisto.newsys.altares.fr/xsd','string','0','1','true'};
		private String[] encours_type_info = new String[]{'encours','http://alerte.request.callisto.newsys.altares.fr/xsd','double','0','1','true'};
		private String[] refClient_type_info = new String[]{'refClient','http://alerte.request.callisto.newsys.altares.fr/xsd','string','0','1','true'};
		private String[] siren_type_info = new String[]{'siren','http://alerte.request.callisto.newsys.altares.fr/xsd','string','0','1','true'};
		public Integer operation;
		private String[] operation_type_info = new String[]{'operation','http://alerte.request.callisto.newsys.altares.fr/xsd','int','0','1','false'};
		private String[] apex_schema_type_info = new String[]{'http://alerte.request.callisto.newsys.altares.fr/xsd','true','false'};
		private String[] field_order_type_info = new String[]{'identification','ajoutAlerte','commentaire','encours','refClient','siren','operation'};
	}
}