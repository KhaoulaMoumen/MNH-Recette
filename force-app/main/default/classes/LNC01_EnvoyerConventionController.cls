global class LNC01_EnvoyerConventionController {
    
    @AuraEnabled
    public static Opportunity getOppDetails(String oppId){
        // RETURN OPPORTUNITY STAGE AND ID 
        return [select id , stageName, RecordType.Name from Opportunity where id =: oppId];
       
    }
    
    @AuraEnabled(cacheable=true)
	public static string getDocusignUrl(String SourceID, String CRL,String CCRM , String CCTM , String LA , String LF){
    
    // CREATE DOCUSIGN ENVELOPE WITH SIGNATAIRES AND SOURCE...
    Pagereference pg = Page.dsfs__DocuSign_CreateEnvelope;
    pg.getParameters().put('SourceID',SourceID);
    pg.getParameters().put('CRL',CRL);
    pg.getParameters().put('CCRM',CCRM);
    pg.getParameters().put('CCTM',CCTM);
    pg.getParameters().put('LA',LA);
    pg.getParameters().put('LF',LF);     
    return pg.getUrl();
}

}