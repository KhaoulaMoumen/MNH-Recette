public with sharing class Util_CustomMetadata {
	
	public static void updateCustomMetadataValue( Map<String,Map<String,Map<String,Object>>> datas)
    {
        List<String> componentNameList = new List<String>();
		for(String cmpBaseName : datas.keySet()){
			for(String cmpRecordName : datas.get(cmpBaseName).keySet()){
				componentNameList.add(cmpBaseName+'.'+cmpRecordName);
			}
		}

        Boolean deploy = false;

        List<Metadata.Metadata> components = Metadata.Operations.retrieve(Metadata.MetadataType.CustomMetadata, componentNameList);
        string np = namespacePrefix;
		
		Metadata.DeployContainer mdContainer = new Metadata.DeployContainer();
		
		for(Metadata.Metadata customMetadataRecordMetadata : components){
			List<String> parts = customMetadataRecordMetadata.fullName.split('\\.');
			Metadata.CustomMetadata customMetadataRecord = (Metadata.CustomMetadata) customMetadataRecordMetadata;

			Map<String,Object> uptadeValues = datas.get(parts[0]).get(parts[1]);
			
			List<Metadata.CustomMetadataValue> values = customMetadataRecord.values;

			for (integer i = 0; i < values.size(); i++)
            {
				String fieldName = values.get(i).field;


                String fieldNameNS = np+'__'+fieldName;

                if (uptadeValues.containsKey(fieldName))
                {
                    values.get(i).value = uptadeValues.get(fieldName);
                    deploy = true;
                }

                if (uptadeValues.containsKey(fieldNameNS))
                {
                    values.get(i).value = uptadeValues.get(fieldNameNS);
                    deploy = true;
                }

            }
            mdContainer.addMetadata(customMetadataRecord);
		}

		if(deploy && ! Test.isRunningTest()){
			Metadata.Operations.enqueueDeployment(mdContainer, null);
		}

    }

    private static String namespacePrefix {
        get {
            if (namespacePrefix == null) {
                String[] parts = String.valueOf(Util_CustomMetadata.class).split('\\.', 2);
                namespacePrefix = parts.size() == 2 ? parts[0] : '';
            }
            return namespacePrefix;
        }
        private set;
    }

}