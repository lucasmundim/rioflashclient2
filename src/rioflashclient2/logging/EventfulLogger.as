package rioflashclient2.logging {
  import rioflashclient2.event.LoggerEvent;
  
  import flash.events.Event;
  import flash.events.EventDispatcher;
  
  import org.osmf.logging.Log;
  import org.osmf.logging.Logger;
  
  /**
   * ...
   * @author 
   */
  public class EventfulLogger extends Logger {
    private static const LEVEL_DEBUG:String = "DEBUG";
    private static const LEVEL_WARN :String = "WARN";
    private static const LEVEL_INFO :String = "INFO";
    private static const LEVEL_ERROR:String = "ERROR";
    private static const LEVEL_FATAL:String = "FATAL";
    
    public var level:int;
    
    private var eventDispatcher:EventDispatcher;
    
    private static var rootLogger:EventfulLogger;
    
    public function EventfulLogger(category:String, logLevel:int) {
      super(category);
      
      this.level = logLevel;
      
      eventDispatcher = new EventDispatcher();
    }
    
    public static function root():EventfulLogger {
      if (rootLogger == null) {
        rootLogger = Log.getLogger('root') as EventfulLogger;
      }
      
      return rootLogger;
    }
    
    public function isRootLogger():Boolean {
      return this.category == 'root';
    }
    
    public function dispatchEvent(event:Event):void {
      eventDispatcher.dispatchEvent(event);
    }
    
    public function addEventListener(type:String, listener:Function, useCapture:Boolean=false, priority:int=0, useWeakReference:Boolean=false):void {
      eventDispatcher.addEventListener(type, listener, useCapture, priority, useWeakReference);
    }
    
    public function removeEventListener(type:String, listener:Function, useCapture:Boolean=false):void {
      eventDispatcher.removeEventListener(type, listener, useCapture);
    }
    
    override public function debug(message:String, ...rest):void {
      logMessage(LEVEL_DEBUG, message, rest);
    }
    
    override public function info(message:String, ...rest):void {
      logMessage(LEVEL_INFO, message, rest);
    }
    
    override public function warn(message:String, ...rest):void {
      logMessage(LEVEL_WARN, message, rest);
    }
    
    override public function error(message:String, ...rest):void {
      logMessage(LEVEL_ERROR, message, rest);
    }
    
    override public function fatal(message:String, ...rest):void {
      logMessage(LEVEL_FATAL, message, rest);
    }
    
    private function logMessage(level:String, message:String, params:Array):void {
      if (shouldLog(level)) {
        var message:String = buildMessage(level, message, params);
        
        trace(message);
        dispatchLoggerEvent(message);
      }
    }
    
    private function buildMessage(level:String, message:String, params:Array):String {
      var msg:String = "";
      msg += new Date().toLocaleString() + " [" + level + "] ";
      msg += "[" + category + "] " + applyParams(message, params);
      return msg;
    }
    
    private function applyParams(message:String, params:Array):String {
      var result:String = message;
      
      for (var i:int = 0; i < params.length; i++) {
        result = result.replace(new RegExp("\\{" + i + "\\}", "g"), params[i]);
      }
      
      return result;
    }
    
    private function logLevel(level:String):int {
      switch (level) {
        case LEVEL_FATAL:
          return 0;
          break;
        case LEVEL_ERROR:
          return 1;
          break;
        case LEVEL_WARN:
          return 2;
          break;
        case LEVEL_INFO:
          return 3;
          break;
        case LEVEL_DEBUG:
          return 4;
          break;
        default:
          return 5;
          break;
      }
    }
    
    private function shouldLog(level:String):Boolean {
      return logLevel(level) <= this.level;
    }
    
    private function dispatchLoggerEvent(message:String):void {
      var event:LoggerEvent = new LoggerEvent(LoggerEvent.LOGGER_EVENT, message);
      
      dispatchEvent(event);
      
      if (!this.isRootLogger()) {
        EventfulLogger.root().dispatchEvent(event);
      }
    }
  }
}

