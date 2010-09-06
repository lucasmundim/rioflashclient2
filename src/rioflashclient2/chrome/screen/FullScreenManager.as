package rioflashclient2.chrome.screen {
  import rioflashclient2.event.EventBus;
  import rioflashclient2.event.PlayerEvent;
  
  import flash.display.Stage;
  import flash.display.StageDisplayState;
  import flash.events.FullScreenEvent;
  
  import org.osmf.logging.Log;
  import org.osmf.logging.Logger;
  
  public class FullScreenManager {
    private var logger:Logger = Log.getLogger('FullScreenManager');
    
    private var stage:Stage;
    
    public function FullScreenManager(stage:Stage) {
      this.stage = stage;
      
      setupEventListeners();
      setupInputBusListeners();
    }
    
    private function setupEventListeners():void {
      stage.addEventListener(FullScreenEvent.FULL_SCREEN, fullScreenChanged);
    }
    
    private function setupInputBusListeners():void {
      EventBus.addListener(PlayerEvent.ENTER_FULL_SCREEN, onEnterFullScreen, EventBus.INPUT);
      EventBus.addListener(PlayerEvent.EXIT_FULL_SCREEN, onExitFullScreen, EventBus.INPUT);
    }
    
    private function onEnterFullScreen(e:PlayerEvent):void {
      stage.displayState = StageDisplayState.FULL_SCREEN;
    }
    
    private function onExitFullScreen(e:PlayerEvent):void {
      stage.displayState = StageDisplayState.NORMAL;
    }
    
    private function fullScreenChanged(e:FullScreenEvent):void {
      if (e.fullScreen) {
        logger.info('Entering full screen.');
        EventBus.dispatch(new PlayerEvent(PlayerEvent.ENTER_FULL_SCREEN));
      } else {
        logger.info('Exiting full screen.');
        EventBus.dispatch(new PlayerEvent(PlayerEvent.EXIT_FULL_SCREEN));
      }
    }
  }
}