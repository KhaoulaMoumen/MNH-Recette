global class LNC13_GenerateContractPEE_Controller {
    
    @AuraEnabled
    public static Offre_PSH__c getOffreDetails(String offreID){
        // RETURN OFFRE STAGE AND ID 
        return [select Id , Avancement_du_dossier__c, RecordTypeId from Offre_PSH__c where id =: offreID];
        
    }
    
    @AuraEnabled
    public static String generateContract(String offreID, String template){
        system.debug('offreID'+offreID);
        system.debug('template'+template);
        String response;
        SDOC__SDJob__c mergeJob = new SDOC__SDJob__c(
            SDOC__Oid__c = offreID,
            SDOC__runAs__c = UserInfo.getUserName(),
            //SDOC__Status__c = 'Selected',
            //SDOC__type__c = 'Bulk Job - List View',
            SDOC__objAPIName__c = 'Offre_PSH__c',
            SDOC__SendEmail__c = '0',
            SDOC__Start__c = true,
            //SDOC__Doclist__c = 'Contrat Membre M1 Mandat PEE 2020'
            SDOC__Doclist__c = template
        );
        
        try {
            List<SDOC__SDJob__c> jobs = new List<SDOC__SDJob__c>();
            system.debug('mergeJob'+mergeJob);
            jobs.add(mergeJob);
            Database.SaveResult[] srList = Database.insert(jobs, false);
            
            for (Database.SaveResult sr : srList) {
                if (sr.isSuccess()) {
                    System.debug('Successfully inserted job. Job ID: ' + sr.getId());
                    response = 'Le contrat a été bien crée.';
                }
                else {
                    for(Database.Error err : sr.getErrors()) {
                        System.debug(err.getStatusCode() + ': ' + err.getMessage());
                        response = 'une erreur a été rencontrée lors de la génération du contrat.';
                    }
                }
                
            }
            //SDOC.SDBatch.CreateSDoc(UserInfo.getSessionId(),'id='+offreID+'&Object=Offre_PSH__c&doclist='+templateID+'+&sendemail=0&oneclick=1');
            //String docURL = 'https://synerciel--recette.lightning.force.com/apex/SDOC__SDCreate1?id='+offreID+'&Object=Offre_PSH__c&doclist='+templateID+'+sendemail=0&oneclick=1';
            //generateDoc(docURL);
            
            response = 'Le contrat a été bien crée. Il sera disponible sur la fiche dans quelques instants';
        }
        catch (Exception e) {
            System.debug('Error insert :' + e );
            response = 'une erreur a été rencontrée lors de la génération du contrat.';
        }
        return response;
    }
    /*
    public static PageReference generateDoc(String docURL){
        system.debug('url'+docURL);
        PageReference generatePage = new PageReference(docURL);
        generatePage.setRedirect(true);
        return generatePage;
    }*/
    
}