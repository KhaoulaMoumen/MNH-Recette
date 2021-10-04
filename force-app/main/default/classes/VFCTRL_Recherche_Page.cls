public with sharing class VFCTRL_Recherche_Page {
	
	public String sObjectName { get ; set ; }

	public VFCTRL_Recherche_Page()  {
		string BaseURL = ApexPages.currentPage().getHeaders().get('Host');
		String url = ApexPages.currentPage().getUrl();
		String[] parts = url.split('\\?');
		system.System.debug(parts[0]);
		sObjectName = parts[0].replace('/apex/VF_Recherche_Page_','');
		system.System.debug(sObjectName);
	}

	
}