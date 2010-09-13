package {
  import com.yahoo.astra.fl.containers.BorderPane;
  import com.yahoo.astra.fl.containers.VBoxPane;
  import com.yahoo.astra.layout.LayoutContainer;
  import com.yahoo.astra.layout.events.LayoutEvent;
  import com.yahoo.astra.layout.modes.BorderConstraints;
  import com.yahoo.astra.layout.modes.VerticalAlignment;
  
  import flash.display.LoaderInfo;
  import flash.display.MovieClip;
  import flash.display.Sprite;
  import flash.display.StageAlign;
  import flash.display.StageScaleMode;
  import flash.events.Event;
  
  import org.osmf.logging.Log;
  import org.osmf.logging.Logger;
  
  import rioflashclient2.chrome.controlbar.ControlBar;
  import rioflashclient2.chrome.controlbar.widget.ResizeHandle;
  import rioflashclient2.chrome.controlbar.widget.TopicsNavigator;
  import rioflashclient2.chrome.screen.DebugConsole;
  import rioflashclient2.chrome.screen.ErrorScreen;
  import rioflashclient2.chrome.screen.FullScreenManager;
  import rioflashclient2.configuration.Configuration;
  import rioflashclient2.event.DragEvent;
  import rioflashclient2.event.LoggerEvent;
  import rioflashclient2.logging.EventfulLogger;
  import rioflashclient2.logging.EventfulLoggerFactory;
  import rioflashclient2.model.LessonLoader;
  import rioflashclient2.player.Player;
  import rioflashclient2.user.VolumeSettings;
    
  [SWF(backgroundColor="0xFFFFFF", frameRate="30", width="1024", height="768")]
  public class Main extends Sprite {
    private var logger:Logger;
    
    private var rawParameters:Object;

    private var debugConsole:DebugConsole;
    private var fullScreenManager:FullScreenManager;
    private var volumeSettings:VolumeSettings;
    private var player:Player;
    private var topicsTree:TopicsNavigator;
    private var controlbar:ControlBar;
    private var errorScreen:ErrorScreen;
    private var lessonLoader:LessonLoader;
    
    public function Main():void {
      
      if (stage) init();
      else addEventListener(Event.ADDED_TO_STAGE, init);
    }
    
    private function init(e:Event = null):void {
      this.rawParameters = LoaderInfo(root.loaderInfo).parameters;
      removeEventListener(Event.ADDED_TO_STAGE, init);

      setupLogger();
      setupDebugConsole();
      setupStage();
      logger.info('Starting Application...');
      setupConfiguration();
      setupErrorScreen();
      setupFullScreenManager();
      setupPlayer();
      setupControlBar();
      setupTreeView();
      loadUserSettings();
      loadLesson();
	  drawLayout();
    }

	private var controlSlide:MovieClip;
	private var containerSlide:MovieClip;
	private function testeDraw():void
	{
		controlSlide = new MovieClip();
		controlSlide.graphics.beginFill(0xFFCC00);
		controlSlide.graphics.drawRect(0,0,400,400);
		controlSlide.graphics.endFill();
		
		addChild(controlSlide);
		
		containerSlide = new MovieClip();
		containerSlide.graphics.beginFill(0x00CC00);
		containerSlide.graphics.drawRect(0,0,400,40);
		containerSlide.graphics.endFill();
		addChild(containerSlide);
		
	}
	
	private var mainContainer:LayoutContainer;
	private var resizeHandle:ResizeHandle;
	private var border:BorderPane;
	private var left:VBoxPane;
	private var right:VBoxPane;
	private function drawLayout():void
	{
		testeDraw();
		var border:BorderPane = new BorderPane();
		border.name = 'borderPane';
		border.width = stage.stageWidth;
		border.height = stage.stageHeight;
		
		left = new VBoxPane([{target:player,maintainAspectRatio: true},
							{target:topicsTree,maintainAspectRatio: true}]);
		left.verticalAlign = VerticalAlignment.TOP;
		left.setSize(320, stage.stageHeight);
		left.name = 'left';
		addChild(left);
		
		resizeHandle = new ResizeHandle();
		resizeHandle.addEventListener(DragEvent.DRAG_START, resizeDragStartHandler);
		resizeHandle.addEventListener(DragEvent.DRAG_UPDATE, resizeDragUpdateHandler);
		addChild(resizeHandle);
		
		right = new VBoxPane([{target:controlSlide,percentWidth: 100, percentHeight: 100},
												{target:containerSlide, percentWidth: 100}]);
		right.verticalAlign = VerticalAlignment.TOP;
		right.setSize(stage.stageWidth-(resizeHandle.x+resizeHandle.width), stage.stageHeight);
		right.name = 'right';
		addChild(controlbar);
		addChild(right);
		
		
		border.configuration = [{target:left, constraint: BorderConstraints.LEFT},
								{ target: resizeHandle, constraint: BorderConstraints.LEFT } ,
								{ target: right, constraint: BorderConstraints.LEFT}];
		
		addChild(border);
	}
	private function resizeHandler(e:LayoutEvent):void
	{
		trace(e.target);
	}
	private var dragStartWidth:Number;
	private function resizeDragStartHandler(event:DragEvent):void
	{
		this.dragStartWidth = topicsTree.width||320;
	}
	
	private function resizeDragUpdateHandler(event:DragEvent):void
	{
		
		resizeHandle.x = this.dragStartWidth + event.delta;
		
		
		left.setSize(resizeHandle.x,stage.stageHeight);
		right.setSize(resizeHandle.x+resizeHandle.width, stage.stageHeight);
		
		var widthVideo:Number = left.width;
		var heightVideo:Number = 240*widthVideo/320;
		
		player.setSize(widthVideo, heightVideo);
		topicsTree.setSize(left.width,stage.stageHeight-heightVideo);
	}
    private function setupErrorScreen():void{
      errorScreen = new ErrorScreen();
      addChild(errorScreen);
    }
    
    public function setupLogger():void {
      Log.loggerFactory = new EventfulLoggerFactory(this.rawParameters.logLevel || 3);
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
	  player.width = 320;
	  player.height = 240;
	  //addChild(player);
    }

    private function setupTreeView():void {
      topicsTree = new TopicsNavigator();
      //addChild(topicsTree);
    }

    private function setupControlBar():void {
      if (Configuration.getInstance().displayControlBar) {
        logger.info('Displaying control bar.');
        controlbar = new ControlBar();
		
		
		controlbar.scaleX = controlbar.scaleY = 1;
        
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