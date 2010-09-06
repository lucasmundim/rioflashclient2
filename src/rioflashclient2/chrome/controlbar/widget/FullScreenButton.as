package rioflashclient2.chrome.controlbar.widget {
  import caurina.transitions.Tweener;
  
  import rioflashclient2.assets.FullScreenButtonAsset;
  import rioflashclient2.event.EventBus;
  import rioflashclient2.event.PlayerEvent;
  
  import flash.display.StageDisplayState;
  import flash.events.Event;
  import flash.events.FullScreenEvent;
  import flash.events.KeyboardEvent;
  import flash.events.MouseEvent;
  import flash.ui.Keyboard;
  
  /**
   * ...
   * @author 
   */
  public class FullScreenButton extends FullScreenButtonAsset implements ILayoutWidget {
    private var currentState:String;
    
    private var fullScreenState:String = 'fullscreen';
    private var normalState:String = 'normal';
    
    public function FullScreenButton() {
      if (!!stage) init();
      else addEventListener(Event.ADDED_TO_STAGE, init);
    }
    
    private function init(e:Event=null):void {
      setupEventListeners();
      setupBusListeners();
      setupInterface();
      setNormalState();
    }
    
    private function setupEventListeners():void {
      addEventListener(MouseEvent.ROLL_OVER, onMouseOver);
      addEventListener(MouseEvent.ROLL_OUT, onMouseOut);
      addEventListener(MouseEvent.CLICK, onClick);
    }

    private function setupBusListeners():void {
      EventBus.addListener(PlayerEvent.ENTER_FULL_SCREEN, onEnterFullScreen);
      EventBus.addListener(PlayerEvent.EXIT_FULL_SCREEN, onExitFullScreen);
    }
    
    private function setupInterface():void {
      buttonMode = true;
      background.alpha = 0;
    }
    
    public function setFullScreenState():void {
      currentState = fullScreenState;
      gotoAndStop(currentState);
    }
    
    public function setNormalState():void {
      currentState = normalState
      gotoAndStop(currentState);
    }
    
    private function onMouseOver(e:MouseEvent):void {
      Tweener.addTween(background, { time: 0.5, alpha: 1 });
    }
    
    private function onMouseOut(e:MouseEvent):void {
      Tweener.addTween(background, { time: 0.5, alpha: 0 });
    }
    
    private function onClick(e:MouseEvent):void {
      trace(currentState);
      if (currentState == fullScreenState) {
        EventBus.dispatch(new PlayerEvent(PlayerEvent.EXIT_FULL_SCREEN), EventBus.INPUT);
      } else {
        EventBus.dispatch(new PlayerEvent(PlayerEvent.ENTER_FULL_SCREEN), EventBus.INPUT);
      }
      trace(currentState);
    }

    private function onEnterFullScreen(e:PlayerEvent):void {
      setFullScreenState();
    }

    private function onExitFullScreen(e:PlayerEvent):void {
      setNormalState();
    }
    
    public function get offsetLeft():Number {
      return 2;
    }
 
    public function get offsetTop():Number {
      return 0;
    }
    
    public function get align():String {
      return WidgetAlignment.RIGHT;
    }
  }
}
