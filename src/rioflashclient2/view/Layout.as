package rioflashclient2.view
{
	import flash.display.DisplayObject;
	
	public class Layout 
	{
		private var items:Array;
		public function Layout()
		{
			items = [];
		}
		
		public function addItem(configuration:Object):void
		{
			items.addItem(configuration);	
		}
		
		public function draw():void
		{
			items[1].element.visible = false;
			return;
			for(var index:uint = 0; index<items.length; index++){
				var item:Object = items[index];				
				switch(item.verticalAlign){
					case "TOP":
						item.element.x = index > 0 ? items[index].x : 0;
						item.element.y = index > 0 ? items[index].y : 0;
					break;
					case "BOTTOM":
						item.x = index > 0 ? items[index-1].x : 0;
						item.element.y = index > 0 ? items[index-1].y + items[index-1].height : 0;
					break;
					case "LEFT":
						item.x = index > 0 ? items[index-1].x+items[index-1].y : 0;
						item.element.y = index > 0 ? items[index-1].y : 0;
					case "PAGEBOTTOM":
						item.x = index > 0 ? items[index-1].x : 0;
						item.element.y = index > 0 ? item.element.stage.stageHeight - item.element.height : 0;
					break;
				}
				trace(item.verticalAlign, item.element);

				
			}
				
		}
	}
}