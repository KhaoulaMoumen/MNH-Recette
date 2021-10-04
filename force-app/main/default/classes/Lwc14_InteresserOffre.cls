/*----------------------------------------------------------------------
-- - Name          : Lwc14_InteresserOffre
-- - Author        : JGO - jason.goolaup@talan.com
-- - Description   : Controller du bouton permettant de créé un case
--   
-- Maintenance History:
--
-- Date         Name                Version     Remarks 
-- -----------  -----------         --------    ---------------------------------------
-- 31-07-2020   JGO                 1.0         Init
---------------------------------------------------------------------------------------
*/
public with sharing class Lwc14_InteresserOffre {
    

    @AuraEnabled
    public static void interesserOffre(String offreName){
        System.debug('[Lwc14_InteresserOffre][interesserOffre] start');

        try {
                String currentUserId = UserInfo.getUserId();
                User currentUser = [SELECT contactID, accountId, contact.MobilePhone, contact.email FROM User where id =: currentUserId];
                
                Case c = new Case();
                c.Status = 'Nouveau';
                c.Canal_de_reception__c = 'Espace Pro Synerciel';
                c.Origin = 'Adhérent Synerciel';
                c.Selectionnez_un_sujet_Adh__c ='Autre';
                c.Type = 'Intérêt pour une offre';
                c.Priority = 'Standard';
                c.Subject = 'Intérêt pour un service Synerciel';
                c.Description = 'Je suis intéressé(e) par le service ' + offreName + ' et je souhaiterais être recontacté(e) à ce sujet';

                If(currentUser != null){
                    c.ContactId = currentUser.contactID;
                    c.AccountId = currentUser.AccountId;
                    System.debug('[Lwc14_InteresserOffre][interesserOffre] currentUserInfo:' + currentUser);
                }

                Database.insert(c);
              /* */
              
        } catch (SynercielException.PermissionException e) {
            System.debug('[Lwc14_InteresserOffre][activatePartenaire] on ne peut pas créé le case : pas la permission');
            throw new AuraHandledException(JSON.serialize(e));
        } catch (Exception e) {
            throw e;
        }
    }

}