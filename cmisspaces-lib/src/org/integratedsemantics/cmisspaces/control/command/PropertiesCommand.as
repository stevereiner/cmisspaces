package org.integratedsemantics.cmisspaces.control.command
{	
	import com.adobe.cairngorm.control.CairngormEvent;
	import com.universalmind.cairngorm.commands.Command;
	import com.universalmind.cairngorm.events.Callbacks;
	
	import org.integratedsemantics.cmisspaces.control.delegate.atomrest.PropertiesDelegate;
	import org.integratedsemantics.flexspaces.control.event.properties.GetPropertiesEvent;
	import org.integratedsemantics.flexspaces.control.event.properties.SetPropertiesEvent;
	import org.integratedsemantics.flexspaces.model.folder.Node;
	import org.integratedsemantics.flexspaces.model.vo.PropertiesVO;

	
	/**
	 * Properties Command supports getting and setting properties on ADM and AVM nodes
	 */
	public class PropertiesCommand extends Command
	{
        /**
         * Constructor
         */
        public function PropertiesCommand()
        {
            super();
        }

        /**
         * Execute command for the given event
         *  
         * @param event event calling command
         * 
         */
        override public function execute(event:CairngormEvent):void
        {
            // always call the super.execute() method which allows the 
            // callBack information to be cached.
            super.execute(event);
 
            switch(event.type)
            {
                case GetPropertiesEvent.GET_PROPERTIES:
                    getProperties(event as GetPropertiesEvent);  
                    break;
                case SetPropertiesEvent.SET_PROPERTIES:  
                    setProperties(event as SetPropertiesEvent); 
                    break;
            }
        }		
				
		/**
		 * Gets properties data for document / folder
		 * 
		 * @param event get properties event 
		 */
		public function getProperties(event:GetPropertiesEvent):void
		{		    
            var handlers:Callbacks = new Callbacks(onGetPropertiesDataSuccess, onFault);
            var delegate:PropertiesDelegate = new PropertiesDelegate(handlers);
            delegate.getProperties(event.repoNode as Node);			
		}
		
        /**
         * Sets properties data for document / folder
         * 
         * @param event set properties event 
         */
        public function setProperties(event:SetPropertiesEvent):void
        {
            var handlers:Callbacks = new Callbacks(onSetPropertiesDataSuccess, onFault);
            var delegate:PropertiesDelegate = new PropertiesDelegate(handlers);
            delegate.setProperties(event.repoNode as Node, event.name, event.title, event.description, event.author);                     
        }

		/**
		 * onGetPropertiesDataSuccess event handler
		 * 
		 * @param event success event
		 */
		protected function onGetPropertiesDataSuccess(event:*):void
		{
            var propertiesVO:PropertiesVO = event.result as PropertiesVO;
            
            this.result(propertiesVO);
		}
		
        /**
         * onSetPropertiesDataSuccess event handler
         * 
         * @param event success event
         */
        protected function onSetPropertiesDataSuccess(event:*):void
        {
            this.result(event.result);
        }
		
	}
	
}