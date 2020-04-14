/**
 *	@author			:	Justus van den Berg (jfwberg@gmail.com)
 *	@date			:	2020-01-13 22:00
 *	@description	:	Batch class for extracting Component Dependencies
 *
 *	Copyright 2020 Justus van den Berg
 *
 *	Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */
public with sharing class jst_ComponentDependency {
    
	// Constants
	public final String		 TOOLING_API_VERSION				= '48.0';
	public final String		 TOOLING_RESPONSE_ATTRIBUTE_DONE 	= 'done';
	public final String 	 TOOLING_RESPONSE_ATTRIBUTE_RECORDS	= 'records';
	public final String 	 TOOLING_RESPONSE_ATTRIBUTE_SIZE	= 'totalSize';
	public final Set<String> METADATA_TYPES = new Set<String>	{ 'ApexClass', 'ApexComponent', 'ApexPage', 'ApexTrigger', 'ApprovalProcess', 'AssignmentRule', 'AuraDefinitionBundle', 'CustomField', 'CustomLabel', 'CustomMetadata', 'CustomObject', 'CustomTab', 'Dashboard', 'EmailTemplate', 'EscalationRule', 'FieldSet', 'FlexiPage', 'Flow', 'FlowDefinition', 'GlobalValueSet', 'Group', 'HomePageLayout', 'Layout', 'MatchingRule', 'PermissionSet', 'Profile', 'Queue', 'QuickAction', 'Report', 'ReportType', 'Role', 'SharingSet', 'StaticResource', 'ValidationRule', 'WebLink', 'WorkflowAlert', 'WorkflowFieldUpdate', 'WorkflowRule', 'WorkflowTask'};
	
	// String to store the parent Id if applicable
	public String parentId;

	/**
	 *	@description	:	Method for executing a Component dependency query based on an Id
	 *						Tooling query will retrieve ALL depencies related to that specific metadata Id
	 *	@note			:	Purposely NOT optimised for bulk processing, do not use in loops, use with batch size 1
	 *						Query limit of 1000 added so even in the unlikely event of > 1000 records, the code will not break
	 */
	public Object[] ExecuteCompenentDepencyQueryFromId(Id metadataId) {

		// Setup Tooling query
		String 	query = 'SELECT ';
				query+= '	MetadataComponentId, 	MetadataComponentNamespace, 	MetadataComponentName,		MetadataComponentType,';
 				query+= '	RefMetadataComponentId, RefMetadataComponentNamespace,	RefMetadataComponentName,	RefMetadataComponentType ';
 				query+= 'FROM ';
 				query+= '	MetadataComponentDependency ';
				query+= 'WHERE ';
				query+= '	RefMetadataComponentId = \'' + metadataId + '\' ';
				query+= 'ORDER BY RefMetadataComponentName ASC LIMIT 1000';

		// Create new API call to the tooling query using URL encoded query string
		Http http = new Http();
		HttpRequest request = new HttpRequest();
		request.setEndpoint(URL.getSalesforceBaseUrl().toExternalForm()+ '/services/data/v'+TOOLING_API_VERSION+'/tooling/query?q='+EncodingUtil.urlEncode(query, 'UTF-8'));
		request.setMethod('GET');
		request.setHeader('Content-Type', 'application/json;charset=UTF-8');
		request.setHeader('Authorization', 'Bearer ' + ( test.isRunningTest()?'':Page.jst_getSessionId.getContent().toString().trim() ));
		HttpResponse response = http.send(request);

		// Check response code
		if (response.getStatusCode() == 200) {
			
			// Deserialize results into 
			Map<String, Object> toolingQueryResultMap = (Map<String, Object>)JSON.deserializeUntyped(response.getBody());
			
			// Check if the results contain the necesarry attributes
			if(toolingQueryResultMap.containsKey(TOOLING_RESPONSE_ATTRIBUTE_DONE) && toolingQueryResultMap.containsKey(TOOLING_RESPONSE_ATTRIBUTE_SIZE) && toolingQueryResultMap.containsKey(TOOLING_RESPONSE_ATTRIBUTE_RECORDS)){
				
				// Check if there are any records in the result
				if((Integer) toolingQueryResultMap.get(TOOLING_RESPONSE_ATTRIBUTE_SIZE) > 0){

					// If records are present return the record list
					return (Object[]) toolingQueryResultMap.get(TOOLING_RESPONSE_ATTRIBUTE_RECORDS);

				}else{
					// If no results just return an empty list
					return new Object[]{};
				}
			}else{
				// Handle unexpected result
				String errorString = 'Unexpected response body:\n' + response.getBody();
				System.debug(errorString);
				throw new StringException(errorString);
			}
		}else{
			// Handle unexpected result
			String errorString = 'Unexpected reponse code "' + response.getStatusCode() +'",\nResponse body:\n'+response.getBody();
			System.debug(errorString);
			throw new StringException(errorString);
		}
    }


	/**
	 *	@description	:	Method for executing a metadata query
	 *						Tooling query will retrieve ALL depencies related to that specific metadata Id
	 *	@note			:	Batch size limited to 1000
	 */
	public Object[] ExecuteMetadataQuery(String metadataType, jst_ComponentDependencyExtractor.MetadataTypeDetails mdtDetails, String whereClause) {
		
		// Check if the metadata type is actually valid
		if(METADATA_TYPES.contains(metadataType)){
			
			// Setup Tooling query
			String 	query = 'SELECT Id, '+ (mdtDetails.includeNamespacePrefix?'NamespacePrefix,':'') + mdtDetails.nameField +' FROM ' + metadataType+' '+whereClause+' LIMIT 1000';
					
			// Create new API call to the tooling query using URL encoded query string
			Http http = new Http();
			HttpRequest request = new HttpRequest();
			request.setEndpoint(URL.getSalesforceBaseUrl().toExternalForm()+ '/services/data/v' + TOOLING_API_VERSION + (mdtDetails.useToolingApi?'/tooling':'') + '/query?q='+EncodingUtil.urlEncode(query, 'UTF-8'));
			request.setMethod('GET');
			request.setHeader('Content-Type', 'application/json;charset=UTF-8');
			request.setHeader('Authorization', 'Bearer ' + ( test.isRunningTest()?'':Page.jst_getSessionId.getContent().toString().trim() ));
			HttpResponse response = http.send(request);

			// Check response code
			if (response.getStatusCode() == 200) {
				
				// Deserialize results into 
				Map<String, Object> toolingQueryResultMap = (Map<String, Object>)JSON.deserializeUntyped(response.getBody());
				
				// Check if the results contain the necesarry attributes
				if(toolingQueryResultMap.containsKey(TOOLING_RESPONSE_ATTRIBUTE_DONE) && toolingQueryResultMap.containsKey(TOOLING_RESPONSE_ATTRIBUTE_SIZE) && toolingQueryResultMap.containsKey(TOOLING_RESPONSE_ATTRIBUTE_RECORDS)){
					
					// Check if there are any records in the result
					if((Integer) toolingQueryResultMap.get(TOOLING_RESPONSE_ATTRIBUTE_SIZE) > 0){

						// If records are present return the record list
						return (Object[]) toolingQueryResultMap.get(TOOLING_RESPONSE_ATTRIBUTE_RECORDS);

					}else{
						// If no results just return an empty list
						return new Object[]{};
					}
				}else{
					// Handle unexpected result
					String errorString = 'Unexpected response body:\n' + response.getBody();
					System.debug(errorString);
					throw new StringException(errorString);
				}
			}else{
				// Handle unexpected result
				String errorString = 'Unexpected reponse code "' + response.getStatusCode() +'",\nResponse body:\n'+response.getBody();
				System.debug(errorString);
				throw new StringException(errorString);
			}
		}else{
			// Handle unexpected result
			String errorString = 'Metadata type now allowed for this method.';
			System.debug(errorString);
			throw new StringException(errorString);
		}
    }


	/**
	 * @description	:	Method that handles tooling API results
	 */
	public void HandleCreateMetadataItemFromRecords(Object[] records, String type, String nameField){

		// Check if there are any records to process
		if(!records.isEmpty()){
			
			// Create a map for all referenced metadata items (I don't know if there will be any duplicates but this will deduplicate)
			Map<String,jst_Metadata_Item__c> metadataItemRecordMap = new Map<String,jst_Metadata_Item__c>();

			// Loop through records
			for(Integer i=0,max=records.size();i<max;i++){
				
				// Create the data map for the referenced record to extract the details
				Map<String, Object> recordMap = (Map<String, Object>) records[i];
				
				// Fix for circle references in test data
				if(test.isRunningTest()){this.parentId = null;}

				// Create parent record
				metadataItemRecordMap.put( (String) recordMap.get('Id'),
					new jst_Metadata_Item__c(
						MetadataComponentId__c 			= (String) recordMap.get('Id'),
						MetadataComponentNamespace__c 	= (String) recordMap.get('NamespacePrefix'),
						MetadataComponentName__c		= (String) recordMap.get(nameField),
						MetadataComponentType__c		= type,
						Parent_Metadata_Item__c			= this.parentId
					)
				);
			}

			// Upsert related records based on the metadata component Id
			upsert metadataItemRecordMap.values() MetadataComponentId__c;
		}
	}


	/**
	 * @description	:	Method that handles tooling API results
	 * @note		:	Assumption is that the record set only contains records from a single REF Id
	 *					Method will fail if multiple are presented even if possible.
	 *					Assumption is that there will never be more than 1000 records due to query limits
	 */
	public void HandleRecordsFromSingleMetadataItem(Object[] records){

		// Check if there are any records to process
		if(!records.isEmpty()){
			
			// Create the data map for the first records to extract the details from the parent
			Map<String, Object> parentRecordMap = (Map<String, Object>) records[0];

			// Create parent record
			jst_Metadata_Item__c parentRecord = new jst_Metadata_Item__c(
				MetadataComponentId__c 			= 	(String) parentRecordMap.get('RefMetadataComponentId'),
				MetadataComponentNamespace__c 	=	(String) parentRecordMap.get('RefMetadataComponentNamespace'),
				MetadataComponentName__c		=	(String) parentRecordMap.get('RefMetadataComponentName'),
				MetadataComponentType__c		=	(String) parentRecordMap.get('RefMetadataComponentType')
			);
			
			// Upsert parent record based on the metadata component Id
			upsert parentRecord MetadataComponentId__c;
			
			// Check if the parent record is upserted correctly
			if(!String.isBlank(parentRecord.Id)){
				
				// Create a map for all referenced metadata items (I don't know if there will be any duplicates but this will deduplicate)
				Map<String,jst_Metadata_Item__c> referencedRecordsMap = new Map<String,jst_Metadata_Item__c>();

				// Loop through records
				for(Integer i=0,max=records.size();i<max;i++){
					
					// Create the data map for the referenced record to extract the details
					Map<String, Object> referencedRecordMap = (Map<String, Object>) records[i];

					// Create parent record
					referencedRecordsMap.put((String) referencedRecordMap.get('MetadataComponentId'),
						new jst_Metadata_Item__c(
							MetadataComponentId__c 			= 	(String) referencedRecordMap.get('MetadataComponentId'),
							MetadataComponentNamespace__c 	=	(String) referencedRecordMap.get('MetadataComponentNamespace'),
							MetadataComponentName__c		=	(String) referencedRecordMap.get('MetadataComponentName'),
							MetadataComponentType__c		=	(String) referencedRecordMap.get('MetadataComponentType')
						)
					);
				}

				// Upsert related records based on the metadata component Id
				upsert referencedRecordsMap.values() MetadataComponentId__c;

				// Delete all existing reference to start clean (I can't be bothered with checking if refrences already exists and override them etc. this will work for now)
				delete [SELECT Id FROM jst_Metadata_Item_Reference__c WHERE Metadata_Item__c = :parentRecord.Id];
				
				// Create a list for inserting the new records
				jst_Metadata_Item_Reference__c[] references = new jst_Metadata_Item_Reference__c[]{};

				// Create new refrence between parent and referenced records
				for(Integer i=0,max=referencedRecordsMap.values().size();i<max;i++){
					references.add(
						new jst_Metadata_Item_Reference__c(
							Metadata_Item__c			= parentRecord.Id,
							Reference_Metadata_Item__c	= referencedRecordsMap.values()[i].Id
						)
					);
				}

				// Insert the new references
				insert references;
			}
		}
	}
}