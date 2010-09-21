package {
  import com.yahoo.astra.fl.containers.BorderPane;
  import com.yahoo.astra.fl.containers.VBoxPane;
  import com.yahoo.astra.layout.LayoutContainer;
  import com.yahoo.astra.layout.events.LayoutEvent;
  import com.yahoo.astra.layout.modes.BorderConstraints;
  import com.yahoo.astra.layout.modes.VerticalAlignment;
  
  import fl.containers.BaseScrollPane;
  import fl.controls.ScrollPolicy;
  
  import flash.display.LoaderInfo;
  import flash.display.MovieClip;
  import flash.display.Sprite;
  import flash.display.StageAlign;
  import flash.display.StageScaleMode;
  import flash.events.Event;
  
  import org.osmf.logging.Log;
  import org.osmf.logging.Logger;
  
  import rioflashclient2.assets.Header;
  import rioflashclient2.chrome.controlbar.ControlBar;
  import rioflashclient2.chrome.controlbar.NavigationBar;
  import rioflashclient2.chrome.controlbar.widget.ResizeHandle;
  import rioflashclient2.chrome.controlbar.widget.TopicsNavigator;
  import rioflashclient2.chrome.screen.DebugConsole;
  import rioflashclient2.chrome.screen.ErrorScreen;
  import rioflashclient2.chrome.screen.FullScreenManager;
  import rioflashclient2.configuration.Configuration;
  import rioflashclient2.event.DragEvent;
  import rioflashclient2.event.EventBus;
  import rioflashclient2.event.LoggerEvent;
  import rioflashclient2.logging.EventfulLogger;
  import rioflashclient2.logging.EventfulLoggerFactory;
  import rioflashclient2.model.LessonLoader;
  import rioflashclient2.player.Player;
  import rioflashclient2.player.SlidePlayer;
  import rioflashclient2.user.VolumeSettings;
    
  [SWF(backgroundColor="0x000000", frameRate="30", width="1024", height="768")]
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
	private var controlSlide:MovieClip;
	private var containerSlide:MovieClip;
	private var containerControlBar:MovieClip;
	private var mainContainer:LayoutContainer;
	private var resizeHandle:ResizeHandle;
	/*private var containerPane:BorderPane;
	private var leftVBox:VBoxPane;
	private var rightVBox:VBoxPane;*/
	private var slidePlayer:SlidePlayer;
	private var navigationBar:NavigationBar;
	private var dragStartWidth:Number;
	
	public static const VIDEO_HEIGHT:Number = 240;
	public static const VIDEO_WIDTH:Number = 320;
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
	  setupSlidePlayer();
      setupTreeView();
      loadUserSettings();
      loadLesson();
	  drawLayout();
    }


	private function testeDraw():void
	{
		controlSlide = new MovieClip();
		controlSlide.graphics.beginFill(0xFFCC00);
		controlSlide.graphics.drawRect(0,0,400,400);
		controlSlide.graphics.endFill();
		containerControlBar = new MovieClip();
		containerControlBar.graphics.beginFill(0x00CC00);
		containerControlBar.graphics.drawRect(0,0,320,37);
		containerControlBar.graphics.endFill();
		navigationBar = new NavigationBar();	
	}
	private function drawLayout():void
	{
		testeDraw();
		
		setupControlBar();
		
		
		
		var header:Header = new Header();
		header.bg.width =  stage.stageWidth;
		header.txtHeader.text = "Palestra Professor Nelson de Souza e Silva - Instituto do Coração - UFRJ";
		resizeHandle = new ResizeHandle();
		resizeHandle.addEventListener(DragEvent.DRAG_START, resizeDragStartHandler);
		resizeHandle.addEventListener(DragEvent.DRAG_UPDATE, resizeDragUpdateHandler);

		addChild(player);
		addChild(controlbar);
		addChild(topicsTree);
		addChild(resizeHandle);
		addChild(slidePlayer);
		addChild(navigationBar);
		addChild(header);
		
		dragStartWidth = VIDEO_WIDTH;
		resizeDragStartHandler(new DragEvent(DragEvent.DRAG_UPDATE));
		/*
		
		containerPane = new BorderPane();
		containerPane.name = 'containerPane';
		containerPane.width = stage.stageWidth;
		containerPane.height = stage.stageHeight;
		
		leftVBox = new VBoxPane([{target:player,maintainAspectRatio: true},
			                 {target:controlbar,maintainAspectRatio: true},
							 {target:topicsTree,maintainAspectRatio: true}]);

		leftVBox.verticalAlign = VerticalAlignment.TOP;
		leftVBox.setSize(VIDEO_WIDTH, stage.stageHeight);
		leftVBox.name = 'leftVBox';
		rightVBox = new VBoxPane([{target:controlSlide,percentWidth: 100, percentHeight: 100},{target:navigationBar,maintainAspectRatio: true}]);
		rightVBox.verticalAlign = VerticalAlignment.TOP;
		rightVBox.setSize(stage.stageWidth-(resizeHandle.x+resizeHandle.width), stage.stageHeight);
		rightVBox.name = 'rightVBox';
		containerPane.configuration = [{target:leftVBox, constraint: BorderConstraints.LEFT},
								{ target: resizeHandle, maintainAspectRatio: true, constraint: BorderConstraints.LEFT } ,
								{ target: rightVBox, constraint: BorderConstraints.LEFT}];
		addChild(containerPane);
		dragStartWidth = VIDEO_WIDTH;
		resizeDragUpdateHandler(new DragEvent(DragEvent.DRAG_UPDATE));*/
	}

	private function resizeDragStartHandler(event:DragEvent):void
	{
		dragStartWidth = topicsTree.width||VIDEO_WIDTH;
		resizeDragUpdateHandler(event);
	}	
	private function resizeDragUpdateHandler(event:DragEvent):void
	{
		//Limit resize into area min VIDEO_WIDTH/2 and max VIDEO_WIDTH*2
		resizeHandle.x = Math.min(Math.max(dragStartWidth + event.delta, VIDEO_WIDTH/2), VIDEO_WIDTH*2);
		resizeHandle.bg.height = stage.stageHeight;
		resizeHandle.icon.y = resizeHandle.height/2;
		resizeElements();
	}
	private function resizeElements():void
	{
		resizePlayer();
		resizeControlBar()
		resizeTopicsTree();
		resizeSlideAndNavigation();
	}
	private function resizePlayer():void
	{
		var newWidthVideo:Number = resizeHandle.x||VIDEO_WIDTH;
		var newHeightVideo:Number = VIDEO_HEIGHT*newWidthVideo/VIDEO_WIDTH;
		player.setSize(newWidthVideo, newHeightVideo);
	}
	private function resizeSlideAndNavigation():void
	{
		slidePlayer.x = resizeHandle.x + resizeHandle.width;
		slidePlayer.width = stage.stageWidth - (resizeHandle.x+resizeHandle.width);		
		navigationBar.setSize(slidePlayer.width);
		navigationBar.x = slidePlayer.x;
		navigationBar.y = stage.stageHeight-navigationBar.height;
	}

	private function resizeControlBar():void
	{
		controlbar.setSize(player.width||VIDEO_WIDTH);
		controlbar.y = player.y + (player.height||VIDEO_HEIGHT);
	}
	private function resizeTopicsTree():void
	{
		var videoHeight:Number = player.height||VIDEO_HEIGHT;
		var heightTopics:Number = stage.stageHeight-(videoHeight+37);
		topicsTree.setSize(resizeHandle.x, heightTopics);
		topicsTree.y = controlbar.y + controlbar.height;
	}
	private function setupSlidePlayer():void {
		slidePlayer = new SlidePlayer();
		//addChild(slidePlayer);
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
	  player.setSize(VIDEO_WIDTH,VIDEO_HEIGHT); 
    }

    private function setupTreeView():void {
      topicsTree = new TopicsNavigator();
    }

    private function setupControlBar():void {
      if (Configuration.getInstance().displayControlBar) {
        logger.info('Displaying control bar.');
        controlbar = new ControlBar();
		controlbar.setSize(320,37);
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