package rioflashclient2.chrome.controlbar.widget {
  import rioflashclient2.assets.ProgressBarAsset;
  import rioflashclient2.event.PlayerEvent;
  
  import flash.events.Event;
  import flash.events.MouseEvent;
  
  public class ProgressBar extends ProgressBarAsset {
    private var _currentProgressPercentage:Number;
    private var _downloadProgressPercentage:Number;
    
    public function ProgressBar() {
      if (!!stage) init();
      else addEventListener(Event.ADDED_TO_STAGE, init);
    }
    
    private function init(e:Event=null):void {
      setupEventListeners();
      progressiveMode(); //OnDemand
      
      background.visible = false; // escondido por enquanto, verificar se deverá continuar existindo
      
      reset();
    }
    
    public function get currentProgressPercentage():Number {
      return _currentProgressPercentage;
    }
    
    public function set currentProgressPercentage(percentage:Number):void {
      _currentProgressPercentage = percentage;
      resizeCurrentProgress();
    }
    
    public function get downloadProgressPercentage():Number {
      return _downloadProgressPercentage;
    }
    
    public function set downloadProgressPercentage(percentage:Number):void {
      _downloadProgressPercentage = percentage;
      resizeDownloadProgress();
    }
    
    public function streamingMode():void {
      bufferAnimation.visible = true;
      downloadProgress.visible = false;
    }
    
    public function progressiveMode():void {
      bufferAnimation.visible = false;
      downloadProgress.visible = true;
    }
    
    public function seekTo(seekPercentage:Number):void {
      currentProgressPercentage = seekPercentage;
    }
    
    private function setupEventListeners():void {
      stage.addEventListener(Event.RESIZE, resize);
      
      addEventListener(MouseEvent.CLICK, onSeek);
      addEventListener(MouseEvent.MOUSE_DOWN, onStartDrag);
    }
    
    private function onSeek(e:MouseEvent):void {
      var seekPercentage:Number = calculatedSeekPercentageGivenX(e.currentTarget.mouseX);
      
      if (seekPercentage <= downloadProgressPercentage) {
        currentProgress.width = e.currentTarget.mouseX;
        dispatchEvent(new PlayerEvent(PlayerEvent.SEEK, seekPercentage));
      }
    }
    
    private function calculatedSeekPercentageGivenX(x:Number):Number {
      return x / background.width;
    }
    
    private function onStartDrag(e:MouseEvent):void {
      stage.addEventListener(MouseEvent.MOUSE_MOVE, onSeek);
      stage.addEventListener(MouseEvent.MOUSE_UP, onStopDrag);
      
      dispatchEvent(new PlayerEvent(PlayerEvent.PAUSE));
    }
    
    private function onStopDrag(e:MouseEvent):void {
      stage.removeEventListener(MouseEvent.MOUSE_MOVE, onSeek);
      stage.removeEventListener(MouseEvent.MOUSE_UP, onStopDrag);
      
      dispatchEvent(new PlayerEvent(PlayerEvent.PLAY));
    }
    
    private function reset():void {
      currentProgressPercentage = 0;
      downloadProgressPercentage = 0;
    }
    
    private function resize(e:Event):void {
      maskBufferAnimation.width = stage.stageWidth;
      background.width = stage.stageWidth;
      
      resizeCurrentProgress();
      resizeDownloadProgress();
    }
    
    private function resizeCurrentProgress():void {
      currentProgress.width = currentProgressPercentage * background.width;
    }
    
    private function resizeDownloadProgress():void {
      downloadProgress.width = downloadProgressPercentage * background.width;
    }
  }
}
