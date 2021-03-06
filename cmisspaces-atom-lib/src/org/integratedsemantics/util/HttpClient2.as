package org.integratedsemantics.util
{
	import com.adobe.net.URI;
	
	import flash.events.Event;
	import flash.events.HTTPStatusEvent;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.net.URLRequestHeader;
	import flash.utils.ByteArray;
	
	import mx.messaging.ChannelSet;
	import mx.messaging.channels.HTTPChannel;
	import mx.messaging.channels.SecureHTTPChannel;
	import mx.rpc.events.FaultEvent;
	import mx.rpc.events.ResultEvent;
	import mx.rpc.http.HTTPService;
	
	import org.httpclient.HttpClient;
	import org.httpclient.HttpHeader;
	import org.httpclient.HttpRequest;
	import org.httpclient.HttpResponse;
	import org.httpclient.events.HttpDataEvent;
	import org.httpclient.events.HttpListener;
	import org.httpclient.events.HttpRequestEvent;
	import org.httpclient.events.HttpResponseEvent;
	import org.httpclient.events.HttpStatusEvent;
	import org.integratedsemantics.cmisspaces.model.config.CMISConfig;
    
	[Event(name=Event.CLOSE, type="flash.events.Event")]  

	[Event(name=HttpRequestEvent.CONNECT, type="org.httpclient.events.HttpRequestEvent")]
	[Event(name=HttpResponseEvent.COMPLETE, type="org.httpclient.events.HttpResponseEvent")]

	[Event(name=HttpDataEvent.DATA, type="org.httpclient.events.HttpDataEvent")]     
	[Event(name=HttpStatusEvent.STATUS, type="org.httpclient.events.HttpStatusEvent")]
	[Event(name=HttpRequestEvent.COMPLETE, type="org.httpclient.events.HttpRequestEvent")]  
	[Event(name=HttpErrorEvent.ERROR, type="org.httpclient.events.HttpErrorEvent")]  
	[Event(name=HttpErrorEvent.TIMEOUT_ERROR, type="org.httpclient.events.HttpErrorEvent")]    
	[Event(name=IOErrorEvent.IO_ERROR, type="flash.events.IOErrorEvent")]  
	[Event(name=SecurityErrorEvent.SECURITY_ERROR, type="flash.events.SecurityErrorEvent")]  
	

	/**
	 * Extends HttpClient in as3httpclientlib to support URLLoader, HttpService requests
	 * (instead of using sockets)
	 * (note that URLLoader and HttpService requests have limitations in Flash (AIR less limits)
	 * in terms of the headers and http methods use can use (unless BlazeDS proxy is used)
	 *  
	 */
	public class HttpClient2 extends HttpClient
	{
		/**
		 * Create HTTP client
		 */
		public function HttpClient2() 
		{
			super();			
		}
		
		/**
		 * Request using URLLoader
		 * @param	uri URI
		 * @param	request HTTP request
		 * @param	timeout Timeout (in millis)
		 */
		public function requestURLLoader(uri:URI, httpRequest:HttpRequest, timeout:int = -1, listener:HttpListener = null):void
		{
		    //trace("HttpClient2 requestURLLoader()");

			var request:URLRequest = new URLRequest(uri.toString());		
			

            var headers:Array = httpRequest.header._headers;
            for (var h:int = 0; h < headers.length; h++)
            {
                var header:URLRequestHeader = new URLRequestHeader(headers[h]["name"], headers[h]["value"]);
                request.requestHeaders.push(header);		
            }
            
            request.method = httpRequest.method;                        

			request.data = httpRequest.body;
					
			var loader:URLLoader = new URLLoader();

			// use binary as what HttpClient excepts (response as ByteArray)
            loader.dataFormat = URLLoaderDataFormat.BINARY;			            

			loader.addEventListener(Event.COMPLETE, onComplete);
			loader.addEventListener(HTTPStatusEvent.HTTP_STATUS, onStatus);
			loader.addEventListener(ProgressEvent.PROGRESS, onProgress);
			loader.addEventListener(IOErrorEvent.IO_ERROR, onIOError);
			loader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onSecurityError);
			
			dispatchEvent(new HttpRequestEvent(httpRequest, httpRequest.header.toString(), HttpRequestEvent.CONNECT));
			dispatchEvent(new HttpRequestEvent(httpRequest, httpRequest.header.toString()));

			loader.load(request);
		}
		
		 /**
		  * Request using HTTPService 
		  * @param	uri URI
		  * @param	request HTTP request
		  * @param	timeout Timeout (in millis)
		  * 
		  */
		 public function requestHTTPService(cmisConfig:CMISConfig, uri:URI, httpRequest:HttpRequest, timeout:int = -1, listener:HttpListener = null):void
		{
		    //trace("HttpClient2 requestHTTPService()");

			var httpService:HTTPService = new HTTPService();
			httpService.url = uri.toString();
			
            var headers:Array = httpRequest.header._headers;
            for (var h:int = 0; h < headers.length; h++)
            {
                var headerName:String = headers[h]["name"];
                var headerValue:String = headers[h]["value"];
                httpService.headers[headerName] = headerValue;		
            }

            httpService.method = httpRequest.method;                        
		
			// use text so result not parsed
            httpService.resultFormat = "text";			            

			httpService.addEventListener(ResultEvent.RESULT, onResult);
			httpService.addEventListener(FaultEvent.FAULT, onFault);
			
			dispatchEvent(new HttpRequestEvent(httpRequest, httpRequest.header.toString(), HttpRequestEvent.CONNECT));
			dispatchEvent(new HttpRequestEvent(httpRequest, httpRequest.header.toString()));
			
            if (cmisConfig.useProxy == true)
            {
    			if ( (httpRequest.method == "POST") || (httpRequest.method == "PUT") || (httpRequest.method == "DELETE") )
    			{
        			httpService.useProxy = true;
        
                    if (cmisConfig.channelSet == null)
                    {
						cmisConfig.channelSet = new ChannelSet();
                        setupChannels(cmisConfig, cmisConfig.channelSet);
                    }                   
                    httpService.channelSet = cmisConfig.channelSet;
                    var body:String = String(httpRequest.body);
                    httpService.send(body);
                }
                else
                {
                    httpService.send();                    
                }
            }
            else
            {
			    httpService.send();
            }
		}

		private function onStatus(e:HTTPStatusEvent):void 
		{
		    trace("HttpClient2 onStatus()");

    		// todo create/init diff type status: HttpStatusEvent
    		//dispatchEvent(e.clone());
		}

		private function onProgress(e:ProgressEvent):void 
		{
		    trace("HttpClient2 onProgress()");

			dispatchEvent(e.clone());
		}
		
		private function onIOError(e:IOErrorEvent):void 
		{
		    trace("HttpClient2 onIOError()");

			dispatchEvent(e.clone());
		}
		
		private function onSecurityError(e:SecurityErrorEvent):void 
		{
		    trace("HttpClient2 onSecurityError()");

			dispatchEvent(e.clone());
		}
		
		private function onComplete(event:Event):void 
		{
		    trace("HttpClient2 onComplete()");

			var loader:URLLoader = URLLoader(event.target);
		    
			var headers:Array = [];      
			
			var httpResponse:HttpResponse = new HttpResponse("1.1", "200", "", new HttpHeader(headers));
			
			//construct status event
			dispatchEvent(new HttpStatusEvent(httpResponse));
			
			//construct http data event
			dispatchEvent(new HttpDataEvent(loader.data));

			//construct response event
			dispatchEvent(new HttpResponseEvent(httpResponse));			
		}		
		
		private function onFault(event:FaultEvent):void 
		{
		    trace("HttpClient2 onFault()");
		}
		
		private function onResult(event:ResultEvent):void 
		{
		    trace("HttpClient2 onResult()");

			var ba:ByteArray = new ByteArray();
            if (event.result != null)
            {
                var strData:String = event.result as String
    			ba.writeUTFBytes(strData); 
            }
            
			var headers:Array = [];      
			
			var httpResponse:HttpResponse = new HttpResponse("1.1", "200", "", new HttpHeader(headers));
			
			//construct status event
			dispatchEvent(new HttpStatusEvent(httpResponse));
			
			//construct http data event
			dispatchEvent(new HttpDataEvent(ba));

			//construct response event
			dispatchEvent(new HttpResponseEvent(httpResponse));			
		}
		
        private function setupChannels(cmisConfig:CMISConfig, channelSet:ChannelSet):void
        {
            var baseUrl:String = cmisConfig.proxyProtocol + "://" + cmisConfig.proxyDomain + ":" + cmisConfig.proxyPort + cmisConfig.proxyPrefixUrl;   

            if (cmisConfig.proxyProtocol == "http")
            {
                var channelUrl:String = baseUrl + "/messagebroker/http";
                var channelId:String = "remoting-http";
                var channel:HTTPChannel = new HTTPChannel(channelId, channelUrl);            
                channelSet.addChannel(channel);
            }
            else if (cmisConfig.proxyProtocol == "https")
            {   
                var channelUrl3:String = baseUrl + "/messagebroker/httpsecure";
                var channelId3:String = "remoting-secure-http";
                var channel3:SecureHTTPChannel = new SecureHTTPChannel(channelId3, channelUrl3);            
                channelSet.addChannel(channel3);
            }                                                                                   
        }
			
				
	}
	
}
