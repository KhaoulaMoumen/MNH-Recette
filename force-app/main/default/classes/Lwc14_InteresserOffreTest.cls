/*----------------------------------------------------------------------
-- - Name          : Lwc14_InteresserOffreTest 
-- - Author        : JGO - jason.goolaup@talan.com
-- - Description   : Classe de test pour LWC14_InteresserOffre
--   
-- Maintenance History:
--
-- Date         Name                Version     Remarks 
-- -----------  -----------         --------    ---------------------------------------
-- 31-07-2020   JGO                 1.0         Init
---------------------------------------------------------------------------------------
*/
@isTest(SeeAllData=false)
public class Lwc14_InteresserOffreTest {
    static testmethod void testRelanceFinOffreDecouverte(){
        LWC14_InteresserOffre.interesserOffre('testOffre');
    }
}