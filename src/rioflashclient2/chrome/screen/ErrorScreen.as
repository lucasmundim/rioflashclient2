package rioflashclient2.chrome.screen {
  import rioflashclient2.assets.MessageScreen;
  import rioflashclient2.event.EventBus;

  import flash.display.DisplayObject;
  import flash.display.Sprite;
  import flash.events.ErrorEvent;
  import flash.events.Event;
  import flash.text.TextFormat;

  import org.osmf.logging.Log;
  import org.osmf.logging.Logger;

  public class ErrorScreen extends MessageScreen {
    private var logger:Logger = Log.getLogger('ErrorScreen');

    private static const SIDE_PADDING_PERCENTAGE:Number = 0.125;

    private static const HEADER_HEIGHT:Number = 42;
    private static const TITLE_HEIGHT:Number = 80;
    private static const TEXT_HEIGHT:Number = 160;

    private static const DEFAULT_HEADER:String = "Atenção"
    private static const DEFAULT_TITLE:String = "Ocorreu um erro";
    private static const DEFAULT_DESCRIPTION:String = "Por favor, tente acessar mais tarde.";

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
      this.header.defaultTextFormat = new TextFormat(new VAG42().fontName, 42, 0xFFFFFF);
      this.title.defaultTextFormat = new TextFormat(new Arial20().fontName, 20, 0xFFFFFF);
      this.description.defaultTextFormat = new TextFormat(new Arial15().fontName, 15, 0xFFFFFF);

      this.header.embedFonts = true;
      this.title.embedFonts = true;
      this.description.embedFonts = true;

      resizeAndPosition();
    }

    public function showErrorScreen(header:String=null, title:String=null, description:String=null):void {
      this.header.text = header;
      this.title.text = title;
      this.description.text = description;

      show();
    }

    public function showError(e:Event):void {
      showErrorScreen(DEFAULT_HEADER , DEFAULT_TITLE.toUpperCase(), DEFAULT_DESCRIPTION.toLowerCase());
    }

    private function resizeAndPosition(e:Event=null):void {
      if (stage != null) {
        this.background.width = stage.stageWidth;
        this.background.height = stage.stageHeight;

        position();
      }
    }

    private function position():void {
      resizeAndCenterWidgetHorizontally(this.header);
      resizeAndCenterWidgetHorizontally(this.title);
      resizeAndCenterWidgetHorizontally(this.description);
    }

    private function resizeAndCenterWidgetHorizontally(widget:DisplayObject):void {
      var padding:Number = stage.stageWidth*SIDE_PADDING_PERCENTAGE;
      widget.x = padding;
      widget.width = stage.stageWidth - 2*padding;
    }

    public function show():void {
      visible = true;
    }

    public function hide():void {
      visible = false;
    }
  }
}
