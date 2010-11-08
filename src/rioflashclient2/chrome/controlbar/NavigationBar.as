package rioflashclient2.chrome.controlbar {
  import caurina.transitions.Tweener;

  import fl.controls.CheckBox;

  import flash.display.Sprite;
  import flash.events.Event;
  import flash.events.MouseEvent;

  import org.osmf.logging.Log;
  import org.osmf.logging.Logger;

  import rioflashclient2.assets.ControlBarBackground;
  import rioflashclient2.assets.NavigationFinishButton;
  import rioflashclient2.assets.NavigationFirstButton;
  import rioflashclient2.assets.NavigationNextButton;
  import rioflashclient2.assets.NavigationPrevButton;
  import rioflashclient2.event.EventBus;
  import rioflashclient2.event.SlideEvent;

  public class NavigationBar extends Sprite {
    private var logger:Logger = Log.getLogger('NavigationBar');

    private var background:ControlBarBackground = new ControlBarBackground();

    private var first:NavigationFirstButton = new NavigationFirstButton();
    private var prev:NavigationPrevButton = new NavigationPrevButton();
    private var next:NavigationNextButton = new NavigationNextButton();
    private var last:NavigationFinishButton = new NavigationFinishButton();

    private var sync:CheckBox = new CheckBox();

    private static const PADDING:Number = 5;

    public function NavigationBar() {
      this.name = 'NavigationBar';
      this.tabChildren = false;
      if (!!stage) init();
      else addEventListener(Event.ADDED_TO_STAGE, init);
    }

    public function setSize(newWidth:Number = 640, newHeight:Number = 37):void {
      background.width = newWidth;
      resizeAndPosition();
    }

    private function init(e:Event=null):void {
      logger.info('Initializing navigation bar...');
      setupBackground();
      setupControls();
      setupEventListeners();
      resizeAndPosition();
    }

    private function setupBackground():void {
      addChild(background);
    }

    private function setupEventListeners():void {
      var list:Array = [next, prev, first, last];
      for(var i:uint = 0; i < list.length; i++){
        list[i].buttonMode = true;
        list[i].addEventListener(MouseEvent.ROLL_OVER, onOver);
        list[i].addEventListener(MouseEvent.ROLL_OUT, onOut);
        list[i].addEventListener(MouseEvent.MOUSE_OVER, onOver);
        list[i].addEventListener(MouseEvent.MOUSE_OUT, onOut);
      }

      next.addEventListener(MouseEvent.CLICK, onClickNextSlide);
      prev.addEventListener(MouseEvent.CLICK, onClickPrevSlide);
      first.addEventListener(MouseEvent.CLICK, onClickFirstSlide);
      last.addEventListener(MouseEvent.CLICK, onClickLastSlide);
      sync.addEventListener(MouseEvent.CLICK, onClickSyncButton);
    }

    private function onClickSyncButton(e:MouseEvent):void {
      if (sync.selected) {
        EventBus.dispatch(new SlideEvent(SlideEvent.CURRENT_SLIDE, { sync: false }), EventBus.INPUT);
      }
    }

    private function onClickNextSlide(e:MouseEvent):void {
      EventBus.dispatch(new SlideEvent(SlideEvent.NEXT_SLIDE, { sync: sync.selected }), EventBus.INPUT);
    }

    private function onClickPrevSlide(e:MouseEvent):void {
      EventBus.dispatch(new SlideEvent(SlideEvent.PREV_SLIDE, { sync: sync.selected }), EventBus.INPUT);
    }

    private function onClickFirstSlide(e:MouseEvent):void {
      EventBus.dispatch(new SlideEvent(SlideEvent.FIRST_SLIDE, { sync: sync.selected }), EventBus.INPUT);
    }

    private function onClickLastSlide(e:MouseEvent):void {
      EventBus.dispatch(new SlideEvent(SlideEvent.LAST_SLIDE, { sync: sync.selected }), EventBus.INPUT);
    }

    private function setupControls():void {
      addChild(next);
      addChild(prev);
      addChild(last);
      addChild(first);
      sync.selected = true;
      addChild(sync);
    }

    private function onOver(e:MouseEvent):void {
      Tweener.addTween(e.target, { time: 1, alpha: 0.4 });
    }

    private function onOut(e:MouseEvent):void {
      Tweener.addTween(e.target, { time: 1, alpha: 1 });
    }

    private function resizeAndPosition():void
    {
      sync.y = 10;
      first.y = prev.y = last.y = next.y = 8;
      prev.x = first.x + first.width + PADDING;
      next.x = prev.x + first.width + PADDING;
      last.x = next.x + next.width + PADDING;
      sync.label = "Sincronizar";
      sync.setStyle("color", "0xFFFFFF");
      sync.x = background.width - sync.width;
    }
  }
}