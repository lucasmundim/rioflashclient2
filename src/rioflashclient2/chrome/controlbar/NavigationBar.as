package rioflashclient2.chrome.controlbar {
  import caurina.transitions.Tweener;

  import fl.controls.CheckBox;
  import fl.controls.Label;

  import flash.display.Sprite;
  import flash.events.Event;
  import flash.events.MouseEvent;
  import flash.text.TextFieldAutoSize;

  import org.osmf.logging.Log;
  import org.osmf.logging.Logger;
  import org.osmf.events.TimelineMetadataEvent;
  import org.osmf.metadata.CuePoint;

  import rioflashclient2.assets.ControlBarBackground;
  import rioflashclient2.assets.NavigationFinishButton;
  import rioflashclient2.assets.NavigationFirstButton;
  import rioflashclient2.assets.NavigationNextButton;
  import rioflashclient2.assets.NavigationPrevButton;
  import rioflashclient2.event.EventBus;
  import rioflashclient2.event.SlideEvent;
  import rioflashclient2.event.PlayerEvent;
  import rioflashclient2.model.Lesson;
  import rioflashclient2.model.Slide;

  public class NavigationBar extends Sprite {
    private var logger:Logger = Log.getLogger('NavigationBar');

    private var lesson:Lesson;
    private var slides:Array;

    private var background:ControlBarBackground = new ControlBarBackground();

    private var first:NavigationFirstButton = new NavigationFirstButton();
    private var prev:NavigationPrevButton = new NavigationPrevButton();
    private var next:NavigationNextButton = new NavigationNextButton();
    private var last:NavigationFinishButton = new NavigationFinishButton();

    private var sync:CheckBox = new CheckBox();
    private var slideInfo:Label = new Label();

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
      setupBusListeners()
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

    private function setupBusListeners():void {
      EventBus.addListener(SlideEvent.SLIDE_CHANGED, onSlideChanged, EventBus.INPUT);
      EventBus.addListener(PlayerEvent.LOAD, onLoad);
      EventBus.addListener(TimelineMetadataEvent.MARKER_TIME_REACHED, onSlideCuePoint);
    }

    private function onLoad(e:PlayerEvent):void {

      load(e.data.lesson);
    }

    public function load(lesson:Lesson):void {
      this.lesson = lesson;
      slides = lesson.slides;
    }

    private function onSlideChanged(e:SlideEvent):void {
      updateSlideInfo(e.slide.slide + 1);
    }

    private function onSlideCuePoint(event:TimelineMetadataEvent):void {
      var cuePoint:CuePoint = event.marker as CuePoint;
      if (cuePoint.name.indexOf("Slide") != -1) {
        logger.info("Slide CuePoint reached=" + cuePoint.time);
        if (sync.selected) {
          updateSlideInfo(cuePoint.name.substr(cuePoint.name.indexOf("_")+1, cuePoint.name.length));
        }
      }
    }

    private function updateSlideInfo(value:Number):void {
      slideInfo.text = value + "/" + slides.length;
      resizeAndPosition();
    }

    private function onClickSyncButton(e:MouseEvent):void {
      EventBus.dispatch(new SlideEvent(SlideEvent.SLIDE_SYNC_CHANGED, { sync: sync.selected }), EventBus.INPUT);
    }

    private function onClickNextSlide(e:MouseEvent):void {
      EventBus.dispatch(new SlideEvent(SlideEvent.NEXT_SLIDE), EventBus.INPUT);
    }

    private function onClickPrevSlide(e:MouseEvent):void {
      EventBus.dispatch(new SlideEvent(SlideEvent.PREV_SLIDE), EventBus.INPUT);
    }

    private function onClickFirstSlide(e:MouseEvent):void {
      EventBus.dispatch(new SlideEvent(SlideEvent.FIRST_SLIDE), EventBus.INPUT);
    }

    private function onClickLastSlide(e:MouseEvent):void {
      EventBus.dispatch(new SlideEvent(SlideEvent.LAST_SLIDE), EventBus.INPUT);
    }

    private function setupControls():void {
      addChild(next);
      addChild(prev);
      addChild(last);
      addChild(first);
      sync.selected = true;
      addChild(sync);
      slideInfo.text = "";
      slideInfo.autoSize = TextFieldAutoSize.LEFT;
      addChild(slideInfo);
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
      slideInfo.y = 10;
      slideInfo.x = background.width - sync.width - slideInfo.width - 10;
      slideInfo.setStyle("color", "0xFFFFFF");
    }
  }
}