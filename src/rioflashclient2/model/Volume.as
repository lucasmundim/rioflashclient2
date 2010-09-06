package rioflashclient2.model {
  import rioflashclient2.event.EventBus;
  import rioflashclient2.event.PlayerEvent;
  
  public class Volume {
    private var currentVolumeLevel:Number;
    private var lastOnVolumeLevel:Number = 1;
    
    public function Volume() {
      setupInputBusListeners();
    }
    
    private function isMuted():Boolean {
      return currentVolumeLevel == 0;
    }
    
    private function saveLastOnVolumeLevel():void {
      if (currentVolumeLevel > 0) {
        lastOnVolumeLevel = currentVolumeLevel;
      }
    }
    
    private function changeVolumeLevel(level:Number):void {
      saveLastOnVolumeLevel();
      currentVolumeLevel = level;
      EventBus.dispatch(new PlayerEvent(PlayerEvent.VOLUME_CHANGE, level));
    }
    
    private function onInputMute(e:PlayerEvent):void {
      if (!isMuted()) {
        EventBus.dispatch(new PlayerEvent(PlayerEvent.MUTE));
        
        changeVolumeLevel(0);
      }
    }
    
    private function onInputUnmute(e:PlayerEvent):void {
      if (isMuted()) {
        EventBus.dispatch(new PlayerEvent(PlayerEvent.UNMUTE));
        
        changeVolumeLevel(lastOnVolumeLevel);
      }
    }
    
    private function onInputVolumeChange(e:PlayerEvent):void {
      changeVolumeLevel(e.data);
    }
    
    private function setupInputBusListeners():void {
      EventBus.addListener(PlayerEvent.MUTE, onInputMute, EventBus.INPUT);
      EventBus.addListener(PlayerEvent.UNMUTE, onInputUnmute, EventBus.INPUT);
      EventBus.addListener(PlayerEvent.VOLUME_CHANGE, onInputVolumeChange, EventBus.INPUT);
    }
  }
}