public class CTRL09_listCCHController {
    @AuraEnabled
    public static list <Cercle_confort_habitat_adh_rent__c> getCCHs(String userId){
        User acc = [select Accountid from user where id =: userId limit 1];
        String accountId =acc.Accountid;
        list <Cercle_confort_habitat_adh_rent__c> CCHs = [select Cercle_Confort_Habitat__r.Name from Cercle_confort_habitat_adh_rent__c where Compte__c =: accountId];
        return CCHs;
    }

}