package rioflashclient2.chrome.screen {
  import rioflashclient2.assets.MessageScreen;
  import rioflashclient2.event.EventBus;
  
  import flash.display.Sprite;
  import flash.events.ErrorEvent;
  import flash.events.Event;
  import flash.text.TextFormat;
  
  import org.osmf.logging.Log;
  import org.osmf.logging.Logger;
  
  public class ErrorScreen extends MessageScreen {
    private var logger:Logger = Log.getLogger('ErrorScreen');
    
    private static const SIDE_PADDING:Number = 50;

    private static const HEADER_HEIGHT:Number = 40;
    private static const TITLE_HEIGHT:Number = 100;
    private static const TEXT_HEIGHT:Number = 140;

    private static const DEFAULT_HEADER:String = "OOPS!"
    private static const DEFAULT_TITLE:String = "Vídeo indisponível no momento";
    private static const DEFAULT_TEXT:String = "O vídeo que você está tentando assistir não foi encontrado ou está temporariamente indisponível. Por favor, tente acessa-lo mais tarde.";
    
    public function ErrorScreen() {
      if (!!stage) init();
      else addEventListener(Event.ADDED_TO_STAGE, init);
    }
    
    private function init(e:Event=null):void {
      setupBusListeners();
      setupEventListeners();
      setupInterface();
      
      hide();
    }
    
    private function setupBusListeners():void {
      EventBus.addListener(ErrorEvent.ERROR, onError);
    }
    
    private function setupEventListeners():void {
      stage.addEventListener(Event.RESIZE, resizeAndPosition);
    }

    private function onError(e:ErrorEvent):void {
      logger.error('An error occurred: ' + e.text);
      disableEventBus();
      showError(e);
    }

    private function disableEventBus():void {
      logger.info('Disabling default event bus.');
      EventBus.getInstance().disable();

      logger.info('Disabling input event bus.');
      EventBus.getInstance(EventBus.INPUT).disable();
    }
    
    private function setupInterface():void {
      this.header.defaultTextFormat = new TextFormat("Arial", 35, 0x333333, true);
      this.title.defaultTextFormat = new TextFormat("Arial", 20, 0x333333, true);
      this.description.defaultTextFormat = new TextFormat("Arial", 13, 0x666666, true);

      resizeAndPosition();
    }
    
    public function showErrorScreen(header:String=null, title:String=null, text:String=null):void {
      this.header.text = header;
      this.title.text = title;
      this.description.text = text;
      
      show();
    }    
    
    public function showError(e:Event):void {
      showErrorScreen(DEFAULT_HEADER , DEFAULT_TITLE.toUpperCase(), DEFAULT_TEXT.toLowerCase());
    }
    
    private function resizeAndPosition(e:Event=null):void {
      if (stage != null) {
        this.background.width = stage.stageWidth;
        this.background.height = stage.stageHeight;

        position();
      }
    }
    
    private function position():void {
      this.header.x = SIDE_PADDING;
      this.header.y = HEADER_HEIGHT;
      this.title.x = SIDE_PADDING;
      this.title.y = TITLE_HEIGHT;
      this.description.x = SIDE_PADDING;
      this.description.y = TEXT_HEIGHT;
    }
  
    public function show():void {
      visible = true;
    }

    public function hide():void {
      visible = false;
    }
  }
}
