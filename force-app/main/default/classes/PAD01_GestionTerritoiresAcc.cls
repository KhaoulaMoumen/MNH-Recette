/*
------------------------------------------------------------------------------------
-- - Name          : PAD01_GestionTerritoiresAcc
-- - Author        : Khaoula MOUMEN
-- - Description   : Class handler that assigns the zone on person account creation or update (situation professionnelle, billing postal code, etablissement)
--    
-- Maintenance History:
--
-- Date         Name                Version     Remarks 
-- -----------  -----------         --------    ---------------------------------------
-- 04-08-2021   K.M                 1.0         Init
---------------------------------------------------------------------------------------
*/
public class PAD01_GestionTerritoiresAcc {
    
    // Method that assigns the zones to accounts
    public static void affecterTerritoire(List<Account> accounts){
        Map<Id,String> mapEtabDepartments = new Map<Id,String>();
        Map<Id,Zone_de_chalandise__c> mapZonesCommercial = new Map<Id,Zone_de_chalandise__c>();
        List<Account> accountsToUpdate = new List<Account>();
        String currentYear = String.valueOf(System.Today().year());
        
        // Get all etablissements 
        List<Account> etablissements = [SELECT Id, PersonMailingPostalCode 
                                        FROM Account 
                                        WHERE RecordType.DeveloperName = :'Etablissement'
                                       ];
        
        // Get all zones 
        List<Zone_de_chalandise__c> zonesC = [SELECT Id, Commercial__c 
                                              FROM Zone_de_chalandise__c];
        
        // Create Map commercial/zone
        for(Zone_de_chalandise__c zone : zonesC) {
            mapZonesCommercial.put(zone.Id,zone);
        }
        
        // Get all Links etablissments - only links of the current year
        List<LienEtablissement__c> liensEtab = [SELECT Id, Zone_de_chalandise__c, Zone_de_chalandise__r.Annee_de_reference__c, Etablissement__c,
                                                Zone_de_chalandise__r.Commercial__c, Pourcentage_d_affectation__c
                                                FROM LienEtablissement__c
                                                WHERE Zone_de_chalandise__r.Annee_de_reference__c = :currentYear
                                               ];
        // Get all Links departements - only the links of the current year
        List<Lien_departement__c> liensDept = [SELECT Id, Zone_de_chalandise__c, Departement__c,Zone_de_chalandise__r.Commercial__c, Pourcentage_d_affectation__c
                                               FROM Lien_departement__c
                                               WHERE Zone_de_chalandise__r.Annee_de_reference__c = :currentYear
                                              ];
        
        // Create Map etablissments by zone 
        Map<Id, List<Id>> mapEtabByZone = new Map<Id, List<Id>>();
        for(LienEtablissement__c lienEtab : liensEtab) {
            List<Id> temp = mapEtabByZone.get(lienEtab.Etablissement__c);
            if(temp == null) {
                mapEtabByZone.put(lienEtab.Etablissement__c, new List<Id>{lienEtab.Zone_de_chalandise__c});
            } else {
                temp.add(lienEtab.Zone_de_chalandise__c);
            }
        }
        
        // Create Map departments by zone
        Map<String, List<String>> mapDeptByZone = new Map<String, List<String>>();
        for(Lien_departement__c lienDept : liensDept) {
            List<String> temp = mapDeptByZone.get(String.valueOf(lienDept.Departement__c));
            if(temp == null) {
                mapDeptByZone.put(String.valueOf(lienDept.Departement__c), new List<String>{lienDept.Zone_de_chalandise__c});
            } else {
                temp.add(lienDept.Zone_de_chalandise__c);
            }
        }
        
        for(Account acc : accounts){
            String accountZC;
            // first case : if person account is actif and related to an establishement 
            if(acc.Situation_professionnelle__c == 'Actif dans le secteur de la santé' && acc.Etablissement__c != NULL){
                List<Id> listZonesC = mapEtabByZone.get(acc.Etablissement__c);
                system.debug('listZonesC**'+listZonesC);
                if(listZonesC != null && listZonesC.size() > 0) {
                    // Case 1 : only one ZC is eligible, the person account is assigned to this zone
                    if(listZonesC.size() == 1) {
                        acc.Zone_de_chalandise__c = listZonesC[0];
                        accountsToUpdate.add(acc);	
                    } 
                    else if(listZonesC.size() > 0){
                        for(Id zc : listZonesC){
                            // Case 2 : if multiple ZC are eligible and one ZC is assigned to the current user 
                            if(mapZonesCommercial.get(zc).Commercial__c == UserInfo.getUserId()){
                                acc.Zone_de_chalandise__c = zc;
                                accountsToUpdate.add(acc); 
                                
                            }
                            // Case 3 : if multiple ZC are eligible - Random affectation
                            else {
                                acc.Zone_de_chalandise__c = generateRandomEtab(acc.Etablissement__c);
                                accountsToUpdate.add(acc);
                            }
                        }
                    }
                }                    
                // second case : if person account has a postal code and is not actif   
            } else if(acc.PersonMailingPostalCode != NULL){
                List<Id> listZonesC = mapDeptByZone.get((acc.PersonMailingPostalCode).substring(0,2));
                if(listZonesC != null && listZonesC.size() > 0) {
                    system.debug('listZonesC**'+listZonesC);
                    // Case 1 : only one ZC is eligible, the person account is assigned to this zone
                    if(listZonesC.size() == 1) {
                        acc.Zone_de_chalandise__c = listZonesC[0];
                        accountsToUpdate.add(acc);	
                    } 
                    else if(listZonesC.size() > 0){
                        for(Id zc : listZonesC){
                            // Case 2 : if multiple ZC are eligible and one ZC is assigned to the current user 
                            if(mapZonesCommercial.get(zc).Commercial__c == UserInfo.getUserId()){
                                acc.Zone_de_chalandise__c = zc;
                                accountsToUpdate.add(acc); 
                                
                            }
                            // Case 3 : if multiple ZC are eligibles - Random assignment
                            else {
                                acc.Zone_de_chalandise__c = generateRandomDept((acc.PersonMailingPostalCode).substring(0,2));
                                accountsToUpdate.add(acc);
                            }
                        }
                    }
                }  
            } 
        }
    }
    
