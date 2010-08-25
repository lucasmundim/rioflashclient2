package rioflashclient2.event {
  
  import flash.events.Event;
  import flash.events.EventDispatcher;
  
  public class EventBus extends EventDispatcher {
    public function EventBus() {
    }
    
    private static var _instance:EventBus;
    
    public static function getInstance():EventBus {
      if (_instance == null) {
        _instance = new EventBus();
      }
      
      return _instance;
    }
    
    public static function addListener(type:String, listener:Function):void {
      getInstance().addEventListener(type, listener);
    }
    
    public static function dispatch(event:Event):void {
      getInstance().dispatchEvent(event);
    }
  }
}