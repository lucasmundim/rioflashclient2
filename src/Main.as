package {
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.display.LoaderInfo;
	
	import rioflashclient2.configuration.Configuration;
		
	public class Main extends Sprite {
		
		private var configuration:Configuration;
		
		public function Main():void {
			if (stage) init();
			else addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private function init(e:Event = null):void {
			removeEventListener(Event.ADDED_TO_STAGE, init);
			// entry point
			trace('App initialized.');
			setupConfiguration();
		}
		
		private function setupConfiguration():void // init -> 2 de 5
		{	
			trace('Loading Configuration...');
			configuration = Configuration.getInstance();
			configuration.load(LoaderInfo(root.loaderInfo).parameters);
		}
	}	
}