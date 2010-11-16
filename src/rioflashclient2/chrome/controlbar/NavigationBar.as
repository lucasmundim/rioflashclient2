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
  import org.osmf.events.TimeEvent;

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
    private var duration:Number = 0;
    private var videoPlayerCurrentTime:Number;

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
        list[i].stop();
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
      EventBus.addListener(SlideEvent.SLIDE_SYNC_CHANGED, onSlideSyncChanged, EventBus.INPUT);

      EventBus.addListener(PlayerEvent.LOAD, onLoad);
      EventBus.addListener(PlayerEvent.SEEK, onSeek);
      EventBus.addListener(PlayerEvent.TOPICS_SEEK, onTopicsSeek);
      EventBus.addListener(PlayerEvent.DURATION_CHANGE, onDurationChange);

      EventBus.addListener(TimeEvent.CURRENT_TIME_CHANGE, onCurrentTimeChange);
      EventBus.addListener(TimelineMetadataEvent.MARKER_TIME_REACHED, onSlideCuePoint);
    }

    private function onLoad(e:PlayerEvent):void {
      load(e.data.lesson);
    }

    public function load(lesson:Lesson):void {
      this.lesson = lesson;
      slides = lesson.slides;
    }

    private function onSeek(e:PlayerEvent):void {
      if (sync.selected) {
        var seekPercentage:Number = (e.data as Number);
        if (seekPercentage <= 0) {
          seekPercentage = 1 / duration;
        }
        var seekPosition:Number = calculatedSeekPositionGivenPercentage(seekPercentage);
        updateSlideInfo(findNearestSlide(seekPosition) + 1);
      }
    }

    private function onTopicsSeek(e:PlayerEvent):void {
      if (sync.selected) {
        var seekPosition:Number = e.data;
        updateSlideInfo(findNearestSlide(seekPosition));
      }
    }

    private function calculatedSeekPositionGivenPercentage(seekPercentage:Number):Number {
      return seekPercentage * duration;
    }

    private function onDurationChange(e:PlayerEvent):void {
      duration = e.data;
    }

    private function onCurrentTimeChange(e:TimeEvent):void {
      videoPlayerCurrentTime = e.time;
    }

    private function onSlideSyncChanged(e:SlideEvent):void {
      if (e.slide.sync) {
        updateSlideInfo(findNearestSlide(videoPlayerCurrentTime) + 1);
      }
    }

    private function findNearestSlide(seekPosition:Number):Number {
      var last:Number = 0;
      for (var i:uint = 0; i < slides.length; i++) {
        if (seekPosition < slides[i].time) {
          return i - 1;
        }
        last = i;
      }
      return last;
    }

    private function onSlideChanged(e:SlideEvent):void {
      updateSlideInfo(e.slide.slide + 1);
    }

    private function onSlideCuePoint(event:TimelineMetadataEvent):void {
      var cuePoint:CuePoint = event.marker as CuePoint;
      if (cuePoint.name.indexOf("Slide") != -1) {
        logger.info("Slide CuePoint reached=" + cuePoint.time);
        if (sync.selected) {
          updateSlideInfo(Number(cuePoint.name.substr(cuePoint.name.indexOf("_")+1, cuePoint.name.length)));
        }
      }
    }

    private function updateSlideInfo(value:Number):void {
      var actualSlide:String = value <= 9 ? "0"+value : value;
      var totalSlides:String = slides.length <= 9 ? "0"+slides.length : slides.length;
      slideInfo.text = actualSlide + "/" + totalSlides;
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
      slideInfo.text = "00/00";
      slideInfo.width = 50;
      slideInfo.setStyle("align", "center");
      //slideInfo.autoSize = TextFieldAutoSize.LEFT;
      addChild(slideInfo);
    }

    private function onOver(e:MouseEvent):void {
      e.target.gotoAndStop(2);
      //Tweener.addTween(e.target, { time: 1, alpha: 0.4 });
    }

    private function onOut(e:MouseEvent):void {
      e.target.gotoAndStop(1);
      //Tweener.addTween(e.target, { time: 1, alpha: 1 });
    }

    private function resizeAndPosition():void
    {
      first.y = prev.y = last.y = next.y = 8;
      slideInfo.y = sync.y = 10;
      first.x = 20;
      prev.x = first.x + first.width + PADDING;
      slideInfo.x = prev.x + prev.width + (PADDING*4);
      slideInfo.setStyle("color", "0x666666");
      next.x = slideInfo.x + slideInfo.width + PADDING;
      last.x = next.x + next.width + PADDING;
      sync.label = "Sincronizar";
      sync.setStyle("color", "0x666666");
      sync.x = background.width - sync.width;
    }
  }
}