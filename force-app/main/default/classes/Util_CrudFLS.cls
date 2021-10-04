global with sharing class Util_CrudFLS {
	public static Boolean isAccessible(String obj, List<String> fieldsToCheck) {
		Schema.SObjectType objType = getSObject(obj);
		if (!objType.getDescribe().isAccessible()) {
			return false;
		}
		Map<String, Schema.SObjectField> m = getFieldsMap(objType);
		
		for (String fieldToCheck : fieldsToCheck) {
			if (!m.get(fieldToCheck).getDescribe().isAccessible()) {
				return false;
			}
		}

		return true;
	}

	public static Boolean isFullRight(String obj, List<String> fieldsToCheck){
		return isAccessible(obj,fieldsToCheck) && isCreateable(obj,fieldsToCheck) && isUpdateable(obj,fieldsToCheck) && isDeletable(obj);
	}

	public static Boolean isUpsertable(String obj, List<String> fieldsToCheck){
		return isCreateable(obj,fieldsToCheck) && isUpdateable(obj,fieldsToCheck);
	}

	public static Boolean isCreateable(String obj, List<String> fieldsToCheck) {
		Schema.SObjectType objType = getSObject(obj);
		if (!objType.getDescribe().isCreateable()) {
			return false;
		}

		Map<String, Schema.SObjectField> m = getFieldsMap(objType);
		for (String fieldToCheck : fieldsToCheck) {
			if (!m.get(fieldToCheck).getDescribe().isCreateable()) {
				return false;
			}
		}

		return true;
	}

	public static Boolean isDeletable(String obj) {
		Schema.SObjectType objType = getSObject(obj);
		if (!objType.getDescribe().isDeletable()) {
			return false;
		}
		return true;
	}

	public static Boolean isUpdateable(String obj, List<String> fieldsToCheck) {
		Schema.SObjectType objType = getSObject(obj);
		if (!objType.getDescribe().isUpdateable()) {
			return false;
		}

		Map<String, Schema.SObjectField> m = getFieldsMap(objType);
		for (String fieldToCheck : fieldsToCheck) {
			if (!m.get(fieldToCheck).getDescribe().isUpdateable()) {
				return false;
			}
		}

		return true;
	}

	private static SObjectType getSObject(String obj) {
		return Schema.getGlobalDescribe().get(obj);
	}

	private static Map<String, Schema.SObjectField> getFieldsMap(SObjectType objType) {
		return objType.getDescribe().fields.getMap();
	}
}