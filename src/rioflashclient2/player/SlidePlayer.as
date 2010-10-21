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
  
  import rioflashclient2.configuration.Configuration;
  import rioflashclient2.elements.PreloadingProxyElement;
  import rioflashclient2.event.EventBus;
  import rioflashclient2.event.PlayerEvent;
  import rioflashclient2.media.PlayerMediaFactory;
  import rioflashclient2.model.Lesson;
  import rioflashclient2.model.Slide;
  import rioflashclient2.model.Video;
  import rioflashclient2.net.RioServerSWFLoader;

  public class SlidePlayer extends MediaPlayerSprite {
    private var logger:Logger = Log.getLogger('SlidePlayer');
    private var duration:Number = 0;
    private var lesson:Lesson;
    public function SlidePlayer() {
      this.name = 'SlidePlayer';

      super(null, null, new PlayerMediaFactory());

      if (!!stage) init();
      else addEventListener(Event.ADDED_TO_STAGE, init);
    }

    private function init(e:Event=null):void {
      setupInterface();
      setupMediaPlayer();
      setupBusDispatchers();
      setupBusListeners();
    }

    public function load(lesson:Lesson):void {
      loadMedia(lesson.slides);
    }

    public function loadMedia(slides:Array):void {
		var swfLoader:RioServerSWFLoader = new RioServerSWFLoader();
		var swfSequence:SerialElement = new SerialElement();
		swfSequence.addChild(new DurationElement(slides[0].time));
		for( var i:uint = 0; i< slides.length; i++){
			var slide:Slide = slides[i];
			var slideURL:String = Configuration.getInstance().resourceURL(slide.relative_path);
			var swfElement:SWFElement = new SWFElement(new URLResource(slideURL), swfLoader);
			var slideDuration:Number = duration-slide.time;
      		if( i > 0 && i < slides.length - 1  ){
      		  trace(i, "if ", slides.length-1)
        		slideDuration = slides[i+1].time-slide.time;
      		}
			var durationElement:DurationElement = new DurationElement(slideDuration, swfElement);
			var preloadElement:PreloadingProxyElement = new PreloadingProxyElement( durationElement );
			
			swfSequence.addChild(durationElement);
			logger.info('Loading from url: ' + slideURL );
		}
		this.media = swfSequence;
		this.mediaPlayer.play();
    }

    private function onLoad(e:PlayerEvent):void {
	  lesson = e.data.lesson;
      duration = lesson.duration;
	  load(e.data.lesson);

    }

	
    private function onDurationChange(e:PlayerEvent):void {
      duration = e.data;
    }

    private function onSeek(e:PlayerEvent):void {
      var seekPercentage:Number = (e.data as Number);
      var seekPosition:Number = calculatedSeekPositionGivenPercentage(seekPercentage);

      logger.info('Slide Seeking to position {0} in seconds, given percentual {1}.', seekPosition, seekPercentage);

      this.mediaPlayer.seek(seekPosition);
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

    private function setupBusDispatchers():void {
      
    }

    private function setupBusListeners():void {
      EventBus.addListener(PlayerEvent.LOAD, onLoad);
      EventBus.addListener(PlayerEvent.SEEK, onSeek);
      EventBus.addListener(PlayerEvent.SERVER_SEEK, onSeek);
      EventBus.addListener(PlayerEvent.TOPICS_SEEK, onSeek);
      EventBus.addListener(PlayerEvent.DURATION_CHANGE, onDurationChange);
	  EventBus.addListener(PlayerEvent.PLAY, onPlay);
      EventBus.addListener(PlayerEvent.PAUSE, onPause);
      EventBus.addListener(PlayerEvent.STOP, onStop);
    }
    public function play():void {
      logger.info('SlidePlayer Playing...');

      fadeIn();
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