/*----------------------------------------------------------------------
-- - Name          : CTRL05_QR_Check
-- - Author        : KM
-- - Description   : Controller de la page VF de vérification de la validité d'un adhérent
--   
-- Maintenance History:
--
-- Date         Name                Version     Remarks 
-- -----------  -----------         --------    ---------------------------------------
-- XX-07-2020   KM                  1.0         Init
-- 03-08-2020   RDB                 1.1         corrections/modifications
---------------------------------------------------------------------------------------
*/
public class CTRL05_QR_Check {
    
    public Boolean isActiveUser {get;set;} 
    public Boolean isClient {get;set;} 
    public Account accAdherent {get;set;}
    public list<Contact> contacts {get;set;}
    
    public CTRL05_QR_Check(){
        String qr_Siret = ApexPages.currentPage().getParameters().get('Siret');
        isActiveUser = false;
        isClient = false;
        
        try {
            system.debug('siret'+qr_Siret);
            // use siret navision Id and use profil adherent 
            //List<Account> listAcc = [SELECT id, Name, Name2__c, sirenSiret__c, BillingStreet, BillingCity, BillingState,BillingCountry,BillingPostalCode, BillingAddress, Profil__c FROM Account WHERE sirenSiret__c ='42826802337699' LIMIT 1];
            List<Account> listAcc = [SELECT id, Name, Name2__c, sirenSiret__c, BillingStreet, BillingCity, BillingState,BillingCountry,BillingPostalCode, BillingAddress, Profil__c FROM Account WHERE sirenSiret__c =:qr_Siret LIMIT 1];
            system.debug('account'+listAcc);
            if(listAcc != null && listAcc.size() > 0) {
                 accAdherent = listAcc[0];
                 contacts = [SELECT Salutation, Email, MobilePhone, Phone, Name , Id FROM Contact WHERE Id in (SELECT contactid FROM user WHERE (accountid = :accAdherent.id AND contactid !=null AND isActive = true))];
               	system.debug('contact'+contacts[0]);
                if(accAdherent.Profil__c == 'Client') isClient = true;
                if(accAdherent.Profil__c == 'Adhérent' || accAdherent.Profil__c == 'Client') {
                    isActiveUser = true;
                } else {
                    isActiveUser = false;
                }
            }
          
        } catch(Exception e) {
            System.debug(e.getMessage());
        }
    }
}