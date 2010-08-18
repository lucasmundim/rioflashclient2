package {
	import flash.display.Sprite;
	import flash.display.DisplayObject;
	import skins.PlayerSkin;
	import flash.events.Event;
		
	public class Main extends Sprite {
		
		public function Main():void {
			if (stage) init();
			else addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private function init(e:Event = null):void {
			removeEventListener(Event.ADDED_TO_STAGE, init);
			// entry point
			addChild(new PlayerSkin.ProjectSprouts() as DisplayObject);
			trace('App initialized.');
		}		
	}	
}