    // Generate random zone based on poucentage - Etablissement 
    public static Id generateRandomEtab(Id accountId) {
        List<Id> zonesByPourcentage = new List<Id>(); 
        
        List<LienEtablissement__c> liensEtab = [SELECT Id, Pourcentage_d_affectation__c, Zone_de_chalandise__c 
                                                FROM LienEtablissement__c
                                                WHERE Etablissement__c = :accountId
                                               ];
        
        if(liensEtab != NULL && liensEtab.size() > 0){  
            for(LienEtablissement__c link : liensEtab){
                for(Integer i=0; i < link.Pourcentage_d_affectation__c; i++){
                    zonesByPourcentage.add(link.Zone_de_chalandise__c);
                }
            }
        }
        
        Double randomNumber = Math.random(); 
        Integer arrayLength = zonesByPourcentage.size(); 
        Integer randomIndex = (randomNumber *(arrayLength-1)).intValue();
        
        return zonesByPourcentage[randomIndex];
    }
    
    // Generate random zone based on poucentage - Departement 
    public static Id generateRandomDept(String departement) {
        List<Id> zonesByPourcentage = new List<Id>(); 
        
        List<Lien_departement__c> liensDept = [SELECT Id, Pourcentage_d_affectation__c, Zone_de_chalandise__c 
                                                FROM Lien_departement__c
                                                WHERE Departement__c = :departement
                                               ];
        
        if(liensDept != NULL && liensDept.size() > 0){  
            for(Lien_departement__c link : liensDept){
                for(Integer i=0; i < link.Pourcentage_d_affectation__c; i++){
                    zonesByPourcentage.add(link.Zone_de_chalandise__c);
                }
            }
        }
        
        Double randomNumber = Math.random(); 
        Integer arrayLength = zonesByPourcentage.size(); 
        Integer randomIndex = (randomNumber *(arrayLength-1)).intValue();
        
        return zonesByPourcentage[randomIndex];
    }
}