/*----------------------------------------------------------------------
-- - Name          : Lwc07_ActiverPartenaireController
-- - Author        : RDB
-- - Description   : Controller du bouton permettant d'activer un partenaire depuis la fiche Contact
--   
-- Maintenance History:
--
-- Date         Name                Version     Remarks 
-- -----------  -----------         --------    ---------------------------------------
-- 31-07-2020   RDB                 1.0         Init
---------------------------------------------------------------------------------------
*/
public with sharing class Lwc07_ActiverPartenaireController {
    

    @AuraEnabled
    public static void activerPartenaire(Id contactId){
        System.debug('[Lwc07_ActiverPartenaireController][activatePartenaire] start');
        
        try {
            AP03_GestionCommunityUsers.activerPartenaire(contactId);
        } catch (SynercielException.PermissionException e) {
            System.debug('[Lwc07_ActiverPartenaireController][activatePartenaire] on ne peut pas activer le partenaire : pas la permission');
            throw new AuraHandledException(JSON.serialize(e));
        } catch (Exception e) {
            throw e;
        }
    }

}