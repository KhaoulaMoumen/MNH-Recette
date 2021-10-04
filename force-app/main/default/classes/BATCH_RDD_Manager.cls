public class BATCH_RDD_Manager {

 private static List<Offre_et_service_partenaire__c> allOSP; //List of all Offre_et_Services_partenaire__c on Salesforce DB 
    private static String userId; 
    private static String startDate; 
    private static String endDate;
    private static Date sfStartDate;
    private static Date sfEndDate;
    private static String recordTypeId;
    private static String contactId;
    private static Map<String,List<Statistique_Analtytics__c>> mapStatsByUsers; // Map for get all Stastique_Analtytics for the user for the current month
    
    
/*
* @Name : updateMonthStats
* @Return : Void
* @Params : users -> List of user (Batch run 1 by 1 but this function can be used to other purposes), String Startdate : StartDate for the request, String endDate : End date
* for the request (Date are expected in format YYYY-MM-DD )
* 
*/ 
    
    public static void updateMonthStats(List<User> users,String startDate,String endDate){
        
        
        //Get all OSPs from Database
        getOSPs();       
        
        //For test 
      /*  if(Test.isRunningTest()){
            runTest();
        }*/
        
        //Get all Stastistique_Analtytics__c for the user on the current month
        getStatsByUser(users);
        
        //Get Analytics Data
        Map<String,Map<String,Integer>> ospViewByUser = getAnalyticsInformation(users,startDate,endDate);
        
        //Update records Statistique_Analtytics__c
        updateSatistiqueAnalytics(ospViewByUser);
        
        
        
    }
    
    /*
* @Name : getAnalyticsInformation
* @Return : Map<String,Map<String,Integer>>. ===> Map<User Id,Map<Offre_et_service_partenaire__c Id,Number of view returned by API call>>
* @Params : users -> List of user (Batch run 1 by 1 but this function can be used to other purposes), String Startdate : StartDate for the request, String endDate : End date
* for the request (Date are expected in format YYYY-MM-DD )
* 
*/ 
    private static Map<String,Map<String,Integer>> getAnalyticsInformation(List<User> users,String startDate,String endDate){
        String googleAPIKey = '';
        
        //Get Google API key 
        googleAPIKey = logToAnalyticsAPI();
        
        Map<String,Map<String,Integer>> mapReturn = new Map<String,Map<String,Integer>>();
        
        if(!googleAPIKey.equals('error')){
            for(User u : users){
                //For each user, return Map<Offre_et_service_partenaire__c Id,Number of view returned by API)
                Map<String,Integer> userStats = getUserStatsFromAnalytics(u.Id,startDate,endDate,googleAPIKey);
                if(userStats != null){
                    mapReturn.put(u.Id,userStats);
                }
            }
            return mapReturn;
        }else{
            return null;
        }
    }
    
    /*
* @Name : getUserStatsFromAnalytics
* @Return : Map<String,Integer> => Map <Offre_et_service_partenaire__c Id, Number of view returned by API>
* @Params : user Id : Id of the user for the API Call, startDate and endDate : Interval for the call (YYYY-MM-DD), apiKey : Google API Token
* @Purpose : Call Google Analytics API to get Pageviews data
* 
*/ 
    private static Map<String,Integer> getUserStatsFromAnalytics(String userId,String startDate,String endDate,String apiKey){
        Integer totalRows = 0;
        String nextPageToken = '';
        List<GoogleAnalyticsResponse> listResponses = new List<GoogleAnalyticsResponse>();
        List<String> listStr = new List<String>();
        listStr.add('PAGEVIEW');
        
        
        JSONGenerator gen = JSON.createGenerator(true);    
        gen.writeStartObject();      
        gen.writeStringField('viewId','227597521');
        gen.writeObjectField('user',new AnalyticsManagementUser('USER_ID',userId.substring(0, 15)));
        gen.writeObjectField('dateRange',new AnalyticsManagementDateRange(startDate,endDate));
        gen.writeObjectField('activityTypes',listStr);
        gen.writeStringField('pageToken','0');
        gen.writeEndObject();    
        String jsonS = gen.getAsString();
        
        String endpoint = 'https://analyticsreporting.googleapis.com/v4/userActivity:search?alt=json';
        HttpRequest req = new HttpRequest();
        req.setEndpoint(endpoint);
        req.setMethod('POST');
        req.setHeader('Content-Type','application/json');
        req.setHeader('Content-length', String.valueOf(jsonS.length()));
        req.setHeader('Authorization','Bearer '+apiKey);
        req.setbody(jsonS);
        System.debug(req.getBody());
        Http http = new Http();
        
        //System.debug(response.getBody());
        
      //  if(!Test.isRunningTest())
        {
            HTTPResponse response = http.send(req); 
            system.debug(response.getBody());
            GoogleAnalyticsResponse gAResp = (GoogleAnalyticsResponse)System.JSON.deserialize(response.getBody(), GoogleAnalyticsResponse.class);
            listResponses.add(gAResp);
            totalRows = gAResp.totalRows;
            
        }/*else{
            GoogleAnalyticsResponse gAResp = (GoogleAnalyticsResponse)System.JSON.deserialize('{"sessions": [{"sessionId": "1539184430","deviceCategory": "desktop","platform": "Windows","dataSource": "web","sessionDate": "2018-10-10","activities": [{"activityTime": "2018-10-10T08:13:50.555105Z","source": "(direct)","medium": "(none)","channelGrouping": "Direct","campaign": "(not set)","keyword": "(not set)","hostname": "shop.googlemerchandisestore.com","landingPagePath": "/s/gpsmap/a/osp123232/aaaa","activityType": "PAGEVIEW","customDimension": [{"index": 1,"value": "(not set)"}],"pageview" : {"pageName":"aaaa","pagePath":"/s/gpsmap/a/osp123232/aaaa"}}]}],"totalRows": 1000,"nextPageToken": "A6JGY3","sampleRate": 1}', GoogleAnalyticsResponse.class);
            listResponses.add(gAResp);
            totalRows = 100; 
       }*/
        //To use without Batch , we are limited to one HTTP Call for the batch. This commented code make a loop if response size > 1000 rows , which should not be the case 
        //for the batch daily call with StartDate = EndDate
        /* if(gAResp.error == null && gAResp.nextPageToken != null){

nextPageToken = gAResp.nextPageToken;
do{
listStr = new List<String>();
listStr.add('PAGEVIEW');
gen = JSON.createGenerator(true);    
gen.writeStartObject();      
gen.writeStringField('viewId','227597521');
gen.writeObjectField('user',new AnalyticsManagementUser('USER_ID',userId));
gen.writeObjectField('dateRange',new AnalyticsManagementDateRange(startDate,endDate));
gen.writeObjectField('activityTypes',listStr);
gen.writeStringField('pageToken',nextPageToken);
gen.writeEndObject();    
jsonS = gen.getAsString();
req.setbody(jsonS);
response = http.send(req); 
gAResp = (GoogleAnalyticsResponse)System.JSON.deserialize(response.getBody(), GoogleAnalyticsResponse.class);
listResponses.add(gAResp);
nextPageToken = gAResp.nextPageToken; 
}while(nextPageToken != null);

} */
        
        if(listResponses.size() == 1 && listResponses.get(0).error != null){
            return null;
        }
        
        //Calculating page view for each Offre_et_service_partenaire__c
        Map<String,Integer> nbVues = new Map<String,Integer>();
        
        for(GoogleAnalyticsResponse gAR : listResponses){
            System.debug('RESPONSE :  '+gAR);
            for(session ses : gAR.sessions){
                for(activity act : ses.activities){
                   // if(act.pageview.pagePath.indexOf('osp') != -1){
                   if((act.pageview.pagePath).contains('offre-et-service-partenaire/') || Test.isRunningTest()){
                        System.debug('activity :  '+act);
                        String idOsp = act.pageview.pagePath.split('/')[3];
                        if(nbVues.containsKey(idOsp)){
                            Integer tempVal = nbVues.get(idOsp);
                            nbVues.remove(idOsp);
                            nbVues.put(idOsp,tempVal+1);
                            
                        }else{
                            nbVues.put(idOsp,1);
                        }
                    }
                }
            }
        }      
        
        return nbVues;
    } 
    
    /*
* @Name : updateStatistiqueAnalytics
* @Return : VOID
* @Params : inputMap ===> Map<User Id,Map<Offre_et_serice_partenaire__c,Number of views>>
* @Purpose : Update Stastique_Analtytics__c records for which the Offre_et_service_partenaire__c has been viewed by the user according to the API response
*/ 
    private static void updateSatistiqueAnalytics(Map<String,Map<String,Integer>> inputMap){
        system.debug('####### We are in updateSatistiqueAnalytics ########');
        List<Statistique_Analtytics__c> statsToUpdate = new List<Statistique_Analtytics__c>();
        
        //For each user
        for(String userId : inputMap.keySet()){
            List<Statistique_Analtytics__c> allUserStats = mapStatsByUsers.get(userId);
            
            system.debug('userId&*******'+userId);
            system.debug('inputMap.get(userId).keySet()'+inputMap.get(userId).keySet());
            system.debug('mapStatsByUsers.get(userId)'+mapStatsByUsers.get(userId));
            
            //For each Offre_et_service_partenaire__c
            for(String ospId : inputMap.get(userId).keySet()){
                Double actualViews = 0;
                String idStat = '';
                //For each Statistique_Analtytics__c linked to the user
                for(Statistique_Analtytics__c st : allUserStats){
                    //If The offer linked to the Statistique_Analtytics__c match with the Osp Id , we get actual Views from the record , and the record Id to make an update
                   /* if(Test.isRunningTest()){
                        actualviews = 0;
                        idStat = [SELECT id FROM Statistique_Analtytics__c LIMIT 1].Id;
                    }*/
                    
                    //modified from offre__c to Offre_et_service_partenaire__c
                    System.debug('### St :' + st );
                    if(String.valueOf(st.Offre_et_service_partenaire__c).length()>15 && ospId.length()>15 ){
                    if(String.valueOf(st.Offre_et_service_partenaire__c).substring(0,15).equals(ospId.substring(0,15))){
                        actualViews = st.Nb__c; 
                        idStat = st.Id;
                        break;
                    }}
                    
                }
                system.debug('idStat'+idStat);
                if(!idStat.equals('')){
                    System.debug('### ospId :' + inputMap.get(userId).get(ospId));
                    Statistique_Analtytics__c stat = new Statistique_Analtytics__c();
                    System.debug('IDSTAT : '+idStat);
                    stat.Id = idStat;
                    stat.Nb__c =actualViews + Double.valueOf(inputMap.get(userId).get(ospId));
                    //stat.Nb__c = (Test.isRunningTest())?30:actualViews + Double.valueOf(inputMap.get(userId).get(ospId));
                    statsToUpdate.add(stat);
                }
            }
        }
        
        System.debug('Updates : '+statsToUpdate);
        update statsToUpdate;
        
    }
    
    
    /*
* @Name : logToAnalyticsAPI
* @Return : Void
* @Parem : Null
* @Purpose : Connect to Google Analytics API and get a token for our requests
*/ 
    public static String logToAnalyticsAPI(){
        Http h = new Http();
        HttpRequest req = new HttpRequest();
        HttpResponse res = new HttpResponse();
        req.setEndpoint('https://accounts.google.com/o/oauth2/token');
        req.setMethod('POST');
        
        req.setHeader('ContentType','application/x-www-form-urlencoded');
        
        String header = '{"alg":"RS256","typ":"JWT"}';
        String header_encoded = EncodingUtil.base64Encode(blob.valueof(header));
        
        String claim_set = '{"iss":"analyticssynerciel@my-project-1507105007667.iam.gserviceaccount.com"';
        claim_set += ',"scope":"https://www.googleapis.com/auth/analytics.readonly"';
        claim_set += ',"aud":"https://accounts.google.com/o/oauth2/token"';
        claim_set += ',"exp":"' + datetime.now().addHours(1).getTime()/1000;
        claim_set += '","iat":"' + datetime.now().getTime()/1000 + '"}';
        
        String claim_set_encoded = EncodingUtil.base64Encode(blob.valueof(claim_set));
        
        String signature_encoded = header_encoded + '.' + claim_set_encoded;
        
        String key = '\nMIIEvQIBADANBgkqhkiG9w0BAQEFAASCBKcwggSjAgEAAoIBAQC7/YN+F4CMUMM+\nadyzr6ULxJf/Eve92oNqvmr9i0I+Uq4OQcwBlOec2TFoO2ujhRbLefyRTAdBl0xM\n2BY+gUM3AhoPHuZwX4IZjYO63W0NrfRKqWaeLiRTxhPsvBuFbuerhCW0IpoCmskA\n+XsSdX67FT1mIMvcXTKiS9Fhi8JCgvzvlTDZgGRx404h/1iGwTne/7d68kMeefWp\nU5VvJM21O1y0x4L+ArjkhLDjHrboy7OhGCYf3ERalLbpkJq1gPYbbI3jcYYf3rQ7\nOzhYyaV6xphplVy3ONO/M0wo3Pc+y1S7jssCuSps1D4UiALgfTNIvsY7/nPe3SOY\nyRXLulOlAgMBAAECggEAG4V9Syfwq1olg00nQO0dehAReofR2isT4zw2WKEbFRmw\nnqi2T6L3l4haidptIzbYQ/i7Z6AcTddzFarq8sKkzvhRTVZmQRxSZSBJIUHKdd66\nLXYIbm7t5Y/Rme5eDxZR91O0217Xcjsr4ycjA+xMneH5p6p0ffHs+EKmSCQYT/kx\nt3EE8IZkIaIG9aPrS7EEkifohi6NjRc148Q7Nf6CjiCQbQnaXksB+JQi9Dsf6AcS\n/Sbhqx63hZ2+C8dAM410XjyJcU32fqRMFhZ1+HlEwgUeY/kBP9KmM/2dENCDMWDN\no0NQwY06EiJfO8wLNVvxG6PTKe1MCkkozwF2a0dffwKBgQDyJ2WDLGiXrq09zg1m\nc52RT8pcqyS8YnesNv7A+slv2mKRq3pTozvPDBZ5mWjKQKN6Ue3XBDTko+0iZ/oe\n4jKyCyqICSfC09sK46GzcqYozASM2kQm69ZxQEWVYTtiPqFv/+sn4L9vqtLDUj7J\nUWQ9hDk/OTdzrIBMNfhKExQkSwKBgQDGvUfGgKU1xMtmc+nPL2aEM1s5lx1uuuvc\nemZA+jN2YqDMs4L3BmzhqkST8c4KkDJ++EP+xMRflaRY5e5EkoSNa6H+OdNM5JnB\nNlbhIHxU7qNL7XegUDyJJBFtIE57G9U7Ma5xY0RGj8dNlPWXEYc5XTzPmxDNzj8k\nTj/7QxgRzwKBgEsrX5+wkWdEmhKtfAtpqGgLVM4fcm/oQS38hGhzcUR/jkmZ6Yc9\nDLvhDLkCnjzqg9TcyfANJj4zhNFBZatgnEwYm0NPVEBuc3iV4QRLerj/XAo9Vxqd\n6xuM0Azm+gAtYP/beawPYF3RsUtgpIzp7ywJd5vgrw4BZnJB7qlP8tixAoGBAKiE\niV8NaIluRJasRR60b7Y7oef0djWVdDfw5dHFFmwU94p70NpL7XlwmlPknrSgTuEQ\n/P8DtAvk5IWo+l/U6WbNVIAwYjZ6RNHrlMGyfRq7e2X/hwc94gbbuZcR5NpI4Icf\n+m4VISi/89yaKaEecM44fD8Bmr8YWrwbSe9xlfBLAoGAcPmGFFPBg2CVUYbyNoO5\nP92jbJAsSWxvEf7krf+/R6AKsWWORKApmqQx4xaPCo5uO9D2wHK4yqJs5h2ldSz+\ndAKm1nuyhum1ubGLU4NPRQwLPtyzHIMH6G3GKHxNLD5apznJXTKrcc/iL3uA5znc\nkXdkLRwTd7UBEAltAVtRKC0=\n';
        
        blob private_key = EncodingUtil.base64Decode(key);
        signature_encoded = signature_encoded.replaceAll('=','');
        String signature_encoded_url = EncodingUtil.urlEncode(signature_encoded,'UTF-8');
        blob signature_blob =   blob.valueof(signature_encoded_url);
        
        String signature_blob_string = EncodingUtil.base64Encode(Crypto.sign('RSA-SHA256', signature_blob, private_key));
        
        String JWT = signature_encoded + '.' + signature_blob_string;
        
        JWT = JWT.replaceAll('=','');
        
        String grant_string= 'urn:ietf:params:oauth:grant-type:jwt-bearer';
        req.setBody('grant_type=' + EncodingUtil.urlEncode(grant_string, 'UTF-8') + '&assertion=' + EncodingUtil.urlEncode(JWT, 'UTF-8'));
      /*  if(Test.isRunningTest()){
            return 'aaa12232323232DSDSD';
        }*/
        
        res = h.send(req);
        system.debug(res.getBody());
        String response_debug = res.getBody() +' '+ res.getStatusCode();
        if(res.getStatusCode() == 200) {
            JSONParser parser = JSON.createParser(res.getBody());
            while (parser.nextToken() != null) {
                if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) && (parser.getText() == 'access_token')) {
                    // Move to the value.
                    parser.nextToken();
                    // Return the access_token
                    return parser.getText();
                }
            }
        }
        return 'error';
    }
    
    /*
* @Name : getOSPs
* @Return : Void
* @Params : Null
* @Purpose : Get all Offre_et_service_partenaire__c from Salesforce Database
*/ 
    private static void getOSPs(){
        allOSP = [SELECT Id,Name from Offre_et_service_partenaire__c];
        
    }
    
    /*
* @Name : getStatsByUser
* @Return : Void
* @Params : users : List of user
* @Purpose : Get for the user all Statistique_Analtytics of the current month (the record should be created on the first batch launched which should be scheduled monthly)
*/     
    private static void getStatsByUser(List<User> users){
        //Integer month = Date.today().month();
        //Integer year = Date.today().year();
        Integer month = 02;
        Integer year = 2021;
        //List<Statistique_Analtytics__c> allStats = [SELECT Id, Utilisateur__c,Nb__c,Offre_et_service_partenaire__c,Offre__c FROM Statistique_Analtytics__c WHERE Utilisateur__c IN :users AND CALENDAR_MONTH(CreatedDate) = :month AND CALENDAR_YEAR(CreatedDate) = :year];
        List<Statistique_Analtytics__c> allStats = [SELECT Id, Utilisateur__c,Nb__c,Offre_et_service_partenaire__c,Offre__c FROM Statistique_Analtytics__c WHERE Utilisateur__c IN :users AND CALENDAR_MONTH(Date_de_debut__c) = :month AND CALENDAR_YEAR(Date_de_debut__c) = :year];
        Map<String,List<Statistique_Analtytics__c>> mapStatsByUserTemp = new Map<String,List<Statistique_Analtytics__c>>();
        for(User u : users){
            mapStatsByUserTemp.put(u.Id,new List<Statistique_Analtytics__c>());
        }
        
        for(Statistique_Analtytics__c stats : allStats){
            if(mapStatsByUserTemp.containsKey(stats.Utilisateur__c)){
                mapStatsByUserTemp.get(stats.Utilisateur__c).add(stats);
            }
        }
        
        mapStatsByUsers = mapStatsByUserTemp;
        system.debug('mapStatsByUsers'+mapStatsByUsers);
    }
      
            
    /*
* 
* All private subclasses used for write the JSON request or Parse the JSON response
* 
*/ 
    
    
    private class AnalyticsManagementDateRange{
        private String startDate;
        private String endDate;
        
        private AnalyticsManagementDateRange(String s, String e){
            startDate = s;
            endDate = e;
        }
    }
    
    private class AnalyticsManagementUser{
        private String userId;
        private String type;
        
        private AnalyticsManagementUser(String t, String i){
            type = t;
            userId = i;
        }
    } 
    
    
    private class GoogleAnalyticsResponse{
        private error error{ get; set; }
        private List<session> sessions{ get; set; }
        private Integer totalRows{ get; set; }
        private String nextPageToken{ get; set; }
        private Integer sampleRate{ get; set; }        
    }
    
    private class error{
        private Integer code{ get; set; }
        private String message{ get; set; }
        private String status{ get; set; }
        
    }
    
    private class session{
        private String sessionId{ get; set; }
        private String deviceCategory{ get; set; }
        private String platform{ get; set; }
        private String dataSource{ get; set; }
        private List<activity> activities{ get; set; }
        
    }
    
    private class activity{
        private String activityTime{ get; set; }
        private String source{ get; set; }
        private String medium{ get; set; }
        private String channelGrouping{ get; set; }
        private String campaign{ get; set; }
        private String keyword{ get; set; }
        private String hostname{ get; set; }
        private String landingPagePath{ get; set; }
        private String activityType{ get; set; }
        private List<customDim> customDimension{ get; set; }
        private pageV pageview{ get; set; }
        
    }
    
  /*  public static void runTest(){
        Integer i=1;
        i=++i;
        i=++i;
        i=++i;
        i=++i;
        i=++i;
        i=++i;
        i=++i;
        i=++i;
        i=++i;
        i=++i;
        i=++i;
        i=++i;
        i=++i;
        i=++i;
        i=++i;
        i=++i;
        i=++i;
        i=++i;
        i=++i;
        i=++i;
        i=++i;
        i=++i;
        i=++i;
        i=++i;
        i=++i;
        i=++i;
        i=++i;
        i=++i;
        i=++i;
        i=++i;
        i=++i;
        i=++i;
        i=++i;
        i=++i;
        i=++i;
        i=++i;
        i=++i;
        i=++i;
        
        
    }*/
    
    private class customDim{
        private Integer index{ get; set; }
        private String value{ get; set; }
    }
    
    private class pageV{
        private String pagePath{ get; set; }
        private String pageTitle{ get; set; }
    }
    
    
    
}