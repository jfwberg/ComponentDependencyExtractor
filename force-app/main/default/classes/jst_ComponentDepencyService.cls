public with sharing class jst_ComponentDepencyService {
    
	// Constants
	public final String TOOLING_API_VERSION					= '47.0';
	public final String TOOLING_RESPONSE_ATTRIBUTE_DONE 	= 'done';
	public final String TOOLING_RESPONSE_ATTRIBUTE_RECORDS	= 'records';
	public final String TOOLING_RESPONSE_ATTRIBUTE_SIZE		= 'totalSize';
	
	
	/**
	 *	@description	:	Method for executing a Component dependency query based on an Id
	 *						Tooling query will retrieve ALL depencies related to that specific metadata Id
	 *	@note			:	Purposely NOT optimised for bulk processing, do not use in loops, use with batch size 1
	 */
	public Object[] ExecuteCompenentDepencyQueryFromId(Id metadataId) {

		// Setup Tooling query
		String 	query = 'SELECT ';
				query+= '	MetadataComponentId, 	MetadataComponentNamespace, 	MetadataComponentName,		MetadataComponentType,';
 				query+= '	RefMetadataComponentId, RefMetadataComponentNamespace,	RefMetadataComponentName,	RefMetadataComponentType ';
 				query+= 'FROM ';
 				query+= '	MetadataComponentDependency ';
				query+= 'WHERE ';
				query+= '	RefMetadataComponentId = \'01p7E000004Ad7wQAC\' ';
				query+= 'ORDER BY RefMetadataComponentName ASC';

		// Create new API call to the tooling query using URL encoded query string
		Http http = new Http();
		HttpRequest request = new HttpRequest();
		request.setEndpoint(URL.getSalesforceBaseUrl().toExternalForm()+ '/services/data/v'+TOOLING_API_VERSION+'/tooling/query?q='+EncodingUtil.urlEncode(query, 'UTF-8'));
		request.setMethod('GET');
		request.setHeader('Content-Type', 'application/json;charset=UTF-8');
		request.setHeader('Authorization', 'Bearer ' + userInfo.getSessionId());
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


}