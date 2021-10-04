public with sharing class API_identiteResponseCallistoAltares {
	public with sharing class IdentiteAltaN4EnResponse {
		public Boolean correct;
		public API_voCallistoAltares.CallistoException_x exception_x;
		public API_voCallistoAltares.ParametreCallistoInfo parametres;
		private String[] correct_type_info = new String[]{'correct','http://response.callisto.newsys.altares.fr/xsd','boolean','0','1','false'};
		private String[] exception_x_type_info = new String[]{'exception','http://response.callisto.newsys.altares.fr/xsd','CallistoException','0','1','true'};
		private String[] parametres_type_info = new String[]{'parametres','http://response.callisto.newsys.altares.fr/xsd','ParametreCallistoInfo','0','1','true'};
		public API_voCallistoAltares.IdentiteAltaN4EntrepriseInfo myInfo;
		private String[] myInfo_type_info = new String[]{'myInfo','http://identite.response.callisto.newsys.altares.fr/xsd','IdentiteAltaN4EntrepriseInfo','0','1','true'};
		private String[] apex_schema_type_info = new String[]{'http://identite.response.callisto.newsys.altares.fr/xsd','true','false'};
		private String[] field_order_type_info = new String[]{'correct','exception_x','parametres','myInfo'};
	}
	public with sharing class IdentiteAltaN4EtResponse {
		public Boolean correct;
		public API_voCallistoAltares.CallistoException_x exception_x;
		public API_voCallistoAltares.ParametreCallistoInfo parametres;
		private String[] correct_type_info = new String[]{'correct','http://response.callisto.newsys.altares.fr/xsd','boolean','0','1','false'};
		private String[] exception_x_type_info = new String[]{'exception','http://response.callisto.newsys.altares.fr/xsd','CallistoException','0','1','true'};
		private String[] parametres_type_info = new String[]{'parametres','http://response.callisto.newsys.altares.fr/xsd','ParametreCallistoInfo','0','1','true'};
		public API_voCallistoAltares.IdentiteAltaN4EtablissementInfo myInfo;
		private String[] myInfo_type_info = new String[]{'myInfo','http://identite.response.callisto.newsys.altares.fr/xsd','IdentiteAltaN4EtablissementInfo','0','1','true'};
		private String[] apex_schema_type_info = new String[]{'http://identite.response.callisto.newsys.altares.fr/xsd','true','false'};
		private String[] field_order_type_info = new String[]{'correct','exception_x','parametres','myInfo'};
	}
}