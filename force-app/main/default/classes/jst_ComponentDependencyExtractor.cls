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
public with sharing class jst_ComponentDependencyExtractor {
	
	// Default value for the picklist
	public static String DEFAULT_METADATA_TYPE = 'CustomObject';

	/**
	 * Map mapping the metadata types to their respective name field
	 * name - name field - use tooling api - include namespace
	 */
	public static final Map<String,MetadataTypeDetails> METADATA_TYPES_MAP = new Map<String,MetadataTypeDetails>{
		'ApexClass' 			=> new MetadataTypeDetails('ApexClass', 			'Name',			false,	true),
		'ApexComponent'			=> new MetadataTypeDetails('ApexComponent', 		'Name',			false,	true),
		'ApexPage'				=> new MetadataTypeDetails('ApexPage', 				'Name',			false,	true),
		'ApexTrigger'			=> new MetadataTypeDetails('ApexTrigger', 			'Name',			false,	true),
		'AssignmentRule'		=> new MetadataTypeDetails('AssignmentRule', 		'Name',			false,	false), 
		'AuraDefinitionBundle'	=> new MetadataTypeDetails('AuraDefinitionBundle',	'DeveloperName',false,	true),
		'CustomField'			=> new MetadataTypeDetails('CustomField',			'DeveloperName',true,	true),
		'CustomLabel'			=> new MetadataTypeDetails('CustomLabel',			'Name',			true,	true),
		'CustomObject'			=> new MetadataTypeDetails('CustomObject', 			'DeveloperName',true,	true),
		'CustomTab'				=> new MetadataTypeDetails('CustomTab', 			'DeveloperName',true,	true),
		'Dashboard'				=> new MetadataTypeDetails('Dashboard', 			'DeveloperName',false,	true),
		'EmailTemplate'			=> new MetadataTypeDetails('EmailTemplate', 		'DeveloperName',false,	true),
		'FieldSet'				=> new MetadataTypeDetails('FieldSet', 				'DeveloperName',true,	true), 
		'FlexiPage'				=> new MetadataTypeDetails('FlexiPage', 			'DeveloperName',true,	true), 
		'Flow'					=> new MetadataTypeDetails('Flow', 					'Fullname',		true,	false), 
		'FlowDefinition'		=> new MetadataTypeDetails('FlowDefinition', 		'DeveloperName',true,	true), 
		'Group'					=> new MetadataTypeDetails('Group', 				'DeveloperName',false, false),
		'MatchingRule'			=> new MetadataTypeDetails('MatchingRule', 			'DeveloperName',false, true),
		'PermissionSet'			=> new MetadataTypeDetails('PermissionSet', 		'Name', 		false, true),
		'Profile'				=> new MetadataTypeDetails('Profile', 				'Name', 		false, false),
		'Report'				=> new MetadataTypeDetails('Report', 				'DeveloperName',false, true),
		'Role'					=> new MetadataTypeDetails('Role', 					'DeveloperName',true, false),
		'StaticResource'		=> new MetadataTypeDetails('StaticResource',		'Name', 		false, true),
		'ValidationRule'		=> new MetadataTypeDetails('ValidationRule',		'FullName',		true, true),
		'WebLink'				=> new MetadataTypeDetails('WebLink',				'FullName', 	true, true),
		'WorkflowAlert'			=> new MetadataTypeDetails('WorkflowAlert',			'DeveloperName',true, true),
		'WorkflowFieldUpdate'	=> new MetadataTypeDetails('WorkflowFieldUpdate',	'DeveloperName',true, true),
		'WorkflowRule'			=> new MetadataTypeDetails('WorkflowRule',			'DeveloperName',true, true),
		'WorkflowTask'			=> new MetadataTypeDetails('WorkflowTask',			'DeveloperName',true, true)	
	};
	

	/**
	 * Method to initialize the lightning component with basic data
	 */
	@AuraEnabled
	public static Map<String,Object> getInitData(){
		
		// Create a map for the output with default flags
		Map<String,Object> outputMap = new Map<String,Object>{
			'isSuccess'		=>	false,
			'hasError'		=>	false,
			'errorMessage'	=>	''
		};

		try{
			// Create a list of metadata types for the picklist
			outputMap.put('metadataTypes', 			METADATA_TYPES_MAP.keySet());
			outputMap.put('selectedMetadataType', 	DEFAULT_METADATA_TYPE);
			
			// Set success flag
			outputMap.put('isSuccess',true);

		}catch(Exception e){
			// Set error flags
			outputMap.put('hasError',true);
			outputMap.put('errorMessage',false);
		}

		// Return the execution details
		return outputMap;
	}


		/**
	 * Method to initialize the lightning component with basic data
	 */
	@AuraEnabled
	public static Map<String,Object> executeBatch(String selectedMetadataType){
		
		// Create a map for the output with default flags
		Map<String,Object> outputMap = new Map<String,Object>{
			'isSuccess'		=>	false,
			'hasError'		=>	false,
			'errorMessage'	=>	'',
			'successMessage'=>	''
		};

		try{

			// Set default job Id to match in test classes
			String jobId = 'No Job Id';

			// Custom field need special care because ot the amount
			if(selectedMetadataType == 'CustomField'){
				
				// Note that Custom objects have to be retrieved first
				String query = 'SELECT Id, MetadataComponentId__c, MetadataComponentName__c FROM jst_Metadata_Item__c WHERE MetadataComponentType__c =\'CustomObject\'';
				if(!test.isRunningTest()){
					jobId = database.executeBatch(new jst_BatchComponentDependencyCustomField(query),1);
				}
			}else{
				
				// Start with this step to create all metadata items
				jst_ComponentDependency cd = new jst_ComponentDependency();
				Object[] metadataItemRecords = cd.ExecuteMetadataQuery(selectedMetadataType,	METADATA_TYPES_MAP.get(selectedMetadataType),'');
				cd.HandleCreateMetadataItemFromRecords(metadataItemRecords,selectedMetadataType,METADATA_TYPES_MAP.get(selectedMetadataType).nameField);

				// Execute the batch for the new metadata type records
				String query = 'SELECT MetadataComponentId__c FROM jst_Metadata_Item__c WHERE  MetadataComponentType__c =\''+selectedMetadataType+'\'';
				if(!test.isRunningTest()){
					jobId = database.executeBatch(new jst_BatchComponentDependency(query,'MetadataComponentId__c'),1);
				}

				
			}
			
			// Add success message
			outputMap.put('successMessage','Started job for metadata type "' + selectedMetadataType + '". Job Id: ' + jobId);

			// Set success flag
			outputMap.put('isSuccess',true);

		}catch(Exception e){
			// Set error flags
			outputMap.put('hasError',true);
			outputMap.put('errorMessage',e.getMessage());
		}

		// Return the execution details
		return outputMap;
	}


	/**
	 * Class for configuring the metadata query
	 */
	public class MetadataTypeDetails{
		public String name;
		public String nameField;
		public Boolean useToolingApi;
		public Boolean includeNamespacePrefix;
		
		public MetadataTypeDetails(String name, String nameField, Boolean useToolingApi, Boolean includeNamespacePrefix){
			this.name = name;
			this.nameField = nameField;
			this.useToolingApi = useToolingApi;
			this.includeNamespacePrefix = includeNamespacePrefix;
		}
	}
}
