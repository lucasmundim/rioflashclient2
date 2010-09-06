package {
  import rioflashclient2.chrome.controlbar.ControlBar;
  import rioflashclient2.chrome.screen.DebugConsole;
  import rioflashclient2.chrome.screen.ErrorScreen;
  import rioflashclient2.chrome.screen.FullScreenManager;
  import rioflashclient2.configuration.Configuration;
  import rioflashclient2.player.Player;
  import rioflashclient2.event.LoggerEvent;
  import rioflashclient2.logging.EventfulLogger;
  import rioflashclient2.logging.EventfulLoggerFactory;
  import rioflashclient2.model.LessonLoader;
  import rioflashclient2.user.VolumeSettings;
  
  import flash.display.LoaderInfo;
  import flash.display.Sprite;
  import flash.display.StageAlign;
  import flash.display.StageScaleMode;
  import flash.events.Event;
  
  import org.osmf.logging.Log;
  import org.osmf.logging.Logger;
    
  [SWF(backgroundColor="0x000000", frameRate="30", width="640", height="360")]
  public class Main extends Sprite {
    private var logger:Logger;
    
    private var rawParameters:Object;

    private var debugConsole:DebugConsole;
    private var fullScreenManager:FullScreenManager;
    private var player:Player;
    private var controlbar:ControlBar;
    private var errorScreen:ErrorScreen;
    private var lessonLoader:LessonLoader;
    
    public function Main():void {
      this.rawParameters = LoaderInfo(root.loaderInfo).parameters;
      
      if (stage) init();
      else addEventListener(Event.ADDED_TO_STAGE, init);
    }
    
    private function init(e:Event = null):void {
      removeEventListener(Event.ADDED_TO_STAGE, init);
      // entry point
      setupLogger();
      setupDebugConsole();
      setupStage();
      
      logger.info('Starting Application...');

      setupConfiguration();
      setupErrorScreen();
      setupFullScreenManager();
      setupPlayer();
      setupControlBar();

      loadUserSettings();
      loadLesson();
    }

    private function setupErrorScreen():void{
      errorScreen = new ErrorScreen();
      addChild(errorScreen);
    }
    
    public function setupLogger():void {
      Log.loggerFactory = new EventfulLoggerFactory(this.rawParameters.logLevel);
      logger = Log.getLogger('Main');
    }

    private function setupDebugConsole():void {
      debugConsole = new DebugConsole();
      EventfulLogger.root().addEventListener(LoggerEvent.LOGGER_EVENT, debugConsole.onLogMessage);
      addChild(debugConsole);
      
      logger.info('Logger and Debug Console initialized.');
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

    private function setupFullScreenManager():void {
      fullScreenManager = new FullScreenManager(stage);
    }

    private function setupPlayer():void {
      player = new Player();
      addChild(player);
    }

    private function setupControlBar():void {
      if (Configuration.getInstance().displayControlBar) {
        logger.info('Displaying control bar.');
        controlbar = new ControlBar();
        addChild(controlbar);
      } else {
        logger.info('Control bar will not be displayed.');
      }
    }

    private function loadUserSettings():void {
      volumeSettings = new VolumeSettings();
      volumeSettings.restore();
    }

    private function loadLesson():void {
      lessonLoader = new LessonLoader(Configuration.getInstance().lessonXML);
      lessonLoader.load();
    }
  } 
}