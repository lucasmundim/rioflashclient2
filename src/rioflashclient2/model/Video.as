package rioflashclient2.model {
  import rioflashclient2.event.EventBus;
  import rioflashclient2.event.PlayerEvent;

  import flash.utils.Dictionary;

  public class Video {
    public var _file:String;

    private var state:String = 'stopped';

    public function Video(file:String) {
      setupBusListeners();
      _file = file;
    }

    public function file():String {
      return _file;
    }

    public function valid():Boolean {
      return hasFile();
    }

    public function hasFile():Boolean {
      return file != null
    }

    public function equals(video:Video):Boolean {
      return video != null && video is Video && video.file == file;
    }

    public function isPlaying():Boolean {
      return state == 'playing';
    }

    public function isPaused():Boolean {
      return state == 'paused';
    }

    public function isStopped():Boolean {
      return state == 'stopped';
    }

    public function shouldPlay():Boolean {
      return !isPlaying();
    }

    public function shouldPause():Boolean {
      return !isPaused();
    }

    public function shouldStop():Boolean {
      return !isStopped();
    }

    public function play():void {
      if (shouldPlay()) {
        setPlayingState();
      }
    }

    public function pause():void {
      if (shouldPause()) {
        setPausedState();
      }
    }

    public function stop():void {
      if (shouldStop()) {
        setStoppedState();
      }
    }

    private function setPlayingState():void {
      state = 'playing';
      EventBus.dispatch(new PlayerEvent(PlayerEvent.PLAY));
    }

    private function setPausedState():void {
      state = 'paused';
      EventBus.dispatch(new PlayerEvent(PlayerEvent.PAUSE));
    }

    private function setStoppedState():void {
      state = 'stopped';
      EventBus.dispatch(new PlayerEvent(PlayerEvent.STOP));
    }

    private function onEnded(e:PlayerEvent):void {
      if (equals(e.data.lesson.video)) {
        state = 'stopped';
      }
    }

    private function setupBusListeners():void {
      EventBus.addListener(PlayerEvent.ENDED, onEnded);
    }
  }
}