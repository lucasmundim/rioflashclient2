package rioflashclient2.chrome.controlbar {
  import caurina.transitions.Tweener;
  
  import rioflashclient2.assets.ControlBarBackground;
  import rioflashclient2.chrome.controlbar.widget.FullScreenButton;
  import rioflashclient2.chrome.controlbar.widget.ILayoutWidget;
  import rioflashclient2.chrome.controlbar.widget.PlayPauseButton;
  import rioflashclient2.chrome.controlbar.widget.ProgressBar;
  import rioflashclient2.chrome.controlbar.widget.ProgressInformationLabel;
  import rioflashclient2.chrome.controlbar.widget.Volume;
  import rioflashclient2.chrome.controlbar.widget.WidgetAlignment;
  import rioflashclient2.configuration.Configuration;
  import rioflashclient2.event.EventBus;
  import rioflashclient2.event.PlayerEvent;
  
  import flash.display.MovieClip;
  import flash.display.Sprite;
  import flash.events.Event;
  import flash.events.FullScreenEvent;
  import flash.events.MouseEvent;
  import flash.events.TimerEvent;
  import flash.utils.Timer;
  
  import org.osmf.events.LoadEvent;
  import org.osmf.events.TimeEvent;
  import org.osmf.logging.Log;
  import org.osmf.logging.Logger;

  public class ControlBar extends MovieClip {
    public var background:ControlBarBackground = new ControlBarBackground();
    public var playPauseButton:PlayPauseButton = new PlayPauseButton();
    public var progressBar:ProgressBar = new ProgressBar();
    public var volume:Volume = new Volume();
    public var fullScreenButton:FullScreenButton = new FullScreenButton();
    public var progressInformationLabel:ProgressInformationLabel = new ProgressInformationLabel();
    
    private var buttonsToLayout:Array = [];
    
    private var currentTime:Number = 0;
    private var duration:Number = 0;
    
    private var bytesLoaded:Number = 0;
    private var bytesTotal:Number = 0;
    
    private var displayed:Boolean = false;
    private var keepDisplaying:Boolean = false;
    
    private var autoHideTimer:Timer;
    
    private var logger:Logger = Log.getLogger('ControlBar');
    
    /**
     * The height of the control bar. This is fixed because the control bar
     * does not resize vertically when the stage is resized.
     */
    public static const HEIGHT:Number = 37;
    
    /**
     * The top offset used to layout buttons on the control bar.
     */
    public static const TOP_OFFSET:Number = 4;
    
    /**
     * The left and right padding of the control bar.
     */
    public static const SIDE_PADDING:Number = 0;
    
    /**
     * The spacement between buttons in the control bar.
     */
    public static const BUTTON_SPACEMENT:Number = 0;
    
    /**
     * The amout of time, in miliseconds, that should pass before the control
     * bar is automatically hidden when the user is not interacting with the
     * player.
     */
    public static const IDLE_TIME_BEFORE_AUTO_HIDE:Number = 3000;
    
    public function ControlBar() {
      this.name = 'ControlBar';
      this.tabChildren = false;
      
      if (!!stage) init();
      else addEventListener(Event.ADDED_TO_STAGE, init);
    }
    
    private function init(e:Event=null):void {
      logger.info('Initializing control bar...');
      
      initialSetup();
      
      setupBackground();
      setupControls();
      setupEventListeners();
      setupBusListeners();
      setupBusDispatchers();
      resizeAndPosition();
    }
    
    private function initialSetup():void {
      this.x = 0;
      this.y = hiddenY();
      
      this.autoHideTimer = new Timer(IDLE_TIME_BEFORE_AUTO_HIDE);
    }
    
    private function setupBackground():void {
      addChild(background);
    }
    
    private function setupControls():void {
      renderButtons();
      renderProgressBar();
      
      positionControls();
    }
    
    private function renderButtons():void {
      logger.info('Rendering buttons...');
      
      for each (var buttonName:String in Configuration.getInstance().controlBarButtons) {
        if (this.hasOwnProperty(buttonName)) {
          logger.info('Rendering button {0}.', buttonName);
          
          buttonsToLayout.push(this[buttonName]);
          addChild(this[buttonName]);
        } else {
          logger.warn('Invalid button name given: {0}.', buttonName);
        }
      }
    }
    
    private function renderProgressBar():void {
      logger.info('Rendering progress bar.');
      addChild(progressBar);
    }
    
    private function setupEventListeners():void {
      stage.addEventListener(FullScreenEvent.FULL_SCREEN, fullScreenChanged);
      stage.addEventListener(Event.RESIZE, resizeAndPosition);
      
      autoHideTimer.addEventListener(TimerEvent.TIMER, hideControlBar);
    }
    
    private function setupBusListeners():void {
      EventBus.addListener(PlayerEvent.PLAY, onPlay);
      EventBus.addListener(PlayerEvent.PAUSE, onPause);
      EventBus.addListener(PlayerEvent.STOP, onStop);
      
      EventBus.addListener(PlayerEvent.SEEK, onSeek);
      
      EventBus.addListener(PlayerEvent.MUTE, onMute);
      EventBus.addListener(PlayerEvent.UNMUTE, onUnmute);
      EventBus.addListener(PlayerEvent.VOLUME_CHANGE, onVolumeChange);
      
      EventBus.addListener(TimeEvent.COMPLETE, onVideoEnded);
      EventBus.addListener(TimeEvent.CURRENT_TIME_CHANGE, onCurrentTimeChange);
      EventBus.addListener(TimeEvent.DURATION_CHANGE, onDurationChange);
      
      EventBus.addListener(LoadEvent.BYTES_LOADED_CHANGE, onBytesLoadedChange);
      EventBus.addListener(LoadEvent.BYTES_TOTAL_CHANGE, onBytesTotalChange);
      
    }
    
    private function setupBusDispatchers():void {
      if (hasPlayPauseButton()) {
        playPauseButton.addEventListener(PlayerEvent.PLAY, EventBus.dispatch);
        playPauseButton.addEventListener(PlayerEvent.PAUSE, EventBus.dispatch);
      }
      
      if (hasFullScreenButton()) {
        fullScreenButton.addEventListener(PlayerEvent.ENTER_FULL_SCREEN, EventBus.dispatch);
        fullScreenButton.addEventListener(PlayerEvent.EXIT_FULL_SCREEN, EventBus.dispatch);
      }
      
      if (hasVolume()) {
        volume.addEventListener(PlayerEvent.VOLUME_CHANGE, EventBus.dispatch);
        volume.addEventListener(PlayerEvent.MUTE, EventBus.dispatch);
        volume.addEventListener(PlayerEvent.UNMUTE, EventBus.dispatch);
      }
      
      progressBar.addEventListener(PlayerEvent.SEEK, EventBus.dispatch);
      progressBar.addEventListener(PlayerEvent.PLAY, EventBus.dispatch);
      progressBar.addEventListener(PlayerEvent.PAUSE, EventBus.dispatch);
    }
    
    private function resizeAndPosition(e:Event=null):void {
      resizeControls();
      positionControls();
      
      position();
    }
    
    private function resizeControls():void {
      background.width = stage.stageWidth;
      
      progressBar.maskBufferAnimation.width = stage.stageWidth;
      progressBar.background.width = stage.stageWidth;
    }
    
    private function position():void {
      y = displayed ? displayedY() : hiddenY();
    }
    
    private function displayedY():int {
      return stage.stageHeight - HEIGHT;
    }
    
    private function hiddenY():int {
      return stage.stageHeight;
    }
    
    private function positionControls():void {
      positionButtons();
      positionProgressBar();
    }
    
    private function positionButtons():void {
      positionButtonsVertically();
      positionButtonsHorizontally();
    }
    
    private function positionButtonsVertically():void {
      for each (var button:ILayoutWidget in buttonsToLayout) {
        button.y = TOP_OFFSET + button.offsetTop;
      }
    }
    
    private function positionButtonsHorizontally():void {
      var currentLeftPosition:Number = 0 + SIDE_PADDING;
      var currentRightPosition:Number = stage.stageWidth - SIDE_PADDING;
      
      for each (var button:ILayoutWidget in buttonsToLayout) {
        if (button.align == WidgetAlignment.LEFT) {
          button.x = currentLeftPosition + button.offsetLeft;
          currentLeftPosition = button.x + button.width + BUTTON_SPACEMENT;
        } else if (button.align == WidgetAlignment.RIGHT) {
          button.x = currentRightPosition + button.offsetLeft - button.width;
          currentRightPosition = button.x - BUTTON_SPACEMENT;
        }
      }
    }
    
    private function positionProgressBar():void {
      progressBar.x = 0;
      progressBar.y = HEIGHT - progressBar.background.height;
    }
    
    private function showControlBar(e:MouseEvent=null):void {
      if (!displayed) {
        logger.debug('Displaying control bar...');
        Tweener.addTween(this, { time: 1, y: displayedY() });
        displayed = true;
        keepDisplaying = false;
      }
    }
    
    private function keepControlBar(e:MouseEvent=null):void {
      keepDisplaying = true;
    }
    
    private function releaseControlBar(e:MouseEvent=null):void {
      keepDisplaying = false;
    }
    
    private function hideControlBar(e:Event=null):void {
      if (displayed && !keepDisplaying) {
        logger.debug('Hiding control bar...');
        
        Tweener.addTween(this, { time: 2, y: hiddenY() });
        displayed = false;
        autoHideTimer.stop();
        
        hideControls();
      }
    }
    
    private function hideControls():void {
      if (hasVolume()) {
        volume.hideSlider();
      }
    }
    
    private function resetAutoHide(e:Event=null):void {
      autoHideTimer.stop();
      autoHideTimer.start();
    }
    
    private function fullScreenChanged(e:FullScreenEvent): void {
      if (e.fullScreen) {
        logger.info('Entering full screen...');
        setFullScreenState();
      } else {
        logger.info('Exiting full screen...');
        setNormalState();
      }
    }
    
    private function onPlay(e:PlayerEvent):void {
			logger.debug('onPlay');
      enable();
      setPlayState();
    }
    
    private function onPause(e:PlayerEvent):void {
      setPauseState();
    }
    
    private function onStop(e:PlayerEvent=null):void {
      disable();
    }
    
    private function onSeek(e:PlayerEvent):void {
      var seekPercentage:Number = e.data as Number;
      var time:Number = seekPercentage * duration;
      
      EventBus.dispatch(new TimeEvent(TimeEvent.CURRENT_TIME_CHANGE, false, false, time));
    }
    
    private function onMute(e:PlayerEvent):void {
      if (hasVolume()) {
        volume.mute();
      }
    }
    
    private function onUnmute(e:PlayerEvent):void {
      if (hasVolume()) {
        volume.unmute();
      }
    }
    
    private function onVolumeChange(e:PlayerEvent):void {
      if (hasVolume()) {
        volume.level = e.data;
      }
    }
    
    private function onVideoEnded(e:TimeEvent):void {
      onStop(); 
    }
    
    private function onCurrentTimeChange(e:TimeEvent):void {
      logger.debug('Current Time Changed: ' + e.time);
      currentTime = e.time;
      updateCurrentProgress();
    }
    
    private function onDurationChange(e:TimeEvent):void {
      logger.debug('Duration Changed: ' + e.time);
      duration = e.time;
      updateCurrentProgress();
    }
    
    private function updateCurrentProgress():void {
      if (duration > 0) {
        if (hasProgressInformationLabel()) {
          progressInformationLabel.currentTime = currentTime;
          progressInformationLabel.duration = duration;
        }
        
        progressBar.currentProgressPercentage = currentTime / duration;
      } else {
        if (hasProgressInformationLabel()) {
          progressInformationLabel.currentTime = 0;
          progressInformationLabel.duration = 0;
        }
        
        progressBar.currentProgressPercentage = 0;
      }
    }
    
    private function onBytesLoadedChange(e:LoadEvent):void {
      logger.debug('Bytes Loaded Changed: ' + e.bytes);
      bytesLoaded = e.bytes;
      updateDownloadProgress();
    }
    
    private function onBytesTotalChange(e:LoadEvent):void {
      logger.debug('Bytes Total Changed: ' + e.bytes);
      bytesTotal = e.bytes;
      updateDownloadProgress();
    }
    
    private function updateDownloadProgress():void {
      if (bytesTotal > 0) {
        progressBar.downloadProgressPercentage = bytesLoaded / bytesTotal;
      } else {
        progressBar.downloadProgressPercentage = 0;
      }
    }
    
    private function addEventHandlers():void {
      stage.addEventListener(MouseEvent.MOUSE_MOVE, showControlBar);
      stage.addEventListener(MouseEvent.MOUSE_MOVE, resetAutoHide);
      
      addEventListener(MouseEvent.MOUSE_OVER, keepControlBar);
      addEventListener(MouseEvent.MOUSE_OUT, releaseControlBar);
    }
    
    private function removeEventHandlers():void {
      stage.removeEventListener(MouseEvent.MOUSE_MOVE, showControlBar);
      stage.removeEventListener(MouseEvent.MOUSE_MOVE, resetAutoHide);
      
      removeEventListener(MouseEvent.MOUSE_OVER, keepControlBar);
      removeEventListener(MouseEvent.MOUSE_OUT, releaseControlBar);
    }
    
    public function enable():void {
      if (!displayed) {
        addEventHandlers();
        showControlBar();
        fadeIn();
      }
    }
    
    public function disable():void {
      keepDisplaying = false;  
      removeEventHandlers();
      hideControlBar();
      fadeOut();
    }
    
    public function setPlayState():void {
      if (hasPlayPauseButton()) {
        playPauseButton.setOnState();
      }
      resetAutoHide();
    }
    
    public function setPauseState():void {
      if (hasPlayPauseButton()) {
        playPauseButton.setOffState();
      }
      resetAutoHide();
    }
    
    public function setFullScreenState():void {
      Tweener.removeTweens(this);
      if (hasFullScreenButton()) {
        fullScreenButton.setOnState();
      }
      resetAutoHide();
    }
    
    public function setNormalState():void {
      Tweener.removeTweens(this);
      if (hasFullScreenButton()) {
        fullScreenButton.setOffState();
      }
      resetAutoHide();
    }
    
    public function fadeIn():void {
      Tweener.addTween(this, { time: 2, alpha: 1, onStart: show });
    }
    
    public function fadeOut():void {
      Tweener.addTween(this, { time: 2, alpha: 0, onComplete: hide });
    }
    
    public function show():void {
      visible = true;
    }
    
    public function hide():void {
      visible = false;
    }
    
    private function hasPlayPauseButton():Boolean {
      return hasButton('playPauseButton');
    }
    
    private function hasFullScreenButton():Boolean {
      return hasButton('fullScreenButton');
    }
    
    private function hasVolume():Boolean {
      return hasButton('volume');
    }
    
    private function hasProgressInformationLabel():Boolean {
      return hasButton('progressInformationLabel');
    }
    
    private function hasButton(buttonName:String):Boolean {
      return buttonsToLayout.indexOf(this[buttonName]) != -1;
    }
  }
}
