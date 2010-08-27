package rioflashclient2.event {
  
  import rioflashclient2.event.EventBus;
  import flash.events.Event;
  import org.flexunit.Assert;
  import org.flexunit.async.Async;
  
  public class EventBusTest {
    
    private var some_event:String;
    private var some_func:Function;
    
    [Before]
    public function setUp():void {
      some_event = "some_event";
      some_func = function():void {};
    }
    
    [Test]
    public function shouldAddListener():void {
      EventBus.addListener(some_event, some_func);
      
      Assert.assertTrue(EventBus.getInstance().hasEventListener(some_event));
    }
    
    [Test(async, timeout="3000")]
    public function shouldDispatchEvent():void {
      Async.proceedOnEvent(this, EventBus.getInstance(), some_event);
      
      EventBus.dispatch(new Event(some_event));
    }
    
  }
}