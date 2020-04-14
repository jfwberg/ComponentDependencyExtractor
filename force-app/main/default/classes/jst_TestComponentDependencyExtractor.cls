@IsTest
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
global with sharing class jst_TestComponentDependencyExtractor implements HttpCalloutMock {
	
	// create test response
	global HTTPResponse respond(HTTPRequest req) {
		
		// Create a fake response
		HttpResponse res = new HttpResponse();
		res.setHeader('Content-Type', 'application/json');
		res.setBody('{ "size": 2, "totalSize": 2, "done": true, "queryLocator": null, "entityTypeName": "ApexClass", "records": [ { "attributes": { "type": "ApexClass", "url": "/services/data/v47.0/tooling/sobjects/ApexClass/01p7E000004PPIxQAO" }, "Id": "01p7E000004PPIxQAO", "Name": "jst_ConfigurationExtensionWizard" }, { "attributes": { "type": "ApexClass", "url": "/services/data/v47.0/tooling/sobjects/ApexClass/01p7E000004Ad82QAC" }, "Id": "01p7E000004Ad82QAC", "Name": "jst_TestListCompare" } ] }');
		res.setStatusCode(200);

		return res;
	}

	public static testMethod void testGetInitData(){
		
		// Start the test
		test.startTest();

		// Execute init result
		Map<String,Object> resultMap = jst_ComponentDependencyExtractor.getInitData();

		// Stop the test
		test.stopTest();

		// Expect execution to have went well
		System.assertEquals(true, resultMap.get('isSuccess'));
	}
	
	
	public static testMethod void testExecuteBatch(){
		
		// Set mock callout class
        Test.setMock(HttpCalloutMock.class, new jst_TestComponentDependencyExtractor());
		
		// Start the test
		test.startTest();

		// Execute init result
		Map<String,Object> resultMap = jst_ComponentDependencyExtractor.executeBatch('ApexClass');

		// Stop the test
		test.stopTest();

		// Expect execution to have went well
		System.assertEquals('Started job for metadata type "ApexClass". Job Id: No Job Id', (String)resultMap.get('successMessage'));
	}
	
	public static testMethod void testExecuteBatchCustomField(){
		
		// Set mock callout class
        Test.setMock(HttpCalloutMock.class, new jst_TestComponentDependencyExtractor());
		
		// Start the test
		test.startTest();

		// Execute init result
		Map<String,Object> resultMap = jst_ComponentDependencyExtractor.executeBatch('CustomField');

		// Stop the test
		test.stopTest();

		// Expect execution to have went well
		System.assertEquals('Started job for metadata type "CustomField". Job Id: No Job Id', (String)resultMap.get('successMessage'));
    }
}
