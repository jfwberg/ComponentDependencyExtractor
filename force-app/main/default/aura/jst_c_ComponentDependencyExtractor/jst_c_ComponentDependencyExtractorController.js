/**
 *	@author			:	Justus van den Berg (jfwberg@gmail.com)
 *	@date			:	2020-01-13 22:00
 *
 *	Copyright 2020 Justus van den Berg
 *
 *	Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */
({
    /**
	 * @description : function for getting the record info from Apex
	 */
	doInit : function(component, event, helper) {
		
		// Open spinner
		component.set("v.loading",true);
		
		// Create new Apex action
		var action = component.get("c.getInitData");
		
		// Set the parameters for record Id
		action.setParams({});

		// Set action callback
		action.setCallback(helper, function(response) {
			
			// Check if action is succesfull
			if(response.getState() === "SUCCESS") {
				
				try{
					// Parse response
					var response = response.getReturnValue();
				
					// Check if the response from the server is as expected
					if(typeof response === 'object' && !$A.util.isUndefinedOrNull(response)){
						
						// Check if there is an error in the input
						if(response.isSuccess === true){
							
							// Set the different metadata types
							component.set("v.metadataTypes",response.metadataTypes);
							
							// Set the default value
							component.set("v.selectedMetadataType",response.selectedMetadataType);

							console.log(response);
							

						}else{
							// Known apex error, show friendly message to the user in an unfriendly box
							helper.showError(component, response.errorMessage);
						}
					}else{
						// Known apex error, show friendly message to the user in an unfriendly box
						helper.showError(component, "Unknown javascript error: Server did not return expected result.");
					}
				}catch(e){
					helper.showError(component, "Unknown javascript error occurred: " + e.message);
				}
			}else{
				// Get the errors from the response
				var responseError = response.getError();

				// Unhandled exception, handle using the default error handling
				if(responseError && responseError.length > 0){
					helper.showError(component, "Unknown Apex Error occurred: " + responseError[0].message,defaultErrorHandlingParams);
				}	
			}

			// Close spinner
			component.set("v.loading",false);
		});
		
		// Add the Apex action to the queue
		$A.enqueueAction(action);
	},



	/**
	 * @description : function for getting the record info from Apex
	 */
	handleUpdate : function(component, event, helper) {
		
		// Open spinner
		component.set("v.loading",true);
		
		// Create new Apex action
		var action = component.get("c.executeBatch");
		
		// Set the parameters for record Id
		action.setParams({"selectedMetadataType" : component.get("v.selectedMetadataType")});

		// Set action callback
		action.setCallback(helper, function(response) {
			
			// Check if action is succesfull
			if(response.getState() === "SUCCESS") {
				
				try{
					// Parse response
					var response = response.getReturnValue();
				
					// Check if the response from the server is as expected
					if(typeof response === 'object' && !$A.util.isUndefinedOrNull(response)){
						
						// Check if there is an error in the input
						if(response.isSuccess === true){
							
							// Show the success messsage
							helper.showMessage(component,response.successMessage);

							console.log(response);
							

						}else{
							// Known apex error, show friendly message to the user in an unfriendly box
							console.log(response.errorMessage);
							helper.showError(component, response.errorMessage);
						}
					}else{
						// Known apex error, show friendly message to the user in an unfriendly box
						helper.showError(component, "Unknown javascript error: Server did not return expected result.");
					}
				}catch(e){
					helper.showError(component, "Unknown javascript error occurred: " + e.message);
				}
			}else{
				// Get the errors from the response
				var responseError = response.getError();

				// Unhandled exception, handle using the default error handling
				if(responseError && responseError.length > 0){
					helper.showError(component, "Unknown Apex Error occurred: " + responseError[0].message,defaultErrorHandlingParams);
				}	
			}

			// Close spinner
			component.set("v.loading",false);
		});
		
		// Add the Apex action to the queue
		$A.enqueueAction(action);
	}

})
