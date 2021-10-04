/*
------------------------------------------------------------------------------------
-- - Name          : TR02_Lead
-- - Author        : Khaoula MOUMEN
-- - Description   : Trigger Lead - Before insert/update
--    
-- Maintenance History:
--
-- Date         Name                Version     Remarks 
-- -----------  -----------         --------    ---------------------------------------
-- 26-08-2021   K.M                 1.0         Init
---------------------------------------------------------------------------------------
*/
trigger TR02_Lead on Lead (before insert, after insert, before update) {
    List<Lead> leadsToUpdate = new List<Lead>();
    List<Task> tasksToInsert = new List<Task>();
    
    //GESTION DES TERRITOIRES AVANT CREATION NOUVEAU SUSPECT
    if(Trigger.isBefore && Trigger.isInsert) {
        for(Lead l : Trigger.new){
            // Execute for all leads
            leadsToUpdate.add(l);
        }
    } 
    //GESTION DES TERRITOIRES AVANT MAJ SUSPECT
    if(Trigger.isBefore && Trigger.isUpdate) {
        for(Lead l : Trigger.new){
            //Get only leads who's billing postal code OR the professional situation OR Establishment value has changed
            if((l.Situation_professionnelle__c != Trigger.oldMap.get(l.Id).Situation_professionnelle__c && l.Situation_professionnelle__c == 'Actif dans le secteur de la santé' && l.Etablissement__c != NULL && l.Etablissement__c !='')
               || (l.Etablissement__c != Trigger.oldMap.get(l.Id).Etablissement__c && l.Situation_professionnelle__c == 'Actif dans le secteur de la santé') 
               || l.PostalCode != Trigger.oldMap.get(l.Id).PostalCode) leadsToUpdate.add(l);
            
        }
    }
    
    // GESTION DES DUPLICATIONS 
    if(Trigger.isAfter && Trigger.isInsert) {
        Set<String> setUniqueComb = new Set<String>();
        String uniqueComb;
        
        For(Lead l : trigger.new)
        {
            uniqueComb = l.Name + l.Email + l.Phone + l.MobilePhone;
            setUniqueComb.add(uniqueComb);
        }
        
        if(setUniqueComb.size() > 0 )
        {
            List<Lead> leadsList = [SELECT Id, Name, FirstName, LastName, MobilePhone, Phone, Email 
                                    FROM Lead
                                   ];
            
            Map<String, List<Lead>> mapLeads = new Map<String, List<Lead>> ();
            
            for(Lead piste : leadsList) {
                uniqueComb = piste.FirstName + piste.LastName + piste.Email +piste.MobilePhone;
                if(mapLeads.containsKey(uniqueComb) && mapLeads.get(uniqueComb) != null) {
                    List<Lead> listLead = mapLeads.get(uniqueComb);
                    listLead.add(piste);
                    mapLeads.put(uniqueComb, listLead); 
                }   
                else {
                    mapLeads.put(uniqueComb, new List<Lead> {piste});
                }
            }
            
            For(Lead currentLead : trigger.new)
            {
                uniqueComb = currentLead.FirstName + currentLead.LastName  + currentLead.Email + currentLead.MobilePhone;
                if(mapLeads.containsKey(uniqueComb))
                {
                    Task t = new Task();
                    t.Subject = 'Duplication';
                    t.Status = 'Open';
                    t.Type = 'Suspicion de doublon';
                    t.Priority = 'Normal';
                    t.WhoId = currentLead.ID;
                    t.Description = 'Duplication du suspect '+currentLead.FirstName+' '+ currentLead.LastName+ '(' +currentLead.ID+')'+' avec le(s) suspect(s) : ' +mapLeads.get(uniqueComb);
                    t.OwnerId = UserInfo.getUserId();
                    t.IsReminderSet = true;
                    t.ReminderDateTime = System.now();
                    tasksToInsert.add(t);
                }
            }
        }
    }
    // Insert Duplication Task
    if(tasksToInsert != NULL && tasksToInsert.size() > 0) {
        system.debug('Trigger Lead tasksToInsert '+tasksToInsert);
        insert tasksToInsert;
    }
    
    // Attribute Zones de chalandises to Users 
    if(PAD.canTrigger('AP02')) {
        if(LeadsToUpdate.size() > 0 && LeadsToUpdate != NULL) {
            system.debug('Trigger LeadsToUpdate '+LeadsToUpdate);
            PAD02_GestionTerritoiresLead.affecterTerritoire(LeadsToUpdate);
        }
    }
}