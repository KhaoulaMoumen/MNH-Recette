/*
Trigger that calculate nbr of factures impayes et regles sur un compte
CreatedBy : MOUMEN Khaoula
@Email : khaoula.moumen@talan.com
CreateDate : 12/03/2020
*/
trigger TR03_CommandeFacture on Facture__c (before insert, after insert, after update, after delete) {
   
    if(Trigger.isAfter && Trigger.isInsert) {
        //List<Facture__c> factures = CTRL03_CommandeFactureHandler.fillAccountField(Trigger.New);
        //CTRL03_CommandeFactureHandler.CalculateNbrFactures(factures, 0);
        CTRL03_CommandeFactureHandler.CalculateNbrFactures(Trigger.New, 0);
    }
    if(Trigger.isAfter && Trigger.isUpdate) {
        CTRL03_CommandeFactureHandler.CalculateNbrFactures(Trigger.New, 1);
    }
    if(Trigger.isAfter && Trigger.isDelete) {
        CTRL03_CommandeFactureHandler.CalculateNbrFactures(Trigger.old, 2);
    }
}