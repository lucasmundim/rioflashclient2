package rioflashclient2.event {
  import flash.events.Event;

  public class LoggerEvent extends Event {
    public static const LOGGER_EVENT:String = "loggerEvent";
    
    public var message:String;
    
    public function LoggerEvent(type:String, message:String=null, bubbles:Boolean=false, cancelable:Boolean=false) { 
      super(type, bubbles, cancelable);
      
      this.message = message;
    } 
    
    public override function clone():Event {
      return new LoggerEvent(type, this.message, bubbles, cancelable);
    } 
    
    public override function toString():String {
      return formatToString("LoggerEvent", "type", "message", "bubbles", "cancelable", "eventPhase"); 
    }
  }
}
