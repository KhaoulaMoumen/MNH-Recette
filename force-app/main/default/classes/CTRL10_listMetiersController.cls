public class CTRL10_listMetiersController {
    @AuraEnabled
    public static list <Metier_de_reference__c> getmetiers(String userId){
        User acc = [select Accountid from user where id =: userId limit 1];
        String accountId =acc.Accountid;
        list <Metier_de_reference__c> metiers = [select Metier__c from Metier_de_reference__c where Compte__c =: accountId];
        return metiers;
    }
}