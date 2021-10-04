public without sharing class ESP_AssignLeadToQueue {
    
    @InvocableMethod(label='Run assignment rules')
    public static void LeadAssign(List<Id> LeadIds)
    {
            Database.DMLOptions dmo = new Database.DMLOptions();
            dmo.assignmentRuleHeader.useDefaultRule= true;          
            Lead Leads = [select id from lead where lead.id in :LeadIds LIMIT 1];
            Leads.setOptions(dmo);
            update Leads;
   }
}