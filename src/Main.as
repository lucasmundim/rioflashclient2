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
  import flash.text.TextFieldAutoSize;
  import flash.text.TextFormat;
  import flash.utils.setTimeout;

  import org.osmf.logging.Log;
  import org.osmf.logging.Logger;

  import rioflashclient2.assets.Header;
  import rioflashclient2.chrome.controlbar.ControlBar;
  import rioflashclient2.chrome.controlbar.NavigationBar;
  import rioflashclient2.chrome.controlbar.widget.ApplicationFullScreenButton;
  import rioflashclient2.chrome.controlbar.widget.ResizeHandle;
  import rioflashclient2.chrome.controlbar.widget.TopicsNavigator;
  import rioflashclient2.chrome.screen.DebugConsole;
  import rioflashclient2.chrome.screen.ErrorScreen;
  import rioflashclient2.chrome.screen.FullScreenManager;
  import rioflashclient2.configuration.Configuration;
  import rioflashclient2.event.DragEvent;
  import rioflashclient2.event.EventBus;
  import rioflashclient2.event.LessonEvent;
  import rioflashclient2.event.LoggerEvent;
  import rioflashclient2.event.PlayerEvent;
  import rioflashclient2.logging.EventfulLogger;
  import rioflashclient2.logging.EventfulLoggerFactory;
  import rioflashclient2.model.LessonLoader;
  import rioflashclient2.player.Player;
  import rioflashclient2.player.SlidePlayer;
  import rioflashclient2.user.VolumeSettings;

  [SWF(backgroundColor="0xFFFFFF", frameRate="30", width="1024", height="768")]
  public class Main extends Sprite {
    public static const DEFAULT_VIDEO_WIDTH:Number = 320;
    public static const DEFAULT_VIDEO_HEIGHT:Number = 240;

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
    private var slidePlayer:SlidePlayer;
    private var navigationBar:NavigationBar;
    private var dragStartWidth:Number;
    private var header:Header;
    private var newWidthVideo:Number;
    private var newHeightVideo:Number;
    private var fullScreenMode:String = "application";
    private var applicationFullScreenButton:ApplicationFullScreenButton;

    public function Main():void {
      if (stage) init();
      else addEventListener(Event.ADDED_TO_STAGE, init);
    }

    private function init(e:Event = null):void {
      this.rawParameters = LoaderInfo(root.loaderInfo).parameters;
      removeEventListener(Event.ADDED_TO_STAGE, init);
      addEventListener(Event.RESIZE, onResize);
      stage.addEventListener(Event.RESIZE, onResize);
      setupLogger();
      setupDebugConsole();
      setupStage();
      logger.info('Starting Application...');
      setupConfiguration();
      setupFullScreenManager();
      setupPlayer();
      setupSlidePlayer();
      setupTreeView();
      loadUserSettings();
      loadLesson();
      setupControlBar();
      drawLayout();
      setupErrorScreen();
    }

    private function onEnterFullScreen(e:PlayerEvent):void {
      fullScreenMode = e.data.mode;
      resizeElements(fullScreenMode);
    }

    private function onExitFullScreen(e:PlayerEvent):void {
      fullScreenMode = "application";
      resizeElements(fullScreenMode);
    }

    private function hideElements():void {
      slidePlayer.visible = resizeHandle.visible =
      topicsTree.visible = navigationBar.visible = header.visible = false;
    }

    private function showElements():void {
      slidePlayer.visible = resizeHandle.visible =
      topicsTree.visible = navigationBar.visible = header.visible = true;
    }

    private function drawLayout():void {
      navigationBar = new NavigationBar();
      header = new Header();
      header.bg.width =  stage.stageWidth;
      header.txtHeader.text ="Carregando aula...";
      header.txtHeader.width = stage.stageWidth;
      header.txtHeader.autoSize = TextFieldAutoSize.LEFT;
      header.txtHeader.defaultTextFormat = new TextFormat(new Arial20().fontName, 14, 0x333333);
      applicationFullScreenButton = new ApplicationFullScreenButton();
      applicationFullScreenButton.x = header.x + header.width - applicationFullScreenButton.width - 10;
      applicationFullScreenButton.y = header.height/2 - applicationFullScreenButton.height/2;
      header.addChild(applicationFullScreenButton);
      resizeHandle = new ResizeHandle();
      resizeHandle.x = DEFAULT_VIDEO_WIDTH;
      resizeHandle.constrains(DEFAULT_VIDEO_WIDTH/2, resizeHandle.y, (DEFAULT_VIDEO_WIDTH * 1.5), 0);
      resizeHandle.addEventListener(DragEvent.DRAG_END, resizeDragUpdateHandler);
      addChild(player);
      addChild(controlbar);
      addChild(topicsTree);
      addChild(slidePlayer);
      addChild(navigationBar);
      addChild(resizeHandle);
      addChild(header);
      setTimeout(function():void{
        resizeDragUpdateHandler();
      },300);
    }

    private function onResize(e:Event):void {
      if (fullScreenMode == "application") {
        showElements();
        resizeElements(fullScreenMode);
      }
    }

    private function resizeDragUpdateHandler(event:DragEvent = null):void {
      resizeElements(fullScreenMode);
    }

    private function resizeElements(mode:String):void {
      if (mode == "video") {
        hideElements();
        resizePlayerToFullScreen();
        resizeControlBarToFullScreen();
      } else {
        showElements();
        header.bg.width = stage.stageWidth;
        header.txtHeader.width = stage.stageWidth - 50;
        applicationFullScreenButton.x = header.x + header.bg.width - applicationFullScreenButton.width - 10;
        resizeHandle.setSize(0, stage.stageHeight);
        resizePlayer();
        resizeControlBar();
        resizeTopicsTree();
        resizeSlideAndNavigation();
      }
    }

    private function resizePlayer():void {
      newWidthVideo = resizeHandle.getX() || DEFAULT_VIDEO_WIDTH;
      newHeightVideo = DEFAULT_VIDEO_HEIGHT * newWidthVideo / DEFAULT_VIDEO_WIDTH;
      player.y = header.y + header.height;
      player.setSize(newWidthVideo, newHeightVideo);
    }

    private function resizePlayerToFullScreen():void {
      player.x = 0;
      player.y = 0;
      player.setSize(stage.stageWidth, stage.stageHeight - controlbar.height);
    }

    private function resizeControlBar():void {
      controlbar.setSize(resizeHandle.getX() || DEFAULT_VIDEO_WIDTH);
      controlbar.y = player.y + (newHeightVideo || DEFAULT_VIDEO_HEIGHT);
    }

    private function resizeControlBarToFullScreen():void {
      controlbar.setSize(stage.stageWidth);
      controlbar.y = stage.stageHeight - controlbar.height;
    }

    private function resizeTopicsTree():void {
      var videoHeight:Number = newHeightVideo || DEFAULT_VIDEO_HEIGHT;
      var heightTopics:Number = stage.stageHeight - (header.height + videoHeight + controlbar.height);
      topicsTree.setSize(resizeHandle.getX(), heightTopics);
      topicsTree.y = controlbar.y + controlbar.height;
    }

    private function resizeSlideAndNavigation():void {
      var posXHandler:Number = resizeHandle.getX() + resizeHandle.width;
      var diffStage:Number = stage.stageWidth - (resizeHandle.getX() + resizeHandle.width);

      navigationBar.setSize(diffStage);
      navigationBar.x = posXHandler;
      navigationBar.y = stage.stageHeight - navigationBar.height;

      slidePlayer.setSize(diffStage, (stage.stageHeight - header.height - navigationBar.height))
      slidePlayer.x = posXHandler;
      slidePlayer.y = header.y + header.height;
    }

    private function setupSlidePlayer():void {
      slidePlayer = new SlidePlayer();
    }

    private function setupErrorScreen():void {
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
      Configuration.getInstance().readParameters(this.rawParameters);
    }

    private function setupFullScreenManager():void {
      fullScreenManager = new FullScreenManager(stage);
      EventBus.addListener(PlayerEvent.ENTER_FULL_SCREEN, onEnterFullScreen, EventBus.INPUT);
      EventBus.addListener(PlayerEvent.EXIT_FULL_SCREEN, onExitFullScreen);
    }

    private function setupPlayer():void {
      player = new Player();
      player.setSize(DEFAULT_VIDEO_WIDTH, DEFAULT_VIDEO_HEIGHT);
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
      lessonLoader = new LessonLoader();
      lessonLoader.load();
      EventBus.addListener(LessonEvent.RESOURCES_LOADED, onLessonResourcesLoaded);
    }

    private function onLessonResourcesLoaded(e:LessonEvent):void {
      header.txtHeader.condenseWhite = true;
      header.txtHeader.htmlText = getFormatedTitle(e.lesson);
    }
    
    private function getFormatedTitle(lesson:Object, limit:Number = 30):String{
      var program:String = lesson.grad_program.length > limit ? lesson.grad_program.substring(0, limit)+"..." : lesson.grad_program;
      var course:String = lesson.course.length > limit ? lesson.course.substring(0, limit)+"..." : lesson.course;
      var professor:String = lesson.professor.length > limit ? lesson.professor.substring(0, limit)+"..." : lesson.professor;
      return "<b>Disciplina:</b>" + program  + " - <b>Aula:</b> " + course + " - <b>Professor: </b>" + professor;
    }
  }
}