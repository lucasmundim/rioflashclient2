package runner {
  import flash.errors.IOError;
  import flash.events.Event;
  import flash.events.IOErrorEvent;
  import flash.events.ProgressEvent;
  import flash.events.SecurityErrorEvent;
  import flash.net.Socket;
  
  public class TestResultNotifier extends Socket {
    public function TestResultNotifier() {
      super();
      
      configureListeners();
      
      super.connect('localhost', 22222);
    }
    
    private function configureListeners():void {
      addEventListener(Event.CLOSE, closeHandler);
      addEventListener(Event.CONNECT, connectHandler);
      addEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);
      addEventListener(SecurityErrorEvent.SECURITY_ERROR, securityErrorHandler);
      addEventListener(ProgressEvent.SOCKET_DATA, socketDataHandler);
    }
    
    public function notifySuccess():void {
      sendData('success');
    }
    
    public function notifyFailure():void {
      sendData('failure');
    }
    
    private function writeln(str:String):void {
      try {
        writeUTFBytes(str + "\n");
        flush();
      } catch(e:IOError) {
        // trace errors
        trace(e);
      }
    }
    
    private function sendData(text:String):void {
      writeln(text);
    }
    
    private function closeHandler(event:Event):void {
      // do nothing when closed
    }
    
    private function connectHandler(event:Event):void {
      // connected
    }
    
    private function ioErrorHandler(event:IOErrorEvent):void {
      // trace errors
      trace("ioErrorHandler: " + event);
    }
    
    private function securityErrorHandler(event:SecurityErrorEvent):void {
      // trace errors
      trace("securityErrorHandler: " + event);
    }
    
    private function socketDataHandler(event:ProgressEvent):void {
      // ignore responses
    }
  }
}