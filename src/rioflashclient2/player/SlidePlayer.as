package rioflashclient2.player {
  import br.com.stimuli.loading.BulkLoader;
  import br.com.stimuli.loading.BulkProgressEvent;

  import caurina.transitions.Tweener;

  import flash.events.Event;
  import flash.display.MovieClip;
  import flash.display.Loader;
  import flash.geom.Rectangle;
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
    private var currentSlideIndex:Number;
    private var container:MovieClip;
    private var sync:Boolean = true;
    private var duration:Number = 0;
    private var videoPlayerCurrentTime:Number;
    private var requestedIndex:Number;
    private var loading:Boolean = false;
    private var dataLoaded:Boolean = false;

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
    }

    private function onLoad(e:PlayerEvent):void {
      trace("loading slides");
      lesson = e.data.lesson;
      slides = lesson.slides;
      duration = lesson.duration;
      dataLoaded = true;
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
      if(slides.length > 1)loader.get("slide_1").addEventListener(Event.COMPLETE, onSecondItemLoaded);
      loader.addEventListener(BulkLoader.COMPLETE, onAllItemsLoaded);
      loader.addEventListener(BulkLoader.PROGRESS, onAllProgress);

      trace("starting loading slides");
      loader.start(1);
    }

    public function onSingleItemLoaded(e:Event):void {
      trace(e.target.id);
      trace("1 more slide loaded");
    }

    public function onFirstItemLoaded(e:Event):void {
      trace("first slide loaded");
      addToContainer(0, true);
      if(slides.length == 1) lesson.video().play();
    }

    public function onSecondItemLoaded(e:Event):void {
      trace("second slide loaded, starting to play");
      lesson.video().play();
    }

    public function onAllItemsLoaded(e:BulkProgressEvent) : void {
      trace("all slides loaded");
    }

    public function onAllProgress(e:BulkProgressEvent) : void {
      //trace(e.loadingStatus());
    }

    private function onFirstSlide(e:SlideEvent):void {
      if (dataLoaded) {
        showSlide(0)
      }
    }

    private function onLastSlide(e:SlideEvent):void {
      if (dataLoaded) {
        showSlide(slides.length - 1);
      }
    }

    private function onPreviousSlide(e:SlideEvent):void {
      if (dataLoaded) {
        if (currentSlideIndex > 0) {
          showSlide(currentSlideIndex - 1);
        }
      }
    }

    private function onNextSlide(e:SlideEvent):void {
      if (dataLoaded) {
        if (currentSlideIndex < (slides.length - 1)) {
          showSlide(currentSlideIndex + 1);
        }
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
        trace("slide cuepoint")
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

    private function currentSlide():Loader {
      return container.getChildByName("slide_" + currentSlideIndex) as Loader;
    }

    public function showSlide(index:Number):void {
      trace("START show slide");
      if (currentSlideIndex != index && !loading) {
        trace("will load slide");

        clearContainer();

        if (slideLoader(index)) {
          trace("already loaded");

          addToContainer(index);
        } else {
          trace("not loaded, loading");

          if (sync) {
            EventBus.dispatch(new PlayerEvent(PlayerEvent.PAUSE));
          }

          requestedIndex = index;
          repriorizeByIndex(requestedIndex);
          loading = true;
          loader.get("slide_" + index).addEventListener(Event.COMPLETE, onRequestedSlideLoaded);
        }
      }
      trace("END show slide")
    }

    private function repriorizeByIndex(index:Number):void {
      loader.pauseAll();
      for ( var i:uint = index; i< slides.length; i++) {
        loader.changeItemPriority("slide_" + i, (slides.length - i + index));
      }
      for ( var j:uint = 0; j< index; j++) {
        loader.changeItemPriority("slide_" + j, (slides.length - j - index));
      }
      loader.resumeAll();
    }

    private function addToContainer(index:Number, ignoreEvent:Boolean = false):void {
      trace("START add to container");
      clearContainer();
      currentSlideIndex = index;
      container.addChild(slideLoader(index));
      resizeContainer();
      if (!ignoreEvent) {
        dispatchSlideChanged(index);
      }
      trace("END add to container");
    }

    private function dispatchSlideChanged(index:Number):void {
      trace("dispatching slide changed")
      var time:Number = slides[index].time;
      EventBus.dispatch(new SlideEvent(SlideEvent.SLIDE_CHANGED, { slide: index, time: time }), EventBus.INPUT);
    }

    private function onRequestedSlideLoaded(e:Event):void {
      trace("START requested slide loaded")
      loading = false;
      addToContainer(requestedIndex);
      if (sync) {
        EventBus.dispatch(new PlayerEvent(PlayerEvent.PLAY));
      }
      trace("END requested slide loaded")
    }

    private function clearContainer():void {
      trace("START clear container");
      var slide:Loader = currentSlide();
      if (slide) {
        container.removeChild(slide);
      }
      trace("END clear container");
    }

    private function slideLoader(index:Number):Loader {
      var name:String = "slide_" + index;

      if (loader.getContent(name) == null) {
        return null;
      }

      var slide:Loader = loader.getContent(name).parent
      slide.name = name;
      return slide;
    }

    private function calculatedSeekPositionGivenPercentage(seekPercentage:Number):Number {
      return seekPercentage * duration;
    }

    public function setSize(newWidth:Number, newHeight:Number):void {
      this.width = newWidth;
      this.height = newHeight;
      resizeContainer();
    }

    private function resizeContainer():void {
      trace("START resize container");
      var slide:Loader = currentSlide();
      if (slide) {
        if (slide.width > slide.height) {
          this.container.height = (slide.height) * this.width / (slide.width);
          this.container.width = this.width;

          if (measuredHeight < this.container.height) {
            this.container.width =  (slide.width) * this.height / (slide.height);
            this.container.height = this.height;
          }
        } else {
          this.container.width = (slide.width) * this.height / (slide.height);
          this.container.height = this.height;

          if (measuredWidth < this.container.width) {
            this.container.height = (slide.height) * this.width / (slide.width);
            this.container.width = this.width;
          }
        }
      }
      this.scrollRect = new Rectangle(this.container.x,this.container.y, this.container.width, this.container.height);
      trace("END resize container");
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