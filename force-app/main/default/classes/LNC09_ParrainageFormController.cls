/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 06-14-2021
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
 * Modifications Log 
 * Ver   Date         Author                               Modification
 * 1.0   06-14-2021   ChangeMeIn@UserSettingsUnder.SFDoc   Initial Version
**/
public class LNC09_ParrainageFormController {
    
    @AuraEnabled
    public static User getUserInfos(String username){
        return [SELECT Id, AccountId FROM User WHERE username =: username];
    }  
    
    @AuraEnabled
    public static String launchFlowParrainage(Parrainage__c parrainage, Id userID){
		String result;
        
        Map<String, Object> params = new Map<String, Object>();
        params.put('portalUserId', userID);
        params.put('parrainage', parrainage);
        
        Flow.Interview.FL01_Parrainage_Community flow = new Flow.Interview.FL01_Parrainage_Community(params);
        flow.start();
        Parrainage__c createdParr = (Parrainage__c)flow.getVariableValue('parrainage');
        system.debug('returned parrainage'+createdParr.Id);
        if(createdParr.Id == NULL) result = 'error'; 
        else result = 'success';
        return result;
    }  

    @AuraEnabled
    public static List<String> getLeadDepartment(){
        List<String> options = new List<String>();
        Schema.DescribeFieldResult fieldResult = Parrainage__c.leadDepartementParrainage__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for (Schema.PicklistEntry f: ple) {
            options.add(f.getLabel());
        }
        
        return options;
    }
}