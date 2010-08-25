package rioflashclient2.model {
  import rioflashclient2.event.EventBus;
  
  import flash.events.ErrorEvent;
  import flash.events.Event;
  import flash.events.IOErrorEvent;
  import flash.events.SecurityErrorEvent;
  import flash.events.TextEvent;
  import flash.net.URLLoader;
  import flash.net.URLRequest;
  import flash.utils.getQualifiedClassName;
  
  import org.osmf.logging.Log;
  import org.osmf.logging.Logger;
  
  public class GenericLoader {
    private var loader:URLLoader;
    
    protected var logger:Logger;
    
    public function GenericLoader() {
      this.logger = Log.getLogger(getClassName());
      this.loader = new URLLoader();
    }
    
    public function load():void {
      logger.info('Loading...');
      
      addLoadURLListeners();
      loader.load(createRequest());
    }
    
    protected function url():String {
      throw new Error('Must be implemented by subclasses');
    }
    
    protected function loaded(data:*):void {
      throw new Error('Must be implemented by subclasses');
    }
    
    protected function onLoad(e:Event):void {
      var loader:URLLoader = e.target as URLLoader;
      
      loaded(loader.data);
    }
    
    protected function onError(e:TextEvent):void {
      EventBus.dispatch(new ErrorEvent(ErrorEvent.ERROR, false, false, e.text));
    }
    
    private function addLoadURLListeners():void {
      loader.addEventListener(Event.COMPLETE, onLoad);
      loader.addEventListener(IOErrorEvent.IO_ERROR, onError);
      loader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onError);
    }
    
    private function createRequest():URLRequest {
      var request:URLRequest = new URLRequest();
      request.url = this.url();
      return request;
    }
    
    private function getClassName():String {
      return getQualifiedClassName(this).split('::')[1];
    }
  }
}