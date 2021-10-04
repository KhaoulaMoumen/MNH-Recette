/*
------------------------------------------------------------------------------------
-- - Name          : PAD_TEST
-- - Author        : Khaoula MOUMEN
-- - Description   : This class contains unit tests for validating the behavior of Apex classes
--    
-- Maintenance History:
--
-- Date         Name                Version     Remarks 
-- -----------  -----------         --------    ---------------------------------------
-- 13-09-2021   K.M                 1.0         Init
---------------------------------------------------------------------------------------
*/
@isTest
private class PAD_TEST {

    static testMethod void PAD_Main_TestMethod() {
        PAD.log('', '');
        PAD.log('', 1);
        PAD.log(1, '');
        PAD.log(1, 1);
        PAD.log(1);
        PAD.log('');
        PAD.startTimer();
        PAD.stopTimer();
        PAD.limits();
        PAD.myColor(0, 0);
        PAD.myColor(0, 3);
        PAD.myColor(2, 3);
        PAD.myColor(3, 3);
        PAD myPAD = new PAD();
        myPAD.getPAD_logs();
        PAD.canTrigger('AP123');
    }
}