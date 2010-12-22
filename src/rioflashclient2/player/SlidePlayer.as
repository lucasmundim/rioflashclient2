package rioflashclient2.player {
  import br.com.stimuli.loading.BulkLoader;
  import br.com.stimuli.loading.BulkProgressEvent;

  import caurina.transitions.Tweener;

  import flash.events.Event;
  import flash.display.MovieClip;

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

    private var lesson:Lesson;
    private var slides:Array;
    private var sync:Boolean = true;
    private var duration:Number = 0;
    private var videoPlayerCurrentTime:Number;
    public var loader:BulkLoader;
    private var firstLoaded:Boolean = false;

    public function SlidePlayer() {
      this.name = 'SlidePlayer';
      if (!!stage) init();
      else addEventListener(Event.ADDED_TO_STAGE, init);
    }

    private function init(e:Event=null):void {
      setupInterface();
      setupBusListeners();
    }

    private function onLoad(e:PlayerEvent):void {
      lesson = e.data.lesson;
      duration = lesson.duration;
      load(e.data.lesson);
    }

    public function load(lesson:Lesson):void {
      slides = lesson.slides;
      loadMedia();
    }

    public function loadMedia():void {
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

    public function showSlide(num:Number):void {
      addChild(loader.getContent("slide_" + num).parent);
    }

    public function onSingleItemLoaded(e:Event):void {
      trace("carregou");
    }

    public function onFirstItemLoaded(e:Event):void {
      trace("carregou o primeiro");
      showSlide(0);
    }

    public function onAllItemsLoaded(e:Event) : void {
      trace("foi tudo");
    }

    public function onAllProgress(e:BulkProgressEvent) : void {
      trace("Loaded" , e.itemsLoaded," of ",  e.itemsTotal);
    }

    public function setSize(newWidth:Number = 320, newHeight:Number = 240):void {
      /*this.width = newWidth;
            this.height = newHeight;*/
    }

    private function onFirstSlide(e:SlideEvent):void {
      slideSeekTo(0)
    }

    private function onLastSlide(e:SlideEvent):void {
      slideSeekTo(slides.length - 1);
    }

    private function onPreviousSlide(e:SlideEvent):void {
      var current:Number = currentSlide();
      if (current > 0) {
        current--;
      }
      slideSeekTo(current)
    }

    private function onNextSlide(e:SlideEvent):void {
      var current:Number = currentSlide();
      if (current < (slides.length - 1)) {
        current++;
      }
      slideSeekTo(current);
    }

    private function slideSeekTo(index:Number):void {
      var time:Number = slides[index].time
      //seekTo(time);
      EventBus.dispatch(new SlideEvent(SlideEvent.SLIDE_CHANGED, { slide: index, time: time }), EventBus.INPUT);
    }

    private function currentSlide():Number {
      //return findNearestSlide(this.mediaPlayer.currentTime)
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
        seekTo(time);
      } else {
        pause();
      }
    }

    private function onSeek(e:PlayerEvent):void {
      var seekPercentage:Number = (e.data as Number);
      if (seekPercentage <= 0) {
        seekPercentage = 1 / duration;
      }
      var seekPosition:Number = calculatedSeekPositionGivenPercentage(seekPercentage);
      logger.info('Slide Seeking to position {0} in seconds, given percentual {1}.', seekPosition, seekPercentage);
      seekTo(seekPosition);
    }

    private function onServerSeek(e:PlayerEvent):void {
      if (sync) {
        var seekPosition:Number = (e.data as Number);
        logger.info('Slide Seeking to position {0} in seconds.', seekPosition);
        seekTo(seekPosition);
      }
    }

    private function onTopicsSeek(e:PlayerEvent):void {
      if (sync) {
        var seekPosition:Number = e.data;
        logger.info('Slide Seeking to position {0} in seconds.', seekPosition);
        seekTo(seekPosition);
      }
    }

    private function onSlideCuePoint(event:TimelineMetadataEvent):void {
      if (sync) {
        var cuePoint:CuePoint = event.marker as CuePoint;
        if (cuePoint.name.indexOf("Slide") != -1) {
          var slideNumber:Number = Number(cuePoint.name.substring(cuePoint.name.indexOf("_") + 1, cuePoint.name.length)) -1;
          seekTo(slideNumber);
        }
      }
    }

    private function seekTo(requestedSeekPosition:Number):void {
      showSlide(requestedSeekPosition);
    }

    private function calculatedSeekPositionGivenPercentage(seekPercentage:Number):Number {
      return seekPercentage * duration;
    }

    private function setupInterface():void {
      resize();
    }

    private function resize(e:Event=null):void {

    }

    private function setupBusListeners():void {
      EventBus.addListener(PlayerEvent.LOAD, onLoad);
      EventBus.addListener(PlayerEvent.SEEK, onSeek);
      EventBus.addListener(PlayerEvent.TOPICS_SEEK, onTopicsSeek);
      EventBus.addListener(PlayerEvent.DURATION_CHANGE, onDurationChange);
      EventBus.addListener(PlayerEvent.PLAYAHEAD_TIME_CHANGED, onServerSeek);

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