package rioflashclient2.chrome.controlbar.widget {
  import caurina.transitions.Tweener;
  
  import rioflashclient2.assets.PlayOverlay;
  
  import flash.events.Event;
  import flash.events.MouseEvent;
  
  public class PlayButton extends PlayOverlay {
    public function PlayButton() {
      if (!!stage) init();
      else addEventListener(Event.ADDED_TO_STAGE, init);
    }
    
    private function init(e:Event=null):void {
      setupEventListeners();
    }
    
    public function adjustPosition(x:Number, y:Number):void {
      this.x = Math.round(x);
      this.y = Math.round(y);
    }
    
    private function onOver(e:MouseEvent):void {
      //Tweener.addTween(this, { time: 1, alpha: 0.4 });
    }
    
    private function onOut(e:MouseEvent):void {
      //Tweener.addTween(this, { time: 1, alpha: 1 });
    }
    
    private function setupEventListeners():void {
      addEventListener(MouseEvent.ROLL_OVER,  onOver);
      addEventListener(MouseEvent.ROLL_OUT,   onOut);
      addEventListener(MouseEvent.MOUSE_OVER, onOver);
      addEventListener(MouseEvent.MOUSE_OUT,  onOut);
    }
  }
}
