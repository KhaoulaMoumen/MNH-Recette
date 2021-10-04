/*
------------------------------------------------------------------------------------
-- - Name          : DataFactory
-- - Author        : Khaoula MOUMEN
-- - Description   : DATA FACTORY CLASS
--    
-- Maintenance History:
--
-- Date         Name                Version     Remarks 
-- -----------  -----------         --------    ---------------------------------------
-- 13-09-2021   K.M                 1.0         Init
---------------------------------------------------------------------------------------
*/
public class DataFactory {
    
     // CREATE LEADS
    public static List<Lead> createLeads(Integer n, Boolean doInsert) {

        List<Lead> leadsToInsert = new List<Lead>();
		Lead lead;

		for(Integer i=0; i<n; i++)
		{
            lead = new Lead(
                Firstname = 'Test'+i,
                Lastname = 'Lead',
                Salutation = 'M.',
                Company = 'TestCompany'+i,
                Email = 'talanTest'+i+'@mnh.com',
                Phone = '060606060'+i,
                Status = 'Pré-qualification',
                Street = 'Rue Test'+i,
                PostalCode = '7510'+i,
                City = 'Paris',
                Country = 'France'
			); 
    		leadsToInsert.add(lead);
		}

		if(doInsert) insert leadsToInsert;
        
        return leadsToInsert;
    }
    
    // CREATE PersonAccount (Prospect/Client/Ancien Client/Ayant droit/Correspondant MNH)
    public static List<Account> createPersonAccounts(Integer n, String rt, Boolean doInsert) {

        List<Account> accountsToInsert = new List<Account>();
		Account acc;

		for(Integer i=0; i<n; i++)
		{
            acc = new Account(
                Name = 'Account TEST'+i,
                Type = 'Adhérent',
                PersonMobilePhone = '0606060606',
                PersonMailingStreet = 'Shipping street test'+i,
                PersonMailingPostalCode = '5900'+i,
                PersonMailingCity = 'Shipping city test'+i,
                PersonMailingCountry ='France',
                Website = 'www.testTalan'+i+'.com',
                NumberOfEmployees = 100+i,
                AnnualRevenue = 1000+i,
                RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(rt).getRecordTypeId()
            ); 
            
    		accountsToInsert.add(acc);
		}

		if(doInsert) insert accountsToInsert;
        
        return accountsToInsert;
    }
    
    // CREATE Account (GHT/Etablissemnt)
    public static List<Account> createAccounts(Integer n, String rt, Boolean doInsert) {

        List<Account> accountsToInsert = new List<Account>();
		Account acc;

		for(Integer i=0; i<n; i++)
		{
            acc = new Account(
                Name = 'Account TEST'+i,
                Type = 'Adhérent',
                Phone = '0606060606',
                BillingStreet = 'Shipping street test'+i,
                BillingPostalCode = '5900'+i,
                BillingCity = 'Shipping city test'+i,
                BillingCountry ='France',
                Website = 'www.testTalan'+i+'.com',
                NumberOfEmployees = 100+i,
                AnnualRevenue = 1000+i,
                RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(rt).getRecordTypeId()
            ); 
            
    		accountsToInsert.add(acc);
		}

		if(doInsert) insert accountsToInsert;
        
        return accountsToInsert;
    }

}