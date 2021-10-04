public  with sharing class LNC12_EnvoiConventionEnMasseController {
	 
    @AuraEnabled
    public static Id executeBatchJob(){
        BA05_SendConventionToSign BA = new BA05_SendConventionToSign();
        Id batchJobId;
        if(!Test.isRunningTest()) Database.executeBatch(new BA05_SendConventionToSign(),1);
        return batchJobId;
    }
    
    @AuraEnabled
    public static Id executeBatchJob2(){
        BA10_SendMassConvPEE BA = new BA10_SendMassConvPEE();
        Id batchJobId;
        if(!Test.isRunningTest())Database.executeBatch(new BA10_SendMassConvPEE(),1);
        return batchJobId;
    }
    
    @AuraEnabled
    public static AsyncApexJob getBatchJobStatus(Id jobID){
        AsyncApexJob jobInfo = [SELECT Status, NumberOfErrors,JobItemsProcessed,TotalJobItems FROM AsyncApexJob WHERE Id = :jobID];
        return jobInfo;
    }
    
}