package rioflashclient2.logging {
  import org.osmf.logging.Logger;
  import org.osmf.logging.LoggerFactory;
  
  public class EventfulLoggerFactory extends LoggerFactory {
    private var logLevel:int;
    
    public function EventfulLoggerFactory(logLevel:int=4) {
      super();
      
      this.logLevel = logLevel || 4;
    }
    
    override public function getLogger(category:String):Logger {
      return new EventfulLogger(category, this.logLevel);
    }
  }
}