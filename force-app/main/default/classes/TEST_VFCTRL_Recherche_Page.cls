@isTest
private with sharing class TEST_VFCTRL_Recherche_Page {
	
	@isTest static void test_constructor() {
		PageReference pageRef = New PageReference('/apex/VF_Recherche_Page_Account?untrucuseless');
		Test.setCurrentPage(pageRef);
		VFCTRL_Recherche_Page ctrl = new VFCTRL_Recherche_Page();

		system.assertEquals(ctrl.sObjectName,'Account');
	}
	
	
	
}