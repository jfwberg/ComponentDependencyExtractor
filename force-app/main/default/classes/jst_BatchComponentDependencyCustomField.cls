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
			componentDepency.parentId = scope[i].Id;
			Object[] metadataItemRecords = componentDepency.ExecuteMetadataQuery('CustomField',new jst_ComponentDependencyExtractor.MetadataTypeDetails('CustomField','DeveloperName',true,true),'WHERE TableEnumOrId =\''+scope[i].MetadataComponentId__c+'\'');
			componentDepency.HandleCreateMetadataItemFromRecords(metadataItemRecords,'CustomField','DeveloperName');
		}

	}
	
    
    /**
     * FINISH METHOD
     */
	global void finish(Database.BatchableContext BC){
		if(!test.isRunningTest()){
			String query = 'SELECT MetadataComponentId__c FROM jst_Metadata_Item__c WHERE MetadataComponentType__c =\'CustomField\'';
			String jobId = database.executeBatch(new jst_BatchComponentDependency(query,'MetadataComponentId__c'),1);
		}
	}
}