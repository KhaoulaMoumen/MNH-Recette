@isTest
private with sharing class TEST_VFCTRL_Update_Button {
	
	@isTest static void test_constructor() {

		Account a = new Account();
		a.Name = 'Altares';
		insert a;

		PageReference pageRef = New PageReference('/sometings?id='+a.Id);
		Test.setCurrentPage(pageRef);
		VFCTRL_Update_Button ctrl = new VFCTRL_Update_Button();

		system.assertEquals(ctrl.sObjectName,'Account');
		system.assertEquals(ctrl.recordId,a.Id);
	}
	
	
	
}