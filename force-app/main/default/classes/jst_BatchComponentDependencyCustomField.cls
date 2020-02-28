/**
 *	@author			:	Justus van den Berg (jfwberg@gmail.com)
 *	@date			:	2020-01-13 22:00
 *	@description	:	Batch class for extracting CustomField Dependencies
 */
global class jst_BatchComponentDependencyCustomField implements Database.Batchable<sObject>, Database.AllowsCallouts{
	
    // Constants
	global final String query;
	
	
    /**
     * CONSTRUCTOR
     */
	global jst_BatchComponentDependencyCustomField(String query){
		this.query = query;
	}
	

    /**
     * QUERY LOCATOR METHOD
     */
	global Database.QueryLocator start(Database.BatchableContext BC){
		return Database.getQueryLocator(query);
	}
	
    
    /**
     * EXECUTE METHOD
     */
	global void execute(Database.BatchableContext BC, jst_Metadata_Item__c[] scope){
		
		// Loop through scope (!! should be batch size 1 !!)
		for(Integer i=0,max=scope.size();i<max;i++){
			
			// Create new class
			jst_ComponentDependency componentDepency = new jst_ComponentDependency();
			Object[] metadataItemRecords = componentDepency.ExecuteMetadataQuery('CustomField','DeveloperName','WHERE TableEnumOrId =\''+scope[i].MetadataComponentId__c+'\'');
			componentDepency.HandleCreateMetadataItemFromRecords(metadataItemRecords,'CustomField','DeveloperName');
		}

	}
	
    
    /**
     * FINISH METHOD
     */
	global void finish(Database.BatchableContext BC){
        
       
	}
}