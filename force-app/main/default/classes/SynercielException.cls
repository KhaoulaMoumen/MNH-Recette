/*----------------------------------------------------------------------
-- - Name          : SynercielException
-- - Author        : RDB
-- - Description   : Exception générique et personnalisée pour le projet Synerciel
--   
-- Maintenance History:
--
-- Date         Name                Version     Remarks 
-- -----------  -----------         --------    ---------------------------------------
-- 13-08-2020   RDB                  1.0         Init
---------------------------------------------------------------------------------------
*/
public virtual class SynercielException extends Exception {

    public static final Integer PARTENAIRE_ACTIVATION_NOT_PERMITTED = 1;
    public static final Integer PARTENAIRE_DEACTIVATION_NOT_PERMITTED = 2;

    public String name;
    public String message;
    public Integer code;

    public SynercielException(String name, String message, Integer code) {
        this.name = name;
        this.message = message;
        this.code = code;
    }  

    public class PermissionException extends SynercielException {

        public PermissionException(String message, Integer code) {
            super('PermissionException', message, code);
        }

    }

}