public with sharing class VFCTRL_Update_Button {
	
	public String sObjectName { get ; set ; }
	public Id recordId { get ; set ; }
	
	public VFCTRL_Update_Button() {
		recordId = apexpages.currentpage().getparameters().get('id');
		sObjectName = recordId.getSObjectType().getDescribe().getName();

	}
}