/*
CreatedBy : MOUMEN Khaoula
@Email : khaoula.moumen@talan.com
CreateDate : 07/07/2020
*/
trigger TR05_User on User (before insert, after update) {
    Set<ID> accountsToUpdate = new Set<ID>(); 
    if(Trigger.isBefore && Trigger.isInsert){
        CTRL04_UserTriggerHandler.Meth02_checkNickname(Trigger.new);
        CTRL04_UserTriggerHandler.Meth03_checkUsername(Trigger.new);
    }
    if(Trigger.isAfter && Trigger.isUpdate) {
        for(User u : Trigger.new){
            //if(u.IsActive == false && Trigger.oldMap.get(u.Id).IsActive == true && (u.ProfileId == Label.ESP_Partenaire_Profil_ID || u.ProfileId == Label.ESP_Adherent_Profil_ID )) accountsToUpdate.add(u.AccountId);
            if(u.IsActive == false && Trigger.oldMap.get(u.Id).IsActive == true && u.ProfileId == Label.ESP_Partenaire_Profil_ID) accountsToUpdate.add(u.AccountId);
        }
    }
    if(accountsToUpdate.size()>0) CTRL04_UserTriggerHandler.Meth01_afterDisablingPartners(accountsToUpdate);
}