/*----------------------------------------------------------------------
-- - Name          : BA17_ReconductionOffre_Relance2
-- - Author        : KM
-- - Description   : à J-1 mois, opportunity/oli/quote/qli/contrat sont créés pour les contrat actifs (Reconduction non souhaitee == false) && Desactivate Users le J+1 jour si reconduction non souhaitee
--   
-- Maintenance History:
--
-- Date         Name                Version     Remarks 
-- -----------  -----------         --------    ---------------------------------------
-- 09-03-2021   KM                  1.0         Init
---------------------------------------------------------------------------------------
*/
global class BA17_ReconductionOffre_Relance2 implements Database.Batchable<sObject>, Database.Stateful {
    public String query;
    private List<Account> accountList;
    List<Account> accountToUpdate = new List<Account>();
    Date TODAY = Date.today();
    String offreRecordTypeId = Label.LABS_SF_Contract_OffreId;
    String accClient = 'Client';
    
    
    global Database.QueryLocator start(Database.BatchableContext bc){
        
        this.accountList = new List<Account>();
        
        this.query = 'SELECT Id, Categorie_de_metier__c, OwnerId, Name, Profil__c, (SELECT Id, Date_de_reconduction__c, Statut__c, RecordTypeId, Date_de_relance__c, Reconduction_non_souhaitee__c, EndDate__c FROM Conventions_annuelle__r WHERE RecordTypeId = :offreRecordTypeId ORDER BY EndDate__c DESC LIMIT 1) FROM Account WHERE Profil__c =:accClient';
        
        return Database.getQueryLocator(this.query);
    }
    
    // LOGIC IS IMPLEMENTED FOR A SMALL SCOPE TO AVOID GOVERMENT LIMITATIONS = BATCH MUST BE EXECUTED FOR 1 ACCOUNT 
    global void execute(Database.BatchableContext BC, List<Account> scope) {
        
        
        for(Account acc : scope) {
            system.debug('I am here');
            if (!acc.Conventions_annuelle__r.isEmpty()) {
                if (acc.Conventions_annuelle__r[0].Statut__c == 'Actif' && acc.Conventions_annuelle__r[0].Date_de_reconduction__c == TODAY.addMonths(1) && acc.Conventions_annuelle__r[0].Reconduction_non_souhaitee__c == false) {
                    
                    /** CREATE OPPORTUNITY RECONDUCTION **/
                    Opportunity opp = new Opportunity();
                    opp.Name = 'OFFRECOM_'+(acc.Conventions_annuelle__r[0].Date_de_reconduction__c).year()+'_'+acc.Name;
                    opp.RecordTypeId = Label.LABS_SF_Opp_RT_OCId;
                    opp.AccountId = acc.Id;
                    opp.Annee__c = (acc.Conventions_annuelle__r[0].Date_de_reconduction__c).year();
                    opp.Categorie_de_metier__c = acc.Categorie_de_metier__c;
                    opp.StageName = 'Terminé';
                    opp.OwnerId = acc.OwnerId;
                    opp.Date_acceptation_CGV__c = acc.Conventions_annuelle__r[0].Date_de_reconduction__c;
                    opp.Product__c = Label.LABS_SF_OPTIMProductID;
                    opp.Mode_de_r_glement__c = 'Prélèvement en 1 fois';
                    opp.Conditions_de_paiement__c = 'IMMEDIAT';
                    opp.Pricebook2Id = Label.LABS_SF_PricebookClient;
                    opp.CloseDate = TODAY;
                    opp.Produit__c = 'OPTIM\'ACHAT';
                    opp.TECH_isOffreCom__c = true;
                    opp.TECH_ReconductionOffre__C = true;
                    insert opp;
                    
                    /** CREATE OPPORTUNITY LINE ITEM **/
                    OpportunityLineItem oli = new OpportunityLineItem();
                    oli.OpportunityId = opp.Id;
                    oli.Quantity = 1;
                    oli.PricebookEntryId = Label.LABS_SF_OPTIMACHAT;
                    oli.TotalPrice = Integer.valueOf(Label.LABS_SF_OPTIMAT_Price);
                    insert oli;
                    
                    /** CREATE QUOTE **/
                    Quote q = new Quote();
                    q.Status = 'Préparation';
                    q.Name =   'CMD_Offre commerciale -'+(opp.Date_acceptation_CGV__c).year()+'_'+acc.Name;
                    q.OpportunityId = opp.Id;
                    q.Echelonnement__c = '12M-PDT';
                    q.Mode_de_r_glement__c = 'Prélèvement en 1 fois';
                    q.Conditions_de_paiement__c = 'IMMEDIAT';
                    q.Date_1ere_echeance__c = opp.Date_acceptation_CGV__c;
                    q.Pricebook2Id = Label.LABS_SF_PricebookClient;
                    q.Date_de_commande_effective__c = opp.Date_acceptation_CGV__c;
                    insert q;
                    
                    /** CREATE QUOTE LINE ITEM **/
                    QuoteLineItem qli = new QuoteLineItem();
                    qli.PricebookEntryId = Label.LABS_SF_OPTIMACHAT;
                    qli.QuoteId = q.Id;
                    qli.Product2Id = Label.LABS_SF_OPTIMProductID;
                    qli.UnitPrice = Integer.valueOf(Label.LABS_SF_OPTIMAT_Price);
                    qli.Quantity = 1;
                    insert qli;
                    
                    /** CREATE CONTRACTS **/ 
                    Convention_annuelle__c contrat = new Convention_annuelle__c();
                    contrat.RecordTypeId = Label.LABS_SF_Contract_OffreId;
                    contrat.Ann_e__c = opp.Annee__c;
                    contrat.Name = 'CTR_ OFFRE_'+opp.Annee__c+'_'+acc.Name;
                    contrat.Produit__c = Label.LABS_SF_OPTIMProductID;
                    contrat.Montant_HT__c = Integer.valueOf(Label.LABS_SF_OPTIMAT_Price);
                    contrat.Adherent__c = opp.AccountId;
                    contrat.conventionSignatureDate__c = opp.Date_de_signature_convention__c;
                    contrat.Date_de_signature_convention_Synerciel__c = opp.Date_de_signature_convention_Synerciel__c;
                    contrat.Recrutement_Reconventionnement__c = opp.Id;
                    contrat.Commande_vente__c = q.Id;
                    contrat.Date_debut_contrat__c = opp.Date_acceptation_CGV__c;
                    contrat.EndDate__c = (opp.Date_acceptation_CGV__c).addMonths(12);
                    contrat.Date_de_reconduction__c = (opp.Date_acceptation_CGV__c).addMonths(12);
                    contrat.Date_de_relance__c = (opp.Date_acceptation_CGV__c).addMonths(10);
                    insert contrat;
                    
                }
                if (acc.Conventions_annuelle__r[0].EndDate__c == TODAY.addDays(-1) && acc.Conventions_annuelle__r[0].Reconduction_non_souhaitee__c == true){
                    acc.Profil__c = 'Ancien client';
                    accountToUpdate.add(acc);
                }
            }
        }
   
    }
    
    global void finish(Database.BatchableContext BC){
        // UPDATE THE ACCOUNTS
        Set<Account> accountToUpdateSet = new Set<Account>(accountToUpdate);
        List<Account> comptesToUpdate = new List<Account>(accountToUpdateSet);
        
        System.debug('comptesToUpdate :' + comptesToUpdate);
        if(comptesToUpdate.size() > 0) System.enqueueJob(new QueueClass(comptesToUpdate));
        
    }
    
    public class QueueClass implements Queueable {
        List<Account> comptesToUpdate;
        public QueueClass(List<Account> comptesToUpdate) {
            this.comptesToUpdate = comptesToUpdate;
        }
        public void execute(QueueableContext context) {
            
            try {
                System.debug('comptesToUpdate :' + comptesToUpdate);
                update comptesToUpdate;
            } catch (Exception e) {
                System.debug('Error update :' + e );
            }
        }
    }
}