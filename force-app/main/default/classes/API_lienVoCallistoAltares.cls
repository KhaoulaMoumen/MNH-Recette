public with sharing class API_lienVoCallistoAltares {
	public with sharing class Actionnaire {
		public String codePays;
		public Date dateMAJ;
		public String pays;
		public Double pourcentage;
		public String raisonSociale;
		public String siren;
		public String type_x;
		private String[] codePays_type_info = new String[]{'codePays','http://lien.vo.callisto.newsys.altares.fr/xsd','string','0','1','true'};
		private String[] dateMAJ_type_info = new String[]{'dateMAJ','http://lien.vo.callisto.newsys.altares.fr/xsd','date','0','1','true'};
		private String[] pays_type_info = new String[]{'pays','http://lien.vo.callisto.newsys.altares.fr/xsd','string','0','1','true'};
		private String[] pourcentage_type_info = new String[]{'pourcentage','http://lien.vo.callisto.newsys.altares.fr/xsd','double','0','1','true'};
		private String[] raisonSociale_type_info = new String[]{'raisonSociale','http://lien.vo.callisto.newsys.altares.fr/xsd','string','0','1','true'};
		private String[] siren_type_info = new String[]{'siren','http://lien.vo.callisto.newsys.altares.fr/xsd','string','0','1','true'};
		private String[] type_x_type_info = new String[]{'type','http://lien.vo.callisto.newsys.altares.fr/xsd','string','0','1','true'};
		private String[] apex_schema_type_info = new String[]{'http://lien.vo.callisto.newsys.altares.fr/xsd','true','false'};
		private String[] field_order_type_info = new String[]{'codePays','dateMAJ','pays','pourcentage','raisonSociale','siren','type_x'};
	}
	public with sharing class Participation {
		public String codePays;
		public Date dateMAJ;
		public String pays;
		public Double pourcentage;
		public String raisonSociale;
		public String siren;
		public String type_x;
		private String[] codePays_type_info = new String[]{'codePays','http://lien.vo.callisto.newsys.altares.fr/xsd','string','0','1','true'};
		private String[] dateMAJ_type_info = new String[]{'dateMAJ','http://lien.vo.callisto.newsys.altares.fr/xsd','date','0','1','true'};
		private String[] pays_type_info = new String[]{'pays','http://lien.vo.callisto.newsys.altares.fr/xsd','string','0','1','true'};
		private String[] pourcentage_type_info = new String[]{'pourcentage','http://lien.vo.callisto.newsys.altares.fr/xsd','double','0','1','true'};
		private String[] raisonSociale_type_info = new String[]{'raisonSociale','http://lien.vo.callisto.newsys.altares.fr/xsd','string','0','1','true'};
		private String[] siren_type_info = new String[]{'siren','http://lien.vo.callisto.newsys.altares.fr/xsd','string','0','1','true'};
		private String[] type_x_type_info = new String[]{'type','http://lien.vo.callisto.newsys.altares.fr/xsd','string','0','1','true'};
		private String[] apex_schema_type_info = new String[]{'http://lien.vo.callisto.newsys.altares.fr/xsd','true','false'};
		private String[] field_order_type_info = new String[]{'codePays','dateMAJ','pays','pourcentage','raisonSociale','siren','type_x'};
	}
}