package org.integratedsemantics.cmis.atom.property
{
	import org.integratedsemantics.cmis.atom.CMISConstants;

    /**
     * Boolean Property
     */
    public class CMISPropertyBoolean extends CMISProperty
    {
        public function CMISPropertyBoolean(source:XML=null)
        {
            super(source);
        }

        override public function getType():String
        {
            return CMISConstants.PROP_TYPE_BOOLEAN;
        }
                
    }
}