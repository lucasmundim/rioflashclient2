package rioflashclient2.event {
  
  import flash.events.Event;
  import flash.events.EventDispatcher;

  import org.osmf.logging.Log;
  import org.osmf.logging.Logger;
  
  public class EventBus extends EventDispatcher {
    private static var instances:Object = {};

    private var logger:Logger;
    private var name:String;

    public function EventBus(name:String='default') {
      this.name = name;

      logger = Log.getLogger('EventBus(' + name + ')');
    }
    
    override public function dispatchEvent(event:Event):Boolean {
      logger.debug('Dispatching event {0}: {1}', event.type, event.toString());
     
      return super.dispatchEvent(event);
    }

    override public function addEventListener(type:String, listener:Function, useCapture:Boolean=false, priority:int=0, useWeakReference:Boolean=false):void {
      logger.debug('Adding listener for {0}.', type);

      return super.addEventListener(type, listener, useCapture, priority, useWeakReference);
    }
    
    public static function getInstance(name:String='default'):EventBus {
      if (!instances[name]) {
        instances[name] = new EventBus(name);
      }
      
      return instances[name];
    }
    
    public static function addListener(type:String, listener:Function, name:String='default'):void {
      getInstance(name).addEventListener(type, listener);
    }
    
    public static function dispatch(event:Event, name:String='default'):Boolean {
      return getInstance(name).dispatchEvent(event);
    }
  }
}