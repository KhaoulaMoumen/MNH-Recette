/*
------------------------------------------------------------------------------------
-- - Name          : JSON2Apex_IBAN
-- - Author        : Khaoula MOUMEN
-- - Description   : http://json2apex.herokuapp.com/
--     
-- Maintenance History:
--
-- Date         Name                Version     Remarks 
-- -----------  -----------         --------    ---------------------------------------
-- 30-04-2021   K.M                 1.0         Init
---------------------------------------------------------------------------------------
*/

public class JSON2Apex_IBAN {

    public class Validations {
		public Chars chars;
		public Chars account;
		public Chars iban;
		public Chars structure;
		public Chars length;
		public Chars country_support;
	}

	public class Errors {
	}

	public Bank_data bank_data;
	public Sepa_data sepa_data;
	public Validations validations;
	public List<Errors> errors;

	public class Sepa_data {
		public String SCT;
		public String SDD;
		public String COR1;
		public String B2B;
		public String SCC;
	}

	public class Bank_data {
		public String bic;
		public String branch;
		public String bank;
		public String address;
		public String city;
		public String state;
		public String zip;
		public String phone;
		public String fax;
		public String www;
		public String email;
		public String country;
		public String country_iso;
		public String account;
		public String bank_code;
		public String branch_code;
	}

	public class Chars {
		public String code;
		public String message;
	}

	
	public static JSON2Apex_IBAN parse(String json) {
		return (JSON2Apex_IBAN) System.JSON.deserialize(json, JSON2Apex_IBAN.class);
	}
}