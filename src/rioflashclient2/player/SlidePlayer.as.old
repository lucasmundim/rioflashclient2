package rioflashclient2.player {

  import caurina.transitions.Tweener;

  import flash.events.Event;

  import org.osmf.elements.DurationElement;
  import org.osmf.elements.SWFElement;
  import org.osmf.elements.SerialElement;
  import org.osmf.events.LoadEvent;
  import org.osmf.events.TimeEvent;
  import org.osmf.layout.ScaleMode;
  import org.osmf.logging.Log;
  import org.osmf.logging.Logger;
  import org.osmf.media.MediaPlayerSprite;
  import org.osmf.media.URLResource;
  import org.osmf.events.TimelineMetadataEvent;
  import org.osmf.metadata.CuePoint;
  import org.osmf.layout.LayoutMetadata;
  import org.osmf.layout.HorizontalAlign;
  import org.osmf.layout.VerticalAlign;

  import rioflashclient2.configuration.Configuration;
  import rioflashclient2.elements.PreloadingProxyElement;
  import rioflashclient2.event.EventBus;
  import rioflashclient2.event.PlayerEvent;
  import rioflashclient2.event.SlideEvent;
  import rioflashclient2.media.PlayerMediaFactory;
  import rioflashclient2.model.Lesson;
  import rioflashclient2.model.Slide;
  import rioflashclient2.model.Video;
  import rioflashclient2.net.RioServerSWFLoader;


  public class SlidePlayer extends MediaPlayerSprite {
    private var logger:Logger = Log.getLogger('SlidePlayer');

    private var lesson:Lesson;
    private var slides:Array;
    private var sync:Boolean = true;
    private var duration:Number = 0;
    private var videoPlayerCurrentTime:Number;

    public function SlidePlayer() {
      this.name = 'SlidePlayer';

      super(null, null, new PlayerMediaFactory());

      if (!!stage) init();
      else addEventListener(Event.ADDED_TO_STAGE, init);
    }

    private function init(e:Event=null):void {
      setupInterface();
      setupMediaPlayer();
      setupBusListeners();
    }

    public function load(lesson:Lesson):void {
      slides = lesson.slides;
      loadMedia();
    }

    public function loadMedia():void {
      var swfLoader:RioServerSWFLoader = new RioServerSWFLoader();
      var swfSequence:SerialElement = new SerialElement();
      var layoutData:LayoutMetadata = layoutMetadata(width, height);

      swfSequence.addChild(new DurationElement(slides[0].time));

      for ( var i:uint = 0; i< slides.length; i++) {
        var slide:Slide = slides[i];
        var slideURL:String = Configuration.getInstance().resourceURL(slide.relative_path);
        var swfElement:SWFElement = new SWFElement(new URLResource(slideURL), swfLoader);
        swfElement.metadata.addValue(LayoutMetadata.LAYOUT_NAMESPACE, layoutData);

        var slideDuration:Number;
        if (i < (slides.length - 1)) {
          slideDuration = slides[i+1].time - slide.time;
        } else {
          slideDuration = duration - slide.time;
        }

        var durationElement:DurationElement = new DurationElement(slideDuration, swfElement);
        var preloadElement:PreloadingProxyElement = new PreloadingProxyElement( durationElement );
        swfSequence.addChild(preloadElement);
        logger.info('Loading: ' + slideURL + ' with ' + slideDuration + 's');
      }

      swfSequence.metadata.addValue(LayoutMetadata.LAYOUT_NAMESPACE, layoutData);
      this.media = swfSequence;
    }

    public function setSize(newWidth:Number = 320, newHeight:Number = 240):void {
      this.width = newWidth;
      this.height = newHeight;
      this.mediaContainer.width = newWidth;
      this.mediaContainer.height = newHeight;

      if (this.media != null) {
        var layoutData:LayoutMetadata = layoutMetadata(newWidth, newHeight);
        for ( var i:uint = 0; i< (this.media as SerialElement).numChildren; i++) {
          (this.media as SerialElement).getChildAt(i).metadata.addValue(LayoutMetadata.LAYOUT_NAMESPACE, layoutData);
        }
        this.media.metadata.addValue(LayoutMetadata.LAYOUT_NAMESPACE, layoutData);
      }
    }

    private function layoutMetadata(newWidth:Number, newHeight:Number):LayoutMetadata {
      var layoutData:LayoutMetadata = new LayoutMetadata();
      layoutData.scaleMode = ScaleMode.LETTERBOX;
      layoutData.horizontalAlign = HorizontalAlign.LEFT;
      layoutData.verticalAlign = VerticalAlign.TOP;
      layoutData.width = newWidth;
      layoutData.height = newHeight;
      return layoutData;
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
      seekTo(time);
      EventBus.dispatch(new SlideEvent(SlideEvent.SLIDE_CHANGED, { slide: index, time: time }), EventBus.INPUT);
    }

    private function currentSlide():Number {
      return findNearestSlide(this.mediaPlayer.currentTime)
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

    private function onLoad(e:PlayerEvent):void {
      lesson = e.data.lesson;
      duration = lesson.duration;
      load(e.data.lesson);
      play();
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
          seekTo(cuePoint.time);
        }
      }
    }

    private function seekTo(requestedSeekPosition:Number):void {
      this.mediaPlayer.seek(requestedSeekPosition - 1); // Workaround for serial element blank screen seek problem
      this.mediaPlayer.seek(requestedSeekPosition);
      play();
    }

    private function calculatedSeekPositionGivenPercentage(seekPercentage:Number):Number {
      return seekPercentage * duration;
    }

    private function setupInterface():void {
      this.scaleMode = ScaleMode.LETTERBOX;
      resize();
    }

    private function setupMediaPlayer():void {
      this.mediaPlayer.autoPlay = Configuration.getInstance().autoPlay;
    }

    private function resize(e:Event=null):void {
      if (stage != null) {
        this.width = stage.width;
        this.height = stage.height;
      }
    }

    private function setupBusListeners():void {
      EventBus.addListener(PlayerEvent.LOAD, onLoad);
      EventBus.addListener(PlayerEvent.SEEK, onSeek);
      EventBus.addListener(PlayerEvent.TOPICS_SEEK, onTopicsSeek);
      EventBus.addListener(PlayerEvent.DURATION_CHANGE, onDurationChange);
      EventBus.addListener(PlayerEvent.PLAY, onPlay);
      EventBus.addListener(PlayerEvent.PAUSE, onPause);
      EventBus.addListener(PlayerEvent.STOP, onStop);
      EventBus.addListener(PlayerEvent.PLAYAHEAD_TIME_CHANGED, onServerSeek);

      EventBus.addListener(TimeEvent.CURRENT_TIME_CHANGE, onCurrentTimeChange);
      EventBus.addListener(TimelineMetadataEvent.MARKER_TIME_REACHED, onSlideCuePoint);

      EventBus.addListener(SlideEvent.FIRST_SLIDE, onFirstSlide, EventBus.INPUT);
      EventBus.addListener(SlideEvent.PREV_SLIDE, onPreviousSlide, EventBus.INPUT);
      EventBus.addListener(SlideEvent.NEXT_SLIDE, onNextSlide, EventBus.INPUT);
      EventBus.addListener(SlideEvent.LAST_SLIDE, onLastSlide, EventBus.INPUT);
      EventBus.addListener(SlideEvent.SLIDE_SYNC_CHANGED, onSlideSyncChanged, EventBus.INPUT);
    }

    public function play():void {
      logger.info('SlidePlayer Playing...');
      this.mediaPlayer.play();
    }

    public function fadeIn():void {
      Tweener.addTween(this, { time: 2, alpha: 1, onStart: show });
    }

    public function fadeOut():void {
      Tweener.addTween(this, { time: 2, alpha: 0, onComplete: hide });
    }

    public function pause():void {
      logger.info('Paused...');
      this.mediaPlayer.pause();
    }

    public function show():void {
      visible = true;
    }

    public function hide():void {
      visible = false;
      alpha = 0;
    }

    public function stop():void {
      logger.info('Stopping...');
      this.mediaPlayer.stop();
      fadeOut();
    }

    private function onPlay(e:PlayerEvent):void {
      play();
    }

    private function onPause(e:PlayerEvent):void {
      pause();
    }

    private function onStop(e:PlayerEvent):void {
      stop();
    }
  }
}