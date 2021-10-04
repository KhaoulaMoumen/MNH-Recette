/*----------------------------------------------------------------------
-- - Name          : Lwc12_DesactiverPartenaireController
-- - Author        : KM
-- - Description   : Controller du bouton permettant de desactiver un utilisateur communaute depuis la fiche Contact
--   
-- Maintenance History:
--
-- Date         Name                Version     Remarks 
-- -----------  -----------         --------    ---------------------------------------
-- 12-08-2020   KM                  1.0         Init
-- 13-08-2020   RDB                 1.1
---------------------------------------------------------------------------------------
*/
public class Lwc12_DesactiverPartenaireController {
    
    /**
     * Désactive le partenaire
     */
    @AuraEnabled
    public static void desactiverPartenaire(String contactId){
        System.debug('[Lwc12_DesactiverPartenaireController][desactiverPartenaire] start');
        
        try {
            AP03_GestionCommunityUsers.desactiverPartenaire(contactId);
        } catch (SynercielException.PermissionException e) {
            System.debug('[Lwc12_DesactiverPartenaireController][desactiverPartenaire] on ne peut pas désactiver le partenaire : pas la permission');
            throw new AuraHandledException(JSON.serialize(e));
        } catch (Exception e) {
            throw e;
        }

    }
}