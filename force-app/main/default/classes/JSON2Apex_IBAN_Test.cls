@IsTest
public class JSON2Apex_IBAN_Test {
	
		
	static testMethod void testParse() {
		String json = '{\"bank_data\":{\"bic\":\"BNPAFRPPXXX\",\"branch\":null,\"bank\":\"BNP PARIBAS\",\"address\":\"7 PL LOUIS BARTHOU\",\"city\":\"BORDEAUX\",\"state\":null,\"zip\":\"33000\",\"phone\":null,\"fax\":null,\"www\":null,\"email\":null,\"country\":\"FRANCE\",\"country_iso\":\"FR\",\"account\":\"00010127183\",\"bank_code\":\"30004\",\"branch_code\":\"00321\"},\"sepa_data\":{\"SCT\":\"YES\",\"SDD\":\"YES\",\"COR1\":\"YES\",\"B2B\":\"YES\",\"SCC\":\"NO\"},\"validations\":{\"chars\":{\"code\":\"006\",\"message\":\"IBAN does not contain illegal characters\"},\"account\":{\"code\":\"002\",\"message\":\"Account Number check digit is correct\"},\"iban\":{\"code\":\"001\",\"message\":\"IBAN Check digit is correct\"},\"structure\":{\"code\":\"005\",\"message\":\"IBAN structure is correct\"},\"length\":{\"code\":\"003\",\"message\":\"IBAN Length is correct\"},\"country_support\":{\"code\":\"007\",\"message\":\"Country supports IBAN standard\"}},\"errors\":[]}';
		JSON2Apex_IBAN obj = JSON2Apex_IBAN.parse(json);
		System.assert(obj != null);
	}
}