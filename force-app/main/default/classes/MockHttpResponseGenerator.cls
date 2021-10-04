@isTest
global class MockHttpResponseGenerator implements HttpCalloutMock {
    // Implement this interface method
    global HTTPResponse respond(HTTPRequest req) {
        HTTPResponse res = new HTTPResponse();
        if(req.getEndpoint().contains('https://accounts.google.com')){
        
        // Create a fake response
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{"access_token":"ya29.c.KpwB6AfpARtGI8jifjoCYZosZVd3iUd9a4INWMY-N7db8O_Kw1_EXIOSCa6m_2h-bVIZ__6aN6hUBQlPUdu6m0RbuhWDbzNl9Mtk7rI0NzocOF1l2OF5RV6j1kWKxXSSq9XkCtECLbsLhcO5c-gAQmN1KiIDdVuL6NOBnHc0ZF9_HmcAkHEVwpFYL3XcglZz_grnkUgY0-Qf0Q0JEb2Z","expires_in":3599,"token_type":"Bearer"}');
            res.setStatusCode(200);
        }
        if(req.getEndpoint().contains('https://analyticsreporting.googleapis.com')){
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"sessions": [{"sessionId": "1539184430","deviceCategory": "desktop","platform": "Windows","dataSource": "web","sessionDate": "2018-10-10","activities": [{"activityTime": "2018-10-10T08:13:50.555105Z","source": "(direct)","medium": "(none)","channelGrouping": "Direct","campaign": "(not set)","keyword": "(not set)","hostname": "shop.googlemerchandisestore.com","landingPagePath": "/s/gpsmap/a/osp123232/aaaa","activityType": "PAGEVIEW","customDimension": [{"index": 1,"value": "(not set)"}],"pageview" : {"pageName":"aaaa","pagePath":"/s/offre-et-service-partenair/a/osp123232/aaaa"}}]}],"totalRows": 1000,"nextPageToken": "A6JGY3","sampleRate": 1}');
            res.setStatusCode(200);
        }
            return res;
        
    }
}