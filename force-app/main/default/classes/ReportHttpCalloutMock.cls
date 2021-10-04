@isTest
global class ReportHttpCalloutMock implements HttpCalloutMock {

    global HTTPResponse respond(HTTPRequest request) {

        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json');
        response.setBody('this is a test');
        response.setStatusCode(200);
        return response; 
    }
}