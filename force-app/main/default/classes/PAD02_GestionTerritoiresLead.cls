/*
------------------------------------------------------------------------------------
-- - Name          : PAD02_GestionTerritoiresLead
-- - Author        : Khaoula MOUMEN
-- - Description   : Class handler that attributes the zone on person account creation or update (situation professionnelle, billing postal code, etablissement)
--    
-- Maintenance History:
--
-- Date         Name                Version     Remarks 
-- -----------  -----------         --------    ---------------------------------------
-- 27-08-2021   K.M                 1.0         Init
---------------------------------------------------------------------------------------
*/
public class PAD02_GestionTerritoiresLead {
    
    // Method that assigns the zones to leads
    public static void affecterTerritoire(List<Lead> leads){
        Map<Id,String> mapEtabDepartments = new Map<Id,String>();
        Map<Id,Zone_de_chalandise__c> mapZonesCommercial = new Map<Id,Zone_de_chalandise__c>();
        List<Lead> leadsToUpdate = new List<Lead>();
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
        
        for(Lead l : leads){
            String leadZC;
            // first case : if lead is actif and related to an establishement 
            if(l.Situation_professionnelle__c == 'Actif dans le secteur de la santé' && l.Etablissement__c != NULL){
                List<Id> listZonesC = mapEtabByZone.get(l.Etablissement__c);
                system.debug('listZonesC**'+listZonesC);
                if(listZonesC != null && listZonesC.size() > 0) {
                    // Case 1 : only one ZC is eligible, the lead is assigned to this ZC
                    if(listZonesC.size() == 1) {
                        l.Zone_de_chalandise__c = listZonesC[0];
                        leadsToUpdate.add(l);	
                    } 
                    else if(listZonesC.size() > 0){
                        for(Id zc : listZonesC){
                            // Case 2 : if multiple ZC are eligible and one ZC is assigned to the current user 
                            if(mapZonesCommercial.get(zc).Commercial__c == UserInfo.getUserId()){
                                l.Zone_de_chalandise__c = zc;
                                leadsToUpdate.add(l); 
                                
                            }
                            // Case 3 : if multiple ZC are eligible - Random assignment
                            else {
                                l.Zone_de_chalandise__c = generateRandomEtab(l.Etablissement__c);
                                leadsToUpdate.add(l);
                            }
                        }
                    }
                }                    
                // second case : if lead has a postal code and is not actif   
            } else if(l.PostalCode != NULL){
                List<Id> listZonesC = mapDeptByZone.get((l.PostalCode).substring(0,2));
                if(listZonesC != null && listZonesC.size() > 0) {
                    system.debug('listZonesC**'+listZonesC);
                    // Case 1 : only one ZC is eligible, the lead is assigned to the ZC
                    if(listZonesC.size() == 1) {
                        l.Zone_de_chalandise__c = listZonesC[0];
                        leadsToUpdate.add(l);	
                    } 
                    else if(listZonesC.size() > 0){
                        for(Id zc : listZonesC){
                            // Case 2 : if multiples ZC are eligible and one ZC is assigned to the current user 
                            if(mapZonesCommercial.get(zc).Commercial__c == UserInfo.getUserId()){
                                l.Zone_de_chalandise__c = zc;
                                leadsToUpdate.add(l); 
                                
                            }
                            // Case 3 : if multiples ZC are eligible and one ZC - Random assignation
                            else {
                                l.Zone_de_chalandise__c = generateRandomDept((l.PostalCode).substring(0,2));
                                leadsToUpdate.add(l);
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
        // Get all link etablissements 
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