
package rioflashclient2.event
{
	import flash.events.Event;

	public class DragEvent extends Event
	{
		
	//--------------------------------------
	//  Static Properties
	//--------------------------------------
	
		public static const DRAG_START:String = "dragStart";
		public static const DRAG_UPDATE:String = "dragUpdate";
		public static const DRAG_END:String = "dragEnd";
		
	//--------------------------------------
	//  Constructor
	//--------------------------------------
	
		/**
		 * Constructor.
		 */
		public function DragEvent(type:String, delta:Number = 0)
		{
			super(type, false, false);
			
			this.delta = delta;
		}
	
	//--------------------------------------
	//  Properties
	//--------------------------------------
		
		/**
		 * The number of pixels dragged during this update.
		 */
		public var delta:Number;
		
	//--------------------------------------
	//  Public Methods
	//--------------------------------------
	
		/**
		 * @private
		 */
		override public function clone():Event
		{
			return new DragEvent(this.type, this.delta);
		}
		
	}
}