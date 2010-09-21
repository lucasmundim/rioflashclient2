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
			buttonMode = true;
			useHandCursor = true;
			addEventListener(MouseEvent.MOUSE_DOWN,resizeHandleDownHandler);
		}

		protected var startDragPosition:Number;
				
		protected function resizeHandleDownHandler(event:MouseEvent):void
		{
			event.updateAfterEvent();
			startDragPosition = stage.mouseX;
			stage.addEventListener(MouseEvent.MOUSE_MOVE, handleDragHandler, false, 0, true);
			stage.addEventListener(MouseEvent.MOUSE_UP, handleDragStopHandler, false, 0, true);
			dispatchEvent(new DragEvent(DragEvent.DRAG_START, 0));
		}
		
		protected function handleDragHandler(event:MouseEvent):void
		{
			dispatchEvent(new DragEvent(DragEvent.DRAG_UPDATE, calculateOffset()));
		}
		
		protected function handleDragStopHandler(event:MouseEvent):void
		{
			handleDragHandler(event);
			stage.removeEventListener(MouseEvent.MOUSE_MOVE, handleDragHandler);
			stage.removeEventListener(MouseEvent.MOUSE_UP, handleDragStopHandler);
			var dragEvent:DragEvent = new DragEvent(DragEvent.DRAG_END, calculateOffset());
			dispatchEvent(dragEvent);
		}
		
		protected function calculateOffset():Number
		{
			var offset:Number = stage.mouseX - startDragPosition;
			return offset;
		}

	}
}