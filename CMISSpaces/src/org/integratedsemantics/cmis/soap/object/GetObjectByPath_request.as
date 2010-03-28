/**
 * GetObjectByPath_request.as
 * This file was auto-generated from WSDL by the Apache Axis2 generator modified by Adobe
 * Any change made to this file will be overwritten when the code is re-generated.
 */

package org.integratedsemantics.cmis.soap.object
{
	import mx.utils.ObjectProxy;
	import flash.utils.ByteArray;
	import mx.rpc.soap.types.*;
	/**
	 * Wrapper class for a operation required type
	 */
    
	public class GetObjectByPath_request
	{
		/**
		 * Constructor, initializes the type class
		 */
		public function GetObjectByPath_request() {}
            
		public var repositoryId:String;
		public var path:String;
		public var filter:String;
		public var includeAllowableActions:Boolean;
		public var includeRelationships:org.integratedsemantics.cmis.soap.object.EnumIncludeRelationships;
		public var renditionFilter:String;
		public var includePolicyIds:Boolean;
		public var includeACL:Boolean;
		public var extension:org.integratedsemantics.cmis.soap.object.CmisExtensionType;
	}
}