package rioflashclient2.chrome.controlbar.widget {
  import caurina.transitions.Tweener;
  
  import rioflashclient2.assets.PlayPauseButtonAsset;
  import rioflashclient2.event.PlayerEvent;
  
  import flash.events.Event;
  import flash.events.MouseEvent;
  
  /**
   * ...
   * @author 
   */
  public class PlayPauseButton extends PlayPauseButtonAsset implements ILayoutWidget {
    private var currentState:String;
    
    private var onState:String = 'playing';
    private var offState:String = 'pause';
    
    private var onEvent:Event = new PlayerEvent(PlayerEvent.PLAY);
    private var offEvent:Event = new PlayerEvent(PlayerEvent.PAUSE);
    
    public function PlayPauseButton() {
      if (!!stage) init();
      else addEventListener(Event.ADDED_TO_STAGE, init);
    }
    
    private function init(e:Event=null):void {
      setupEventListeners();
      setupInterface();
      setOffState();
    }
    
    private function setupEventListeners():void {
      addEventListener(MouseEvent.ROLL_OVER, hover);
      addEventListener(MouseEvent.ROLL_OUT, out);
      addEventListener(MouseEvent.CLICK, click);
    }
    
    private function setupInterface():void {
      buttonMode = true;
      background.alpha = 0;
    }
    
    public function setOnState():void {
      currentState = onState;
      gotoAndStop(currentState);
    }
    
    public function setOffState():void {
      currentState = offState;
      gotoAndStop(currentState);
    }
    
    private function hover(e:MouseEvent):void {
      Tweener.addTween(background, { time: 0.5, alpha: 1 });
    }
    
    private function out(e:MouseEvent):void {
      Tweener.addTween(background, { time: 0.5, alpha: 0 });
    }
    
    private function click(e:MouseEvent=null):void {
      if (currentState == onState) {
        setOffState();
        dispatchEvent(offEvent);
      } else {
        setOnState();
        dispatchEvent(onEvent);
      }
    }
    
    public function get offsetLeft():Number {
      return 0;
    }
    
    public function get offsetTop():Number {
      return 0;
    }
    
    public function get align():String {
      return WidgetAlignment.LEFT;
    }
  }
}
