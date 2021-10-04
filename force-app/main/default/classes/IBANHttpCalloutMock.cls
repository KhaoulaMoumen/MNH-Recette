@isTest
global class IBANHttpCalloutMock implements HttpCalloutMock {

   /* global HTTPResponse respond(HTTPRequest request) {

        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json');
        response.setBody('"bic":"CMCIFRPPXXX","branch":null,"bank":"CREDIT INDUSTRIEL ET COMMERCIAL CIC","address":"95 AV DU BAC","city":"LA VARENNE ST HILAIRE","state":null,"zip":"94210","phone":null,"fax":null,"www":null,"email":null,"country":"FRANCE","country_iso":"FR","account":"00020063801","bank_code":"30066","branch_code":"10866"},"sepa_data":{"SCT":"YES","SDD":"YES","COR1":"YES","B2B":"YES","SCC":"NO"},"validations":{"chars":{"code":"006","message":"IBAN does not contain illegal characters"},"account":{"code":"002","message":"Account Number check digit is correct"},"iban":{"code":"001","message":"IBAN Check digit is correct"},"structure":{"code":"005","message":"IBAN structure is correct"},"length":{"code":"003","message":"IBAN Length is correct"},"country_support":{"code":"007","message":"Country supports IBAN standard"}},"errors":[]');
        response.setStatusCode(200);
        return response; 
    }
    */
    HttpResponse[] responses = new HttpResponse[0];
    public void addResponse(HttpResponse response) {
        responses.add(response);
    }
    public HttpResponse respond(HttpRequest request) {
        return responses.remove(0);
    }
}