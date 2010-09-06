package rioflashclient2.event {
  import flash.events.Event;
  import flash.events.EventDispatcher;

  import org.osmf.logging.Log;
  import org.osmf.logging.Logger;
  
  public class EventBus extends EventDispatcher {
    /**
    * The name of the default bus.
    */
    public static const DEFAULT_BUS:String = 'default';

    /**
    * The name of the user input bus.
    */
    public static const INPUT:String = 'input';
  
    private static var instances:Object = {};

    private var logger:Logger;
    private var name:String;
    private var enabled:Boolean;

    public function EventBus(name:String=DEFAULT_BUS) {
      this.name = name;
      enable();

      logger = Log.getLogger('EventBus(' + name + ')');
    }
    
    override public function dispatchEvent(event:Event):Boolean {
      if (isEnabled()) {
        logger.debug('Dispatching event {0}: {1}', event.type, event.toString());

        return super.dispatchEvent(event);
      } else {
        logger.warn('Event bus disabled, not dispatching event {0}.', event.type);

        return false;
      }
    }

    override public function addEventListener(type:String, listener:Function, useCapture:Boolean=false, priority:int=0, useWeakReference:Boolean=false):void {
      logger.debug('Adding listener for {0}.', type);

      return super.addEventListener(type, listener, useCapture, priority, useWeakReference);
    }

    public function isEnabled():Boolean {
      return enabled;
    }

    public function enable():void {
      enabled = true;
    }

    public function disable():void {
      enabled = false;
    }
    
    public static function getInstance(name:String=DEFAULT_BUS):EventBus {
      if (!instances[name]) {
        instances[name] = new EventBus(name);
      }
      
      return instances[name];
    }
    
    public static function addListener(type:String, listener:Function, name:String=DEFAULT_BUS):void {
      getInstance(name).addEventListener(type, listener);
    }
    
    public static function dispatch(event:Event, name:String='default'):Boolean {
      return getInstance(name).dispatchEvent(event);
    }
  }
}