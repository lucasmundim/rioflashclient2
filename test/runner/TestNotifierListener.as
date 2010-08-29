package runner
{
  import com.adobe.serialization.json.JSON;
  
  import flash.events.Event;
  import flash.events.EventDispatcher;
  import flash.events.IOErrorEvent;
  import flash.events.SecurityErrorEvent;
  import flash.events.TextEvent;
  import flash.net.Socket;
  
  import org.flexunit.reporting.FailureFormatter;
  import org.flexunit.runner.IDescription;
  import org.flexunit.runner.Result;
  import org.flexunit.runner.notification.Failure;
  import org.flexunit.runner.notification.IRunListener;
  import org.flexunit.runner.notification.async.AsyncListenerWatcher;
  
  
  public class TestNotifierListener extends EventDispatcher implements IRunListener {
    private var socket:Socket;
    
    /**
     * The port used to communicate with the server receiving data. 
     */
    public var port:uint = 22222;
    
    /**
     * The ip address of the server receiving data.
     */
    public var server:String = "localhost";
    
    private var lastFailedTest:IDescription;
    
    public function connect():void {
      socket = new Socket();
      
      socket.addEventListener(Event.CONNECT, onConnect);
      socket.addEventListener(IOErrorEvent.IO_ERROR, onError);
      socket.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onError);
      socket.addEventListener(Event.CLOSE, onClose);
      
      try {
        socket.connect(server, port);
      } catch (e:Error) {
        trace (e.message);
      }
    }
    
    public function testRunStarted(description:IDescription):void{
      // do nothing
    }
    
    public function testRunFinished(result:Result):void {
      sendTestResults(result);
    }
    
    public function testStarted(description:IDescription):void {
      // do nothing
    }
    
    public function testFinished(description:IDescription):void {
      if (!hasFailed(description)) {
        sendSuccessTest(description);
      }
    }
    
    public function testAssumptionFailure(failure:Failure):void {
      lastFailedTest = failure.description;
      sendFailedTest(failure);
    }
    
    public function testIgnored(description:IDescription):void {
      // do nothing
    }
    
    public function testFailure(failure:Failure):void {
      lastFailedTest = failure.description;
      sendFailedTest(failure);
    }
    
    private function hasFailed(description:IDescription):Boolean {
      return lastFailedTest && lastFailedTest.displayName == description.displayName;
    }
    
    private function isError(failure:Failure):Boolean {
      return FailureFormatter.isError(failure.exception);
    }
    
    private function sendSuccessTest(description:IDescription):void {
      var successTest:Object = { type: 'test', name: description.displayName, status: 'success' };
      sendData(successTest);
    }
    
    private function sendFailedTest(failure:Failure):void {
      var failedTest:Object = {
        type: 'test',
        name: failure.description.displayName,
        status: isError(failure) ? 'error' : 'failure',
        message: failure.message,
        backtrace: failure.stackTrace
      };
      sendData(failedTest);
    }
    
    private function sendTestResults(result:Result):void {
      var testResults:Object = {
        type: 'results',
        successful: result.successful,
        elapsed_time: result.runTime,
        test_count: result.runCount,
        failures_count: result.failureCount,
        ignored_count: result.ignoreCount
      };
      sendData(testResults);
    }
    
    protected function sendData(object:Object):void{
      if (socket.connected) {
        socket.writeUTFBytes(JSON.encode(object) + '\n');
        socket.flush();
      }
    }
    
    private function onConnect(event:Event):void {
      dispatchEvent(new Event(AsyncListenerWatcher.LISTENER_READY));
    }
    
    private function onError(event:Event):void {
      dispatchEvent(new TextEvent(AsyncListenerWatcher.LISTENER_FAILED, false, false, event.toString()));
    }
    
    private function onClose(event:Event):void {
      // server closed connection.
    }
  }
}