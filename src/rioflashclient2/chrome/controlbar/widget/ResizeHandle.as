package rioflashclient2.chrome.controlbar.widget
{
	import fl.controls.Button;
	import fl.events.ComponentEvent;
	
	import flash.display.DisplayObject;
	import flash.display.Shape;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	
	import rioflashclient2.assets.HorizontalHandleIcon;
	import rioflashclient2.event.DragEvent;
	
	[Event(name="dragUpdate",type="rioflashclient2.event.DragEvent")]
	public class ResizeHandle extends HorizontalHandleIcon
	{
		protected var startDragPosition:Number;
		private var rectangleConstrains:Rectangle;
		public function ResizeHandle()
		{
			super();
			buttonMode = true;
			useHandCursor = true;
			addEventListener(MouseEvent.MOUSE_DOWN,resizeHandleDownHandler);
		}
		public function constrains(x:Number, y:Number, w:Number, h:Number):void{
			rectangleConstrains = new Rectangle(x,y,w,h)
		}
				
		protected function resizeHandleDownHandler(event:MouseEvent):void
		{
			this.startDrag(false,rectangleConstrains);	
			stage.addEventListener(MouseEvent.MOUSE_MOVE, handleDragHandler, false, 0, true);
			addEventListener(MouseEvent.MOUSE_MOVE, handleDragHandler, false, 0, true);
			stage.addEventListener(MouseEvent.MOUSE_UP, handleDragStopHandler, false, 0, true);
			addEventListener(MouseEvent.MOUSE_UP, handleDragStopHandler, false, 0, true);
			dispatchEvent(new DragEvent(DragEvent.DRAG_START));
			event.updateAfterEvent();
		}
		
		protected function handleDragHandler(event:MouseEvent):void
		{
			dispatchEvent(new DragEvent(DragEvent.DRAG_UPDATE));
			event.updateAfterEvent();
		}
		
		protected function handleDragStopHandler(event:MouseEvent):void
		{
			handleDragHandler(event);
			this.stopDrag();
			stage.removeEventListener(MouseEvent.MOUSE_MOVE, handleDragHandler);
			stage.removeEventListener(MouseEvent.MOUSE_UP, handleDragStopHandler);
			event.updateAfterEvent();
		}
	}
}