package rioflashclient2.chrome.controlbar.widget {
  import caurina.transitions.Tweener;
  
  import rioflashclient2.assets.VolumeButtonAsset;
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
    private var _lastOnLevel:Number = 1;
    
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
      setupInterface();
    }
    
    private function setupEventListeners():void {
      addEventListener(MouseEvent.ROLL_OVER, hover);
      addEventListener(MouseEvent.ROLL_OUT, out);
      
      slider.dragHitArea.addEventListener(MouseEvent.CLICK, changeLevel);
      slider.drag.addEventListener(MouseEvent.MOUSE_DOWN, startSliderDrag);
      
      muteButton.addEventListener(MouseEvent.CLICK, mute);
      unmuteButton.addEventListener(MouseEvent.CLICK, unmute);
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
    
    public function unmute(e:Event=null):void {
      if (isMuted) {
        logger.info('Unmuting...');
        restoreLevelState();
        volumeChanged();
        dispatchEvent(new PlayerEvent(PlayerEvent.UNMUTE));
        logger.debug('Unmuted, current level: ' + level);
      }
    }
    
    public function mute(e:Event=null):void {
      if (!isMuted) {
        logger.debug('Muting...');
        saveLevelState();
        muteLevel();
        volumeChanged();
        dispatchEvent(new PlayerEvent(PlayerEvent.MUTE));
        logger.debug('Muted, last on level: ' + _lastOnLevel);
      }
    }
    
    private function changeLevel(e:MouseEvent):void {
      saveLevelState();
      level = calculatedLevelGivenY(e.currentTarget.mouseY);
      volumeChanged();
    }
    
    private function animateVolumeSlider():void {
      Tweener.addTween(slider.fillBar, { time: 0.7, y: calculatedDragAndFillY() });
      Tweener.addTween(slider.drag, { time: 0.7, y: calculatedDragAndFillY() });
    }
    
    private function volumeChanged():void {
      dispatchEvent(new PlayerEvent(PlayerEvent.VOLUME_CHANGE, level));
    }
    
    private function muteLevel():void {
      level = 0;
    }
    
    private function saveLevelState():void {
      if (level > 0) {
        _lastOnLevel = level;
      }
    }
    
    private function restoreLevelState():void {
      if (level == 0 || isNaN(level)) {
        level = _lastOnLevel;
      }
    }
    
    private function setIsMuted():void {
      isMuted = (level == 0);
    }
    
    private function toggleButtons():void {
      muteButton.visible = !isMuted;
      unmuteButton.visible = isMuted;
    }
    
    private function sliderDragged(e:MouseEvent):void {
      logger.debug('Volume slider is being dragged. Current drag Y:' + slider.drag.y);
      
      level = calculatedLevelGivenY(slider.drag.y);
      slider.fillBar.y = slider.drag.y; // changing the fill to follow drag position
      
      saveLevelState(); // saving level state
      volumeChanged(); // notifying volume modification
    }
    
    private function startSliderDrag(e:MouseEvent):void {
      logger.debug('Starting volume slider drag...');
      
      isSliderBeingDragged = true;
      slider.drag.startDrag(false, sliderDragRegion());
      
      stage.addEventListener(MouseEvent.MOUSE_MOVE, sliderDragged);
      stage.addEventListener(MouseEvent.MOUSE_UP, stopSliderDrag);
    }
    
    private function stopSliderDrag(e:MouseEvent):void {
      logger.debug('Stopping volume slider drag...');
      
      slider.drag.stopDrag();
      isSliderBeingDragged = false;
      
      stage.removeEventListener(MouseEvent.MOUSE_MOVE, sliderDragged);
      stage.removeEventListener(MouseEvent.MOUSE_UP, stopSliderDrag);
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
    
    private function hover(e:MouseEvent):void {
      displaySlider();
    }
    
    private function out(e:MouseEvent):void {
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
