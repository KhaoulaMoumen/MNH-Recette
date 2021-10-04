/*
----------------------------------------------------------------------
-- - Name          : BatchReportDownload
-- - Author        : BOU
-- - Description   : Batch qui récupére les rapports en fichier Excel
--
-- Maintenance History:
--
-- Date         Name                Version     Remarks 
-- -----------  -----------         --------    ---------------------------------------
-- 17-08-2020   BOU                 1.0         Init
---------------------------------------------------------------------------------------
*/
global class BatchReportDownload implements Database.Batchable<sObject>, Database.AllowsCallouts {
	
	global Database.QueryLocator start(Database.BatchableContext BC) {
        System.debug('[BatchReportDownload][start] start');
        List<String> reportIds = Label.LABS_SF_ReportIds.split(',');
		return Database.getQueryLocator([SELECT Id, DeveloperName, Name FROM Report WHERE Id IN :reportIds]);
	}

   	global void execute(Database.BatchableContext BC, List<Report> listReports) {
		System.debug('[BatchReportDownload][execute] Lancement du traitement');
        List<ContentVersion> cvs = new List<ContentVersion>();
        List<ContentDocumentLink> cdls = new List<ContentDocumentLink>();
		Boolean isEmpty = false;
        
        HttpRequest req = new HttpRequest();
		Http h = new Http();
        for(Report aReport : listReports) 
        {
            req = new HttpRequest(); 
            req.setEndpoint(URL.getSalesforceBaseUrl().toExternalForm() + '/services/data/v48.0/analytics/reports/'+aReport.Id);
            req.setMethod('GET');
            req.setHeader('Authorization', 'OAuth ' + UserInfo.getSessionId());
            req.setHeader('Accept', 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet');
            HTTPResponse res = h.send(req);
            system.debug('response : '+res);
            
            String result;
            if(res != null) {
                ContentVersion cv = new ContentVersion();
                List<ContentVersion> lContentVersions = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Title = :aReport.Name Limit 1];
                if (lContentVersions != null && lContentVersions.size() > 0)
                {
                    ContentVersion newCV = new ContentVersion();
                    newCV.ReasonForChange = 'new Version ['+DateTime.now()+']';
                    newCV.VersionData = res.getBodyAsBlob();
                    newCV.ContentDocumentId = lContentVersions.get(0).ContentDocumentId;
                    newCV.PathOnClient = aReport.Name+'.xlsx';
                    cvs.add(newCV);                          
                }
                if (Test.isRunningTest() || lContentVersions == null || lContentVersions.size() <=0)
                {
                    isEmpty = true;
                    cv = new ContentVersion();
                    cv.VersionData = res.getBodyAsBlob();
                    cv.Title = aReport.Name;
                    cv.PathOnClient = aReport.Name+'.xlsx';
                    cvs.add(cv); 
                }                           
                System.debug('[BatchReportDownload][execute] Fin du traitement');
            }	
        }
        system.debug('cvs'+cvs);
        system.debug('cdls'+cdls);
        if(cvs.size() > 0) {
            insert cvs;
            if(isEmpty){
                List<ContentVersion> contentVs = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id = :cvs ];
                    ContentWorkspace ws = [SELECT Id, RootContentFolderId FROM ContentWorkspace WHERE Name = 'MySC - Rapports' LIMIT 1];
                for(ContentVersion cv : contentVs){
                    ContentDocumentLink cdl = new ContentDocumentLink();
                    cdl.ContentDocumentId = cv.ContentDocumentId;
                    cdl.ShareType = 'I';
                    cdl.Visibility = 'AllUsers';
                    cdl.LinkedEntityId = ws.Id; //Magic happens here
                    cdls.add(cdl); 
                }
            }
        }
        if(cdls.size() > 0 && !Test.isRunningTest()) insert cdls;
    }
	
	global void finish(Database.BatchableContext BC) {
        System.debug('[BatchReportDownload][finish] finish');
	}
}