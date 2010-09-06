package rioflashclient2.chrome.controlbar.widget {
  import caurina.transitions.Tweener;
  
  import rioflashclient2.assets.VolumeButtonAsset;
  import rioflashclient2.event.EventBus;
  import rioflashclient2.event.PlayerEvent;
  
  import flash.events.Event;
  import flash.events.MouseEvent;
  import flash.geom.Rectangle;
  
  import org.osmf.logging.Log;
  import org.osmf.logging.Logger;
  
  /**
   * ...
   * @author 
   */
  public class Volume extends VolumeButtonAsset implements ILayoutWidget {
    private var logger:Logger = Log.getLogger('VolumeButton');
    
    private var _level:Number;
    
    private var isMuted:Boolean = false;
    private var isSliderBeingDragged:Boolean = false;
    
    private static const BACKGROUND_OFF_HEIGHT:Number = 24;
    private static const BACKGROUND_ON_HEIGHT :Number = 82;
    
    public function Volume() {
      if (!!stage) init();
      else addEventListener(Event.ADDED_TO_STAGE, init);
    }
    
    private function init(e:Event=null):void {
      setupEventListeners();
      setupBusListeners();
      setupInterface();
    }
    
    private function setupEventListeners():void {
      addEventListener(MouseEvent.ROLL_OVER, onMouseOver);
      addEventListener(MouseEvent.ROLL_OUT, onMouseOut);
      
      slider.dragHitArea.addEventListener(MouseEvent.CLICK, onChangeLevel);
      slider.drag.addEventListener(MouseEvent.MOUSE_DOWN, onStartSliderDrag);
      
      muteButton.addEventListener(MouseEvent.CLICK, onMuteClick);
      unmuteButton.addEventListener(MouseEvent.CLICK, onUnmuteClick);
    }

    private function setupBusListeners():void {
      EventBus.addListener(PlayerEvent.VOLUME_CHANGE, onVolumeChange);
    }
    
    private function setupInterface():void {
      muteButton.buttonMode = true;
      unmuteButton.buttonMode = true;
      slider.drag.buttonMode = true;
      slider.dragHitArea.buttonMode = true;
      
      background.alpha = 0;
      background.height = BACKGROUND_OFF_HEIGHT;
    }
    
    public function get level():Number {
      return _level;
    }
    
    public function set level(level:Number):void {
      var newLevel:Number = getNumberBetweenRange(level, 0, 1);
      
      if (_level != newLevel) {
        _level = newLevel;
        
        setIsMuted();
        toggleButtons();
        animateVolumeSlider();
        
        logger.debug('Volume level changed: ' + level);
      }
    }
    
    public function onUnmuteClick(e:Event=null):void {
      EventBus.dispatch(new PlayerEvent(PlayerEvent.UNMUTE), EventBus.INPUT);
    }
    
    public function onMuteClick(e:Event=null):void {
      EventBus.dispatch(new PlayerEvent(PlayerEvent.MUTE), EventBus.INPUT);
    }
    
    private function onChangeLevel(e:MouseEvent):void {
      level = calculatedLevelGivenY(e.currentTarget.mouseY);
      dispatchVolumeChanged();
    }

    private function onVolumeChange(e:PlayerEvent):void {
      level = e.data;
    }
    
    private function animateVolumeSlider():void {
      Tweener.addTween(slider.fillBar, { time: 0.7, y: calculatedDragAndFillY() });
      Tweener.addTween(slider.drag, { time: 0.7, y: calculatedDragAndFillY() });
    }
    
    private function dispatchVolumeChanged():void {
      EventBus.dispatch(new PlayerEvent(PlayerEvent.VOLUME_CHANGE, level), EventBus.INPUT);
    }
    
    private function setIsMuted():void {
      isMuted = (level == 0);
    }
    
    private function toggleButtons():void {
      muteButton.visible = !isMuted;
      unmuteButton.visible = isMuted;
    }
    
    private function onSliderDragged(e:MouseEvent):void {
      level = calculatedLevelGivenY(slider.drag.y);
      slider.fillBar.y = slider.drag.y; // changing the fill to follow drag position
      
      dispatchVolumeChanged(); // notifying volume modification
    }
    
    private function onStartSliderDrag(e:MouseEvent):void {
      isSliderBeingDragged = true;
      slider.drag.startDrag(false, sliderDragRegion());
      
      stage.addEventListener(MouseEvent.MOUSE_MOVE, onSliderDragged);
      stage.addEventListener(MouseEvent.MOUSE_UP, onStopSliderDrag);
    }
    
    private function onStopSliderDrag(e:MouseEvent):void {
      slider.drag.stopDrag();
      isSliderBeingDragged = false;
      
      stage.removeEventListener(MouseEvent.MOUSE_MOVE, onSliderDragged);
      stage.removeEventListener(MouseEvent.MOUSE_UP, onStopSliderDrag);
    }
    
    private function sliderDragRegion():Rectangle {
      return new Rectangle(slider.drag.x, slider.background.y, 0, slider.background.height);
    }
    
    public function displaySlider():void {
      Tweener.addTween(slider, { time: 1, y: sliderHoverY() });
      Tweener.addTween(background, { time: 1, alpha: 1, height: BACKGROUND_ON_HEIGHT, y: backgroundHoverY() });
    }
    
    public function hideSlider():void {
      Tweener.addTween(slider, { time: 1, y: 15 });
      Tweener.addTween(background, { time: 1, alpha: 0, height: BACKGROUND_OFF_HEIGHT, y: 0 });
    }
    
    private function onMouseOver(e:MouseEvent):void {
      displaySlider();
    }
    
    private function onMouseOut(e:MouseEvent):void {
      if (!isSliderBeingDragged) {
        hideSlider();
      }
    }
    
    private function backgroundHoverY():Number {
      return BACKGROUND_OFF_HEIGHT - BACKGROUND_ON_HEIGHT;
    }
    
    private function sliderHoverY():Number {
      return -slider.fillBar.height;
    }
    
    private function calculatedDragAndFillY():Number {
      return (1 - level) * slider.fillBar.height;
    }
    
    private function calculatedLevelGivenY(y:Number):Number {
      return  (slider.fillBar.height - y) / slider.fillBar.height;
    }
    
    private function getNumberBetweenRange(value:Number, min:Number, max:Number):Number {
      return Math.max(min, Math.min(max, value));
    }
    
    public function get offsetLeft():Number {
      return 3;
    }
    
    public function get offsetTop():Number {
      return 0;
    }
    
    public function get align():String {
      return WidgetAlignment.RIGHT;
    }
  }
}
