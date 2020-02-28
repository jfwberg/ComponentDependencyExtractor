/**
 *	@author			:	Justus van den Berg (jfwberg@gmail.com)
 *	@date			:	2020-01-13 22:00
 *	@description	:	Batch class for extracting Component Dependencies
 */
global class jst_BatchComponentDependency implements Database.Batchable<sObject>, Database.AllowsCallouts{
	
    // Constants
	global final String query;
	global final String idFieldName;
	
    /**
     * CONSTRUCTOR
     */
	global jst_BatchComponentDependency(String query,String idFieldName){
		this.query 		= query;
		this.idFieldName= idFieldName;
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
	global void execute(Database.BatchableContext BC, sObject[] scope){
		
		// Loop through scope (!! should be batch size 1 !!)
		for(Integer i=0,max=scope.size();i<max;i++){
			
			// Create new class
			jst_ComponentDependency componentDepency = new jst_ComponentDependency();

			// Fetch the records
			Object[] records = componentDepency.ExecuteCompenentDepencyQueryFromId((Id)scope[i].get(idFieldName));

			// Handle record creation
			componentDepency.HandleRecordsFromSingleMetadataItem(records);
		}

	}
	
    
    /**
     * FINISH METHOD
     */
	global void finish(Database.BatchableContext BC){
        
       
	}
}