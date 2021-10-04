public with sharing class ESP_ConvertFileToCSV {
    
    @InvocableMethod(label='Convert CSV File to Records')
    public static Response[] convert (Request[] inputs) {
        Response[] responseList = new Response[]{};
            
            for (Request curInput : inputs) {
                
                if (curInput.contentDocumentId == null && curInput.contentDocumentIdList == null) {
                    throw new FlowCustomException('You need to provide either a single ContentDocument Id OR a list of ContentDocumentIds as inputs to this Flow action.');
                }
                else {
                    if (curInput.contentDocumentId != null)
                        curInput.contentDocumentIdList.add(curInput.contentDocumentId);
                }
                for (String curContentDocumentId : curInput.contentDocumentIdList){
                    
                    Map<String, String> mapColumns = new Map<String, String>();
                    Map<String, Id> mapAccSiret = new Map<String, Id>();
                    
                    // GET THE COLUMN  AND FIELD API NAME CORRESP
                    List<CommunityFileMapping__mdt> dependances = [Select MasterLabel, fieldApiName__c   FROM CommunityFileMapping__mdt];
                    For(CommunityFileMapping__mdt dep : dependances )
                    {
                        mapColumns.put( dep.get('MasterLabel').toString(), dep.get('fieldApiName__c').toString());
                    }
                    system.debug('mapColumns'+mapColumns);
                    
                    // GET THE ACCOUNT BY SIRET
                    List<Account> accounts = [SELECT Id, sirenSiret__c FROM Account];
                    For(Account acc : accounts)
                    {
                        mapAccSiret.put( acc.sirenSiret__c, acc.Id);
                    }
                    system.debug('mapAccSiret'+mapAccSiret);
                    
                    system.debug('curInput.objectApiName'+curInput.objectApiName);
                    
                    SObjectType sObjType = ((SObject)Type.forName(curInput.objectApiName).newInstance()).getSObjectType();         
                    map<String,SObjectField> fieldMap = sObjType.getDescribe().fields.getMap();
                    
                    Blob csvBlobContent = getCsvContent(curContentDocumentId);
                    String csvStringContent = blobToString(csvBlobContent, 'ISO-8859-1');
                    csvStringContent = csvStringContent.replaceAll('(\r\n|\r)','\n');
                    
                    String[] csvRows = csvStringContent.split('\n');
                    String[] fields = csvRows[0].split(';');
                    csvRows.remove(0);
                    map<String,Schema.DisplayType> fieldToFieldTypeMap = new map<String,Schema.DisplayType>();
                    
                    Response output = new Response();
                    output.rowsfailed = '';
                    
                    for (String field : fields) {
                        
                        if(field.contains('Quanti')) field = 'Quantité';
                        if(field == ' Montant Commande') field = 'Montant Commande';
                        if(field.contains('Date de DEBUT')) field = 'Date de DEBUT de validite';
                        if(field.contains('Date de FIN')) field = 'Date de FIN de validite';
                        if(field.contains('Date de LIVRAISON')) field = 'Date de LIVRAISON (pour les véhicules)';
                        if(field.contains('Code article')) field = 'Code article';
                        if(field.contains('Code partenaire')) field = 'Code partenaire';
                        
                        String fieldApiName = mapColumns.get(field);
                        
                        if(field == 'SIRET'){
                            fieldToFieldTypeMap.put(field, getFieldType(fieldMap, 'Adherent__c'));
                            field = 'Adherent__c';                            
                        } 
                        
                        else {
                            fieldToFieldTypeMap.put(field, getFieldType(fieldMap, fieldApiName));
                        } 
                    }
                    system.debug('fields'+fields);
                   
                    output.convertedCSVRows = new SObject[]{};
                        for(String row : csvRows) {
                            system.debug('csvRow'+row);
                            System.debug(csvRows.indexOf(row));
                            SObject obj = sObjType.newSObject();
                            String[] fieldInputValues = row.split(';',11);
                            Boolean lineFailed = false;
                            if(fieldInputValues.size() > 0){
                                
                            for (Integer i = 0; i < fields.size(); i++) {
                                String fieldValue = fieldInputValues[i];
                                
                                if(fields[i].contains('Quanti')) fields[i] = 'Quantité';
                                if(fields[i] == ' Montant Commande') fields[i] = 'Montant Commande';
                                if(fields[i].contains('Date de DEBUT')) fields[i] = 'Date de DEBUT de validite';
                                if(fields[i].contains('Date de FIN')) fields[i] = 'Date de FIN de validite';
                                if(fields[i].contains('Date de LIVRAISON')) fields[i] = 'Date de LIVRAISON (pour les véhicules)';
                                if(fields[i].contains('Code article')) fields[i] = 'Code article';
                                if(fields[i].contains('Code partenaire')) fields[i] = 'Code partenaire';
                                
                                Schema.DisplayType fieldType = fieldToFieldTypeMap.get(fields[i]);
                                
                                
                                
                                if(fields[i] == 'SIRET') {
                                    fieldType = fieldToFieldTypeMap.get('Adherent__c');
                                    
                                    system.debug('fields  siret'+fields[i]);
                                	system.debug('fieldValue'+fieldValue);
                                	system.debug('fieldType'+fieldType);
                                	system.debug('adherent'+mapAccSiret.get(fieldValue));
                                    
                                    if(mapAccSiret.get(fieldValue) != NULL) obj.put('Adherent__c', getConvertedFieldValue(fieldType, mapAccSiret.get(fieldValue)));
                                    else {
                                        lineFailed = true;
                                        output.rowsfailed += (csvRows.indexOf(row)+1) +' ';
                                    }
                                }
                                else obj.put( mapColumns.get(fields[i]), getConvertedFieldValue(fieldType, fieldValue));
                                if(curInput.commandePartenaireId != NULL) obj.put( 'commande_partenaire_recue__c', curInput.commandePartenaireId);
                                if(curInput.partenaireId != NULL) obj.put( 'Partenaire__c', curInput.partenaireId);
                            }
                            }
                            system.debug('object***'+obj);
                            if(!lineFailed) output.convertedCSVRows.add(obj);
                        }
                    responseList.add(output);
                }            
                
                
            }
        return responseList;
    }
    
    static Blob getCsvContent( String contentDocumentId) {        
        ContentVersion csvFile = [SELECT 
                                  VersionData 
                                  FROM ContentVersion 
                                  WHERE ContentDocumentId = :contentDocumentId 
                                  AND IsLatest = true
                                 ];
        System.debug('contentDocumentId is: ' + contentDocumentId);
        System.debug('csvFile is: ' + csvFile);
        return csvFile.VersionData;
    }
    
    /* Converting the CSV file input(BLOB format) to a string */
    static String blobToString(Blob input, String inCharset){
        String hex = EncodingUtil.convertToHex(input);
        System.assertEquals(0, hex.length() & 1);
        final Integer bytesCount = hex.length() >> 1;
        String[] bytes = new String[bytesCount];
        for(Integer i = 0; i < bytesCount; ++i)
            bytes[i] =  hex.mid(i << 1, 2);
        return EncodingUtil.urlDecode('%' + String.join(bytes, '%'), inCharset);
    } 
    
    static Object getConvertedFieldValue(Schema.DisplayType fieldType, String fieldValue){
        Object convertedFieldValue;
        switch on fieldType {//Setting Field value based on the field data type
            when BOOLEAN {
                convertedfieldValue = String.isEmpty(fieldValue) ? false : Boolean.valueOf(fieldValue);
            }
            when DOUBLE {
                convertedfieldValue = String.isEmpty(fieldValue) ? null : Decimal.valueOf(fieldValue);
            }
            when CURRENCY {
                convertedfieldValue = String.isEmpty(fieldValue) ? null : Decimal.valueOf(fieldValue);
            }
            when INTEGER {
                convertedfieldValue = String.isEmpty(fieldValue) ? null : Integer.valueOf(fieldValue);
            }
            when DATE {
                convertedfieldValue = String.isEmpty(fieldValue) ? null : date.parse(fieldValue);
            }
            when else { 
                convertedfieldValue = fieldValue;
            }
        }
        return convertedFieldValue; 
    }
    
    @TestVisible
    static Schema.DisplayType getFieldType(map<String, SObjectField> fieldMap, String fieldApiName) {
        if(fieldMap.get(fieldApiName) == null) {
            throw new FlowCustomException('Invalid Field Error: '+fieldApiName + '. Please double check the API name of the field.');
        }
        return fieldMap.get(fieldApiName).getDescribe().getType();
    }
    
    public class FlowCustomException extends Exception{}
    
    public class Request{
        
        public Request() {
            contentDocumentIdList = new List<String>();
        }
        
        @InvocableVariable(label='Object API Name' required=true)
        public string objectApiName;
        
        @InvocableVariable(label='Single CSV File ID')
        public string contentDocumentId;
        
        @InvocableVariable(label='List of CSV File IDs')
        public List<String> contentDocumentIdList;
        
        @InvocableVariable(label='Commande partenaire recue Id' required=true)
        public string commandePartenaireId;

        @InvocableVariable(label='Partenaire Id' required=true)
        public string partenaireId;        
    }
    
    public class Response{
        @InvocableVariable(label='List(collection) of Records')
        public List<SObject> convertedCSVRows;
        
         @InvocableVariable(label='Number of rows failed to process')
        public String rowsfailed;
    }
}