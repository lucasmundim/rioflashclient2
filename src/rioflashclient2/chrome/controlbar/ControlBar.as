package rioflashclient2.chrome.controlbar {
  import caurina.transitions.Tweener;
  
  import flash.display.MovieClip;
  import flash.events.ErrorEvent;
  import flash.events.Event;
  import flash.events.FullScreenEvent;
  import flash.events.MouseEvent;
  import flash.events.TimerEvent;
  import flash.utils.Timer;
  
  import org.osmf.events.TimeEvent;
  import org.osmf.logging.Log;
  import org.osmf.logging.Logger;
  
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

  public class ControlBar extends MovieClip {
    public var background:ControlBarBackground = new ControlBarBackground();
    public var playPauseButton:PlayPauseButton = new PlayPauseButton();
    public var progressBar:ProgressBar = new ProgressBar();
    public var volume:Volume = new Volume();
    public var fullScreenButton:FullScreenButton = new FullScreenButton();
    public var progressInformationLabel:ProgressInformationLabel = new ProgressInformationLabel();
    
    private var buttonsToLayout:Array = [];
    private var _basicWidth:Number = 320;
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
    public static const SIDE_PADDING:Number = 10;
    
    /**
     * The spacement between buttons in the control bar.
     */
    public static const BUTTON_SPACEMENT:Number = 7;
    
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
      setupBackground();
	  initialSetup();
      setupControls();
      setupEventListeners();
      setupBusListeners();
      resizeAndPosition();
    }
    
    private function initialSetup():void {
      //this.x = 0;
      //this.y = 0;
      //this.autoHideTimer = new Timer(IDLE_TIME_BEFORE_AUTO_HIDE);
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
      //autoHideTimer.addEventListener(TimerEvent.TIMER, hideControlBar);
    }
    
    private function setupBusListeners():void {
      EventBus.addListener(PlayerEvent.PLAY, onPlay);
      EventBus.addListener(PlayerEvent.STOP, onStop);
      EventBus.addListener(TimeEvent.COMPLETE, onVideoEnded);
      EventBus.addListener(ErrorEvent.ERROR, onError);
    }
    
    public function resizeAndPosition(e:Event=null):void {
      positionControls();
      position();
    }
    
    private function position():void {
      //y = displayed ? displayedY() : hiddenY();
    }
  
	 override public function get width():Number
	 {
	 	return background.width;
	 }
	 override public function get height():Number
	 {
	 	return 37;
	 }
    private function displayedY():int {
      return 0;
    }
    
    private function hiddenY():int {
      return 0;
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
      for each (var button:* in buttonsToLayout) {
        button.y = TOP_OFFSET + button.offsetTop;
      }
    }
    
    private function positionButtonsHorizontally():void {
      var currentLeftPosition:Number = 0 + SIDE_PADDING;
      var currentRightPosition:Number = background.width - SIDE_PADDING;
      
      for each (var button:* in buttonsToLayout) {
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
      progressBar.x = playPauseButton.x + playPauseButton.width + 10;
      progressBar.y = playPauseButton.y + 10;
      progressBar.maskBufferAnimation.width =  playPauseButton.x + playPauseButton.width + progressInformationLabel.x - 10;;
    	progressBar.background.width =  progressBar.maskBufferAnimation.width;
    }
    
    private function showControlBar(e:MouseEvent=null):void {
      if (!displayed) {
        logger.debug('Displaying control bar...');
        //Tweener.addTween(this, { time: 1, y: displayedY() });
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
        
        //Tweener.addTween(this, { time: 2, y: hiddenY() });
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
      Tweener.removeTweens(this); // this fix a bug when changing from or to fullscreen
    }
    
    private function onPlay(e:PlayerEvent):void {
      enable();
    }
    
    private function onStop(e:PlayerEvent):void {
      show();
    }

    private function onVideoEnded(e:TimeEvent):void {
      show();
    }

    private function onError(e:ErrorEvent):void {
      disable();
    }
    
    private function addEventHandlers():void {
      /*stage.addEventListener(MouseEvent.MOUSE_MOVE, showControlBar);
      stage.addEventListener(MouseEvent.MOUSE_MOVE, resetAutoHide);
      
      addEventListener(MouseEvent.MOUSE_OVER, keepControlBar);
      addEventListener(MouseEvent.MOUSE_OUT, releaseControlBar);*/
    }
    
    private function removeEventHandlers():void {
      /*stage.removeEventListener(MouseEvent.MOUSE_MOVE, showControlBar);
      stage.removeEventListener(MouseEvent.MOUSE_MOVE, resetAutoHide);
      
      removeEventListener(MouseEvent.MOUSE_OVER, keepControlBar);
      removeEventListener(MouseEvent.MOUSE_OUT, releaseControlBar);*/
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
    
    public function fadeIn():void {
     // Tweener.addTween(this, { time: 2, alpha: 1, onStart: show });
    }
    
    public function fadeOut():void {
    //  Tweener.addTween(this, { time: 2, alpha: 0, onComplete: hide });
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
	
  	public function setSize(newWidth:Number = 320, newHeight:Number = 37):void{
  		background.width = newWidth;
  		progressBar.maskBufferAnimation.width =  playPauseButton.x + playPauseButton.width + progressInformationLabel.x - 10;;
  		progressBar.background.width =  progressBar.maskBufferAnimation.width;
  	}
  }
}
