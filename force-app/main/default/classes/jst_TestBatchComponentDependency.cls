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
@IsTest
global with sharing class jst_TestBatchComponentDependency implements HttpCalloutMock{
	
	public static Integer responseNumber = 0;

	// create test response
	global HTTPResponse respond(HTTPRequest req) {
		
		// Create a fake response
		HttpResponse res = new HttpResponse();
		res.setHeader('Content-Type', 'application/json');
		
		// Metadata Compont dependency response API
		if(jst_TestBatchComponentDependency.responseNumber == 1){
			res.setBody('{ "size": 2, "totalSize": 2, "done": true, "queryLocator": null, "entityTypeName": "MetadataComponentDependency", "records": [ { "attributes": { "type": "MetadataComponentDependency", "url": "/services/data/v47.0/tooling/sobjects/MetadataComponentDependency/000000000000000AAA" }, "MetadataComponentId": "01p7E000004Ad7eQAC", "MetadataComponentNamespace": "awb_v1", "MetadataComponentName": "jst_TestBatchPopulateDataModelSnapshot", "MetadataComponentType": "ApexClass", "RefMetadataComponentId": "01p7E000004Ad7wQAC", "RefMetadataComponentNamespace": "awb_v1", "RefMetadataComponentName": "jst_TestFactory", "RefMetadataComponentType": "ApexClass" }, { "attributes": { "type": "MetadataComponentDependency", "url": "/services/data/v47.0/tooling/sobjects/MetadataComponentDependency/000000000000000AAA" }, "MetadataComponentId": "01p7E000004Ad7fQAC", "MetadataComponentNamespace": "awb_v1", "MetadataComponentName": "jst_TestBatchPopulateSecuritySnapshot", "MetadataComponentType": "ApexClass", "RefMetadataComponentId": "01p7E000004Ad7wQAC", "RefMetadataComponentNamespace": "awb_v1", "RefMetadataComponentName": "jst_TestFactory", "RefMetadataComponentType": "ApexClass" } ] }');
			res.setStatusCode(200);
		
		// Tooling query response
		}else if(jst_TestBatchComponentDependency.responseNumber == 2){
			res.setBody('{ "size": 2, "totalSize": 2, "done": true, "queryLocator": null, "entityTypeName": "ApexClass", "records": [ { "attributes": { "type": "ApexClass", "url": "/services/data/v47.0/tooling/sobjects/ApexClass/01p7E000004PPIxQAO" }, "Id": "01p7E000004PPIxQAO", "Name": "jst_ConfigurationExtensionWizard" }, { "attributes": { "type": "ApexClass", "url": "/services/data/v47.0/tooling/sobjects/ApexClass/01p7E000004Ad82QAC" }, "Id": "01p7E000004Ad82QAC", "Name": "jst_TestListCompare" } ] }');
			res.setStatusCode(200);
		
		// Error response
		}else if(jst_TestBatchComponentDependency.responseNumber == 3){
			res.setBody('{}');
			res.setStatusCode(400);
		}
		return res;
	}

	public static testMethod void testBatchComponentDependency(){
		
		// Set mock callout class
        Test.setMock(HttpCalloutMock.class, new jst_TestBatchComponentDependency());
		
		// Set the moch response number
		jst_TestBatchComponentDependency.responseNumber = 1;

		// Start the test
		test.startTest();

		// Query an unrelated record as the test data comes from mock where we are sure the test data exists and is limited
		String query = 'SELECT Id, Name FROM User  WHERE Id = \''+UserInfo.getUserId()+'\' LIMIT 1';
		database.executeBatch(new jst_BatchComponentDependency(query,'Id'),1);

		// Stop the test
		test.stopTest();

		// Expect 1 parent record + 2 Child records = 3 in total
		System.assertEquals(3, [SELECT Id FROM jst_Metadata_Item__c].size());

		// Expecting 2 relationship records
		System.assertEquals(2, [SELECT Id FROM jst_Metadata_Item_Reference__c].size());
    }


	public static testMethod void testHandleCreateMetadataItemFromRecords(){
		
		// Set mock callout class
        Test.setMock(HttpCalloutMock.class, new jst_TestBatchComponentDependency());
		
		// Set the moch response number
		jst_TestBatchComponentDependency.responseNumber = 2;

		// Start the test
		test.startTest();

		// Create metadata items
		jst_ComponentDependency cd = new jst_ComponentDependency();
		Object[] metadataItemRecords = cd.ExecuteMetadataQuery('ApexClass',new jst_ComponentDependencyExtractor.MetadataTypeDetails('ApexClass','Name',true,true),'');
		cd.HandleCreateMetadataItemFromRecords(metadataItemRecords,'ApexClass','Name');

		// Stop the test
		test.stopTest();

		// Expect 1 parent record + 2 Child records = 3 in total
		System.assertEquals(2, [SELECT Id FROM jst_Metadata_Item__c].size());
    }

	public static testMethod void testBatchComponentDependencyCustomField(){
		
		// Create test data
		jst_Metadata_Item__c myItem = new jst_Metadata_Item__c(MetadataComponentId__c = '01p7E000004PPIxQAO', MetadataComponentType__c='CustomObject');
		insert myItem;

		// Set mock callout class
        Test.setMock(HttpCalloutMock.class, new jst_TestBatchComponentDependency());
		
		// Set the moch response number
		jst_TestBatchComponentDependency.responseNumber = 2;

		// Start the test
		test.startTest();

		// Query an unrelated record as the test data comes from mock where we are sure the test data exists and is limited
		String query = 'SELECT MetadataComponentId__c, MetadataComponentType__c FROM jst_Metadata_Item__c LIMIT 1';
		database.executeBatch(new jst_BatchComponentDependencyCustomField(query),1);

		// Stop the test
		test.stopTest();

		// Expect 2 child records
		System.assertEquals(2, [SELECT Id FROM jst_Metadata_Item__c].size());
    }

	public static testMethod void testExceptions(){
		// Set mock callout class
        Test.setMock(HttpCalloutMock.class, new jst_TestBatchComponentDependency());

		// Set the moch response number
		jst_TestBatchComponentDependency.responseNumber = 3;

		// Start the test
		test.startTest();
		jst_ComponentDependency componentDependency = new jst_ComponentDependency();
		
		try{componentDependency.ExecuteCompenentDepencyQueryFromId(UserInfo.getUserId());}catch(Exception e){}
		try{componentDependency.ExecuteMetadataQuery('invalid',new jst_ComponentDependencyExtractor.MetadataTypeDetails('Invalid','Invalid',true,true),'');}catch(Exception e){}
		try{componentDependency.ExecuteMetadataQuery('ApexClass',new jst_ComponentDependencyExtractor.MetadataTypeDetails('ApexClass','DeveloperName',false,true),'');}catch(Exception e){}

		// Stop the test
		test.stopTest();

	}
}