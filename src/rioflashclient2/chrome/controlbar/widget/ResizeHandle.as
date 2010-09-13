package rioflashclient2.chrome.controlbar.widget
{
	import fl.controls.Button;
	import fl.events.ComponentEvent;
	
	import flash.display.DisplayObject;
	import flash.display.Shape;
	import flash.events.MouseEvent;
	
	import rioflashclient2.assets.HorizontalHandleIcon;
	import rioflashclient2.event.DragEvent;
	
	[Event(name="dragUpdate",type="rioflashclient2.event.DragEvent")]

	public class ResizeHandle extends HorizontalHandleIcon
	{

		public function ResizeHandle()
		{
			super();
			this.buttonMode = true;
			this.useHandCursor = true;
			this.addEventListener(MouseEvent.MOUSE_DOWN,resizeHandleDownHandler);
		}

		protected var startDragPosition:Number;
				
		protected function resizeHandleDownHandler(event:MouseEvent):void
		{
			this.startDragPosition = this.stage.mouseX;
			this.stage.addEventListener(MouseEvent.MOUSE_MOVE, handleDragHandler, false, 0, true);
			this.stage.addEventListener(MouseEvent.MOUSE_UP, handleDragStopHandler, false, 0, true);
			var dragEvent:DragEvent = new DragEvent(DragEvent.DRAG_START, 0);
			this.dispatchEvent(dragEvent);
		}
		
		protected function handleDragHandler(event:MouseEvent):void
		{
			var dragEvent:DragEvent = new DragEvent(DragEvent.DRAG_UPDATE, this.calculateOffset());
			this.dispatchEvent(dragEvent);
		}
		
		protected function handleDragStopHandler(event:MouseEvent):void
		{
			this.handleDragHandler(event);
			this.stage.removeEventListener(MouseEvent.MOUSE_MOVE, handleDragHandler);
			this.stage.removeEventListener(MouseEvent.MOUSE_UP, handleDragStopHandler);
			var dragEvent:DragEvent = new DragEvent(DragEvent.DRAG_END, this.calculateOffset());
			this.dispatchEvent(dragEvent);
		}
		
		protected function calculateOffset():Number
		{
			var offset:Number = this.stage.mouseX - this.startDragPosition;
			return offset;
		}

	}
}