package {
	import rioflashclient2.configuration.Configuration;
	import rioflashclient2.event.EventBus;
  import rioflashclient2.event.LoggerEvent;
	import rioflashclient2.logging.EventfulLogger;
  import rioflashclient2.logging.EventfulLoggerFactory;
  import rioflashclient2.model.LessonLoader;
	
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.display.LoaderInfo;
	import flash.events.*;
  import flash.display.*;
  import flash.media.*;
  import flash.net.*;
	
	import org.osmf.logging.Log;
  import org.osmf.logging.Logger;
		
	[SWF(backgroundColor="0x000000", frameRate="30", width="640", height="400")]
	public class Main extends Sprite {
		private var logger:Logger;
		private var rawParameters:Object;
		private var configuration:Configuration;
		
		public function Main():void {
			this.rawParameters = LoaderInfo(root.loaderInfo).parameters;
			
			if (stage) init();
			else addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private function init(e:Event = null):void {
			removeEventListener(Event.ADDED_TO_STAGE, init);
			// entry point
			setupLogger();
			setupStage();
      
      logger.info('Starting Application...');

			setupConfiguration();
			
			EventBus.addListener(ErrorEvent.ERROR, function(e:ErrorEvent):void { logger.error('An error occurred: ' + e.text); });
			loadLesson();
		}
		
		public function setupLogger():void {
      Log.loggerFactory = new EventfulLoggerFactory(this.rawParameters.logLevel);
      logger = Log.getLogger('Main');
    }

		private function setupStage():void {
      logger.info('Adjusting stage scale mode and alignment...');
      
      stage.scaleMode = StageScaleMode.NO_SCALE;
      stage.align = StageAlign.TOP_LEFT;
    }

		private function setupConfiguration():void {
			// Comment for production
			this.rawParameters.environment = 'development';

      Configuration.getInstance().readParameters(this.rawParameters);
    }

		private function loadLesson():void {
		  lessonLoader = new LessonLoader(Configuration.getInstance().lessonXML);
		  lessonLoader.load();
		}
	}	
}