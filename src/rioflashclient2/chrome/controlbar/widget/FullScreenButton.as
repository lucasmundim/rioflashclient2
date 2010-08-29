package rioflashclient2.chrome.controlbar.widget {
  import caurina.transitions.Tweener;
  
  import rioflashclient2.assets.FullScreenButtonAsset;
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
    
    private var onState:String = 'fullscreen';
    private var offState:String = 'normal';
    
    private var onEvent:Event = new PlayerEvent(PlayerEvent.ENTER_FULL_SCREEN);
    private var offEvent:Event = new PlayerEvent(PlayerEvent.EXIT_FULL_SCREEN);
    
    public function FullScreenButton() {
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
