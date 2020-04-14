({
    /**
	 * @description : function for sending an error message
	 */
	showError : function(component, message){
		component.find('notifLib').showNotice({
			"variant": "error",
			"header": "Error",
			"message": message
		});
	},

	/**
	 * @description : function for sending a message to the user
	 */
	showMessage : function(component, message){
		component.find('notifLib').showNotice({
			"variant": "success",
			"header": "Success",
			"message": message
		});
	},
})
