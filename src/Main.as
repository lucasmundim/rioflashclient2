package {
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.display.LoaderInfo;
	
	import br.com.stimuli.loading.BulkLoader;
  import br.com.stimuli.loading.BulkProgressEvent;

	import flash.events.*;
  import flash.display.*;
  import flash.media.*;
  import flash.net.*;
	
	import rioflashclient2.configuration.Configuration;
		
	public class Main extends Sprite {
		
		private var configuration:Configuration;
		public var loader:BulkLoader;
		
		public function Main():void {
			if (stage) init();
			else addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private function init(e:Event = null):void {
			removeEventListener(Event.ADDED_TO_STAGE, init);
			// entry point
			trace('App initialized.');
			setupConfiguration();
			loadLesson();
		}
		
		public function loadLesson():void {
			// creates a BulkLoader instance with a name of "main-site", that can be used to retrieve items without having a reference to this instance
			loader = new BulkLoader("main-site");
			// set level to verbose, for debugging only
			loader.logLevel = BulkLoader.LOG_INFO;
			// now add items to load
			loader.add(configuration.lessonXmlUrl, {priority:20, id:"config-xml"});
			
			// dispatched when ALL the items have been loaded:
      loader.addEventListener(BulkLoader.COMPLETE, onAllItemsLoaded);
      
      // dispatched when any item has progress:
      loader.addEventListener(BulkLoader.PROGRESS, onAllItemsProgress);
      
      // now start the loading
      loader.start();
		}
		
		public function onAllItemsLoaded(evt : Event) : void {
			trace("every thing is loaded!");
			// get an xml file!
      //var theXML:XML = loader.getXML("config-xml");
			var theXML:String = loader.getText("config-xml");
      trace(theXML);
		}
		
		// this evt is a "super" progress event, it has all the information you need to 
    // display progress by many criterias (bytes, items loaded, weight)
    public function onAllItemsProgress(evt:BulkProgressEvent) : void {
      trace(evt.loadingStatus());
    }
		
		private function setupConfiguration():void // init -> 2 de 5
		{	
			trace('Loading Configuration...');
			configuration = Configuration.getInstance();
			configuration.load(LoaderInfo(root.loaderInfo).parameters);
		}
	}	
}