package rioflashclient2.event {
  import flash.events.Event;
  
  public class PlayerEvent extends Event {
    public static const LOAD                  :String = "onLoad";
    
    public static const PLAY                  :String = "onPlay";
    public static const PAUSE                 :String = "onPause";
    public static const STOP                  :String = "onStop";
    
    public static const ENDED                 :String = "onVideoEnded";
    
    public static const SEEK                  :String = "onSeek";
    public static const SERVER_SEEK           :String = "onServerSeek";
    
    public static const VOLUME_CHANGE         :String = "onVolumeChange";
    public static const MUTE                  :String = "onMute";
    public static const UNMUTE                :String = "onUnmute";
    
    public static const ENTER_FULL_SCREEN     :String = "onEnterFullScreen";
    public static const EXIT_FULL_SCREEN      :String = "onExitFullScreen";
    
    public static const BUFFER_LENGTH_CHANGE  :String = "onBufferLengthChange";
    public static const STREAM_QUALITY_CHANGE :String = "onStreamQualityChange";
    
    public var data:*;
    
    public function PlayerEvent(type:String, data:*=null, bubbles:Boolean=false, cancelable:Boolean=false) { 
      super(type, bubbles, cancelable);
      
      this.data = data;
    }
    
    public override function clone():Event { 
      return new PlayerEvent(type, this.data, bubbles, cancelable);
    } 
    
    public override function toString():String {
      return formatToString("PlayerEvent", "type", "data", "bubbles", "cancelable", "eventPhase");
    }
  }
}
