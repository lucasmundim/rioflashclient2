package rioflashclient2.chrome.controlbar.widget {
  import rioflashclient2.configuration.Configuration;
  import rioflashclient2.assets.ProgressBarAsset;
  import rioflashclient2.event.EventBus;
  import rioflashclient2.event.PlayerEvent;

  import flash.events.Event;
  import flash.events.MouseEvent;

  import org.osmf.events.LoadEvent;
  import org.osmf.events.TimeEvent;

  public class ProgressBar extends ProgressBarAsset {
    private var _currentProgressPercentage:Number;
    private var _downloadProgressPercentage:Number;
    private var playaheadTime:Number = 0;
    private var _needToKeepPlayaheadTime:Boolean = false;

    private var duration:Number = 0;
    private var bytesTotal:Number = 0;

    public function ProgressBar() {
      if (!!stage) init();
      else addEventListener(Event.ADDED_TO_STAGE, init);
    }

    private function init(e:Event=null):void {
      setupEventListeners();
      setupBusListeners();
      progressiveMode(); //OnDemand
      bullet.y = 5;
      background.visible = true;

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

    public function get needToKeepPlayaheadTime():Boolean {
      return _needToKeepPlayaheadTime;
    }

    public function set needToKeepPlayaheadTime(value:Boolean):void {
      _needToKeepPlayaheadTime = value;
    }

    public function streamingMode():void {
      bufferAnimation.visible = true;
      downloadProgress.visible = false;
    }

    public function progressiveMode():void {
      bufferAnimation.visible = false;
      downloadProgress.visible = true;
    }

    private function setupEventListeners():void {
      stage.addEventListener(Event.RESIZE, onResize);

      addEventListener(MouseEvent.CLICK, onSeek);
      addEventListener(MouseEvent.MOUSE_DOWN, onStartDrag);
    }

    private function setupBusListeners():void {
      EventBus.addListener(TimeEvent.CURRENT_TIME_CHANGE, onCurrentTimeChange);
      EventBus.addListener(PlayerEvent.DURATION_CHANGE, onDurationChange);

      EventBus.addListener(LoadEvent.BYTES_LOADED_CHANGE, onBytesLoadedChange);
      EventBus.addListener(LoadEvent.BYTES_TOTAL_CHANGE, onBytesTotalChange);

      EventBus.addListener(PlayerEvent.PLAYAHEAD_TIME_CHANGED, onPlayaheadTimeChanged);
      EventBus.addListener(PlayerEvent.NEED_TO_KEEP_PLAYAHEAD_TIME, onNeedToKeepPlayaheadTime);
    }

    private function onPlayaheadTimeChanged(e:PlayerEvent):void {
      playaheadTime = e.data;
    }

    private function onNeedToKeepPlayaheadTime(e:PlayerEvent):void {
      needToKeepPlayaheadTime = e.data;
    }

    private function onCurrentTimeChange(e:TimeEvent):void {
      var elapsedTime:Number = 0;
      elapsedTime = e.time;

      if (needToKeepPlayaheadTime) {
        elapsedTime += playaheadTime;
      }

      updateCurrentProgress(elapsedTime);
    }

    private function onDurationChange(e:PlayerEvent):void {
      duration = e.data;
    }

    private function updateCurrentProgress(currentTime:Number):void {
      if (duration > 0) {
        currentProgressPercentage = currentTime / duration;
      } else {
        currentProgressPercentage = 0;
      }
    }

    private function onBytesLoadedChange(e:LoadEvent):void {
      updateDownloadProgress(e.bytes);
    }

    private function onBytesTotalChange(e:LoadEvent):void {
      bytesTotal = e.bytes;
    }

    private function updateDownloadProgress(bytesLoaded:Number):void {
      if (bytesTotal > 0) {
        downloadProgressPercentage = bytesLoaded / bytesTotal;
      } else {
        downloadProgressPercentage = 0;
      }
    }

    private function onSeek(e:MouseEvent):void {
      var position:Number = e.currentTarget.mouseX;

      if (e.currentTarget.toString() == "[object Stage]") {
        position -= x;
      }

      var seekPercentage:Number = calculatedSeekPercentageGivenX(position);
      currentProgress.width = position;
      bullet.x = position;

      EventBus.dispatch(new PlayerEvent(PlayerEvent.SEEK, seekPercentage), EventBus.INPUT);
    }

    private function calculatedSeekPercentageGivenX(x:Number):Number {
      return x / background.width;
    }

    private function onStartDrag(e:MouseEvent):void {
      stage.addEventListener(MouseEvent.MOUSE_MOVE, onSeek);
      stage.addEventListener(MouseEvent.MOUSE_UP, onStopDrag);

      EventBus.dispatch(new PlayerEvent(PlayerEvent.PAUSE), EventBus.INPUT);
    }

    private function onStopDrag(e:MouseEvent):void {
      stage.removeEventListener(MouseEvent.MOUSE_MOVE, onSeek);
      stage.removeEventListener(MouseEvent.MOUSE_UP, onStopDrag);

      EventBus.dispatch(new PlayerEvent(PlayerEvent.PLAY), EventBus.INPUT);
    }

    private function reset():void {
      currentProgressPercentage = 0;
      downloadProgressPercentage = 0;
    }

    private function onResize(e:Event):void {
      maskBufferAnimation.width = Configuration.getInstance().playerWidth;
      background.width = Configuration.getInstance().playerWidth;

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
