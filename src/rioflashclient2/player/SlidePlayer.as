package rioflashclient2.player {
  import br.com.stimuli.loading.BulkLoader;
  import br.com.stimuli.loading.BulkProgressEvent;

  import caurina.transitions.Tweener;

  import flash.events.Event;
  import flash.display.MovieClip;
  import flash.display.Loader;

  import org.osmf.events.TimeEvent;
  import org.osmf.logging.Log;
  import org.osmf.logging.Logger;
  import org.osmf.events.TimelineMetadataEvent;
  import org.osmf.metadata.CuePoint;

  import rioflashclient2.configuration.Configuration;
  import rioflashclient2.event.EventBus;
  import rioflashclient2.event.PlayerEvent;
  import rioflashclient2.event.SlideEvent;
  import rioflashclient2.model.Lesson;
  import rioflashclient2.model.Slide;
  import rioflashclient2.model.Video;

  public class SlidePlayer extends MovieClip {
    private var logger:Logger = Log.getLogger('SlidePlayer');
    private var loader:BulkLoader;

    private var lesson:Lesson;
    private var slides:Array;
    private var currentSlide:Number = 0;
    private var container:MovieClip;
    private var sync:Boolean = true;
    private var duration:Number = 0;
    private var videoPlayerCurrentTime:Number;

    private var measuredWidth:Number;
    private var measuredHeight:Number;

    public function SlidePlayer() {
      this.name = 'SlidePlayer';
      if (!!stage) init();
      else addEventListener(Event.ADDED_TO_STAGE, init);
    }

    private function init(e:Event=null):void {
      setupBusListeners();
      container = new MovieClip();
      addChild(container);
      resize();
    }

    private function onLoad(e:PlayerEvent):void {
      lesson = e.data.lesson;
      slides = lesson.slides;
      duration = lesson.duration;
      load();
    }

    public function load():void {
      loader = new BulkLoader('slides');
      for ( var i:uint = 0; i< slides.length; i++) {
        var slide:Slide = slides[i];
        var slideURL:String = Configuration.getInstance().resourceURL(slide.relative_path);
        loader.add(slideURL, { id: ("slide_" + i), priority: (slides.length - i), type: "movieclip" });
        loader.get("slide_" + i).addEventListener(Event.COMPLETE, onSingleItemLoaded);
      }
      loader.get("slide_0").addEventListener(Event.COMPLETE, onFirstItemLoaded);
      loader.addEventListener(BulkLoader.COMPLETE, onAllItemsLoaded);
      loader.addEventListener(BulkLoader.PROGRESS, onAllProgress);
      loader.start(1);
    }

    public function onSingleItemLoaded(e:Event):void {
      trace("carregou");
    }

    public function onFirstItemLoaded(e:Event):void {
      showSlide(0);
      var sl:Loader = container.getChildByName("slide_0");
      if (sl.width > sl.height) {
        resizeContainer(measuredWidth, (sl.height * measuredWidth / sl.width));
      } else {
        resizeContainer((sl.width * measuredHeight / sl.height), measuredHeight);
      }
    }

    public function onAllItemsLoaded(e:Event) : void {
      trace("foi tudo");
    }

    public function onAllProgress(e:BulkProgressEvent) : void {
      //trace("Loaded" , e.itemsLoaded," of ",  e.itemsTotal);
    }

    private function onFirstSlide(e:SlideEvent):void {
      changeSlideTo(0)
    }

    private function onLastSlide(e:SlideEvent):void {
      changeSlideTo(slides.length - 1);
    }

    private function onPreviousSlide(e:SlideEvent):void {
      if (currentSlide > 0) {
        changeSlideTo(currentSlide - 1);
      }
    }

    private function onNextSlide(e:SlideEvent):void {
      if (currentSlide < (slides.length - 1)) {
        changeSlideTo(currentSlide + 1);
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

    private function onDurationChange(e:PlayerEvent):void {
      duration = e.data;
    }

    private function onCurrentTimeChange(e:TimeEvent):void {
      videoPlayerCurrentTime = e.time;
    }

    private function onSlideSyncChanged(e:SlideEvent):void {
      sync = e.slide.sync;
      if (sync) {
        var time:Number = slides[findNearestSlide(videoPlayerCurrentTime)].time
        showSlideByPosition(time);
      }
    }

    private function onSeek(e:PlayerEvent):void {
      if (sync) {
        var seekPercentage:Number = (e.data as Number);
        if (seekPercentage <= 0) {
          seekPercentage = 1 / duration;
        }
        var seekPosition:Number = calculatedSeekPositionGivenPercentage(seekPercentage);
        logger.info('Slide Seeking to position {0} in seconds, given percentual {1}.', seekPosition, seekPercentage);
        showSlideByPosition(seekPosition);
      }
    }

    private function onTopicsSeek(e:PlayerEvent):void {
      if (sync) {
        var seekPosition:Number = e.data;
        logger.info('Slide Seeking to position {0} in seconds.', seekPosition);
        showSlideByPosition(seekPosition);
      }
    }

    private function onSlideCuePoint(event:TimelineMetadataEvent):void {
      if (sync) {
        var cuePoint:CuePoint = event.marker as CuePoint;
        if (cuePoint.name.indexOf("Slide") != -1) {
          var slideNumber:Number = Number(cuePoint.name.substring(cuePoint.name.indexOf("_") + 1, cuePoint.name.length)) -1;
          showSlide(slideNumber);
        }
      }
    }

    private function showSlideByPosition(requestedPosition:Number):void {
      showSlide(findNearestSlide(requestedPosition));
    }

    private function changeSlideTo(index:Number):void {
      var time:Number = slides[index].time
      showSlide(index);
      EventBus.dispatch(new SlideEvent(SlideEvent.SLIDE_CHANGED, { slide: index, time: time }), EventBus.INPUT);
    }

    public function showSlide(index:Number):void {
      var sl:Loader = container.getChildByName("slide_" + currentSlide);
      if (sl) {
        container.removeChild(sl);
      }
      currentSlide = index;
      container.addChild(slide(index));
    }

    private function slide(index:Number):Loader {
      var sl:Loader = loader.getContent("slide_" + index).parent
      sl.name = "slide_" + index;
      return sl;
    }

    private function calculatedSeekPositionGivenPercentage(seekPercentage:Number):Number {
      return seekPercentage * duration;
    }

    public function setSize(newWidth:Number = 320, newHeight:Number = 240):void {
      this.width = newWidth;
      this.height = newHeight;
      resizeContainer(newWidth, newHeight);
    }

    private function resizeContainer(newWidth:Number, newHeight:Number):void {
      var sl:Loader = container.getChildByName("slide_" + currentSlide);
      if (sl) {
        if (sl.width > sl.height) {
          this.container.height = (sl.height) * newWidth / (sl.width);
          this.container.width = newWidth;

          if (measuredHeight < this.container.height) {
            this.container.width =  (sl.width) * newHeight / (sl.height);
            this.container.height = measuredHeight;
          }
        } else {
          this.container.width = (sl.width) * newHeight / (sl.height);
          this.container.height = newHeight;

          if (measuredWidth < this.container.width) {
            this.container.height = (sl.height) * newWidth / (sl.width);
            this.container.width = measuredWidth;
          }
        }
      }
    }

    override public function set width(value:Number):void
    {
      measuredWidth = value;
    }

    override public function get width():Number
    {
      return measuredWidth;
    }

    override public function set height(value:Number):void
    {
      measuredHeight = value;
    }

    override public function get height():Number
    {
      return measuredHeight;
    }

    private function resize():void {
      //this.container.width = 320;
      //this.container.height = 240;
    }

    private function setupBusListeners():void {
      EventBus.addListener(PlayerEvent.LOAD, onLoad);
      EventBus.addListener(PlayerEvent.SEEK, onSeek);
      EventBus.addListener(PlayerEvent.TOPICS_SEEK, onTopicsSeek);
      EventBus.addListener(PlayerEvent.DURATION_CHANGE, onDurationChange);

      EventBus.addListener(TimeEvent.CURRENT_TIME_CHANGE, onCurrentTimeChange);
      EventBus.addListener(TimelineMetadataEvent.MARKER_TIME_REACHED, onSlideCuePoint);

      EventBus.addListener(SlideEvent.FIRST_SLIDE, onFirstSlide, EventBus.INPUT);
      EventBus.addListener(SlideEvent.PREV_SLIDE, onPreviousSlide, EventBus.INPUT);
      EventBus.addListener(SlideEvent.NEXT_SLIDE, onNextSlide, EventBus.INPUT);
      EventBus.addListener(SlideEvent.LAST_SLIDE, onLastSlide, EventBus.INPUT);
      EventBus.addListener(SlideEvent.SLIDE_SYNC_CHANGED, onSlideSyncChanged, EventBus.INPUT);
    }
  }
}