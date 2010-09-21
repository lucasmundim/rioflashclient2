package rioflashclient2.player {

  import flash.events.Event;

  import org.osmf.events.LoadEvent;
  import org.osmf.events.TimeEvent;
  import org.osmf.logging.Log;
  import org.osmf.logging.Logger;
  import org.osmf.layout.ScaleMode;
  import org.osmf.media.MediaPlayerSprite;
  import org.osmf.media.URLResource;
  import org.osmf.elements.SWFElement;

  import rioflashclient2.configuration.Configuration;
  import rioflashclient2.event.EventBus;
  import rioflashclient2.event.PlayerEvent;
  import rioflashclient2.media.PlayerMediaFactory;
  import rioflashclient2.model.Video;

  import rioflashclient2.net.RioServerSWFLoader;
  import org.osmf.elements.DurationElement;
  import org.osmf.elements.SerialElement;
  import rioflashclient2.elements.PreloadingProxyElement;

  public class SlidePlayer extends MediaPlayerSprite {
    private var logger:Logger = Log.getLogger('SlidePlayer');

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
      setupEventListeners();
    }

    public function load(video:Video):void {
      loadMedia(video.url());
    }

    public function loadMedia(url:String=""):void {
      url = "http://roxo.no-ip.com:3001/redirect.rio?file=/ufrj/palestras/hucff/palestra_nelson-001.swf";
      //url = "http://roxo.no-ip.com:3001/redirect.rio?file=/ufrj/palestras/hucff/ten.swf";
      //url = "http://mediapm.edgesuite.net/osmf/content/test/ten.swf";
      //url = "http://vegas.local:3010/ten.swf";

      logger.info('Loading from url: ' + url);
      //this.resource = new URLResource(url);

      // Serial Element test
      var swfLoader:RioServerSWFLoader = new RioServerSWFLoader();

      var swfElement1:SWFElement = new SWFElement(null, swfLoader);
      swfElement1.resource = new URLResource(url);
      url = "http://roxo.no-ip.com:3001/redirect.rio?file=/ufrj/palestras/hucff/palestra_nelson-002.swf";
      var swfElement2:SWFElement = new SWFElement(null, swfLoader);
      swfElement2.resource = new URLResource(url);

      var swfSequence:SerialElement = new SerialElement();
      swfSequence.addChild(new PreloadingProxyElement(new DurationElement(10, swfElement1)));
      swfSequence.addChild(new PreloadingProxyElement(new DurationElement(10, swfElement2)));

      this.media = swfSequence;
    }

    private function onLoad(e:PlayerEvent):void {
      load(e.data.video);
    }

    private function onSeek(e:PlayerEvent):void {
      //var seekPercentage:Number = (e.data as Number);
      //var seekPosition:Number = calculatedSeekPositionGivenPercentage(seekPercentage);

      //logger.info('Seeking to position {0} in seconds, given percentual {1}.', seekPosition, seekPercentage);

      //this.mediaPlayer.seek(seekPosition);
    }

    private function calculatedSeekPositionGivenPercentage(seekPercentage:Number):Number {
      return seekPercentage * this.mediaPlayer.duration;
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
      this.mediaPlayer.addEventListener(TimeEvent.COMPLETE, EventBus.dispatch);
      this.mediaPlayer.addEventListener(TimeEvent.CURRENT_TIME_CHANGE, EventBus.dispatch);
      this.mediaPlayer.addEventListener(TimeEvent.DURATION_CHANGE, EventBus.dispatch);

      this.mediaPlayer.addEventListener(LoadEvent.BYTES_LOADED_CHANGE, EventBus.dispatch);
      this.mediaPlayer.addEventListener(LoadEvent.BYTES_TOTAL_CHANGE, EventBus.dispatch);
    }

    private function setupBusListeners():void {
      EventBus.addListener(PlayerEvent.LOAD, onLoad);
      EventBus.addListener(PlayerEvent.SEEK, onSeek);
      /*
      EventBus.addListener(PlayerEvent.PLAY, onPlay);
      EventBus.addListener(PlayerEvent.PAUSE, onPause);
      EventBus.addListener(PlayerEvent.STOP, onStop);

      EventBus.addListener(TimeEvent.COMPLETE, onVideoEnded);
      EventBus.addListener(TimeEvent.DURATION_CHANGE, onDurationChange);

      EventBus.addListener(PlayerEvent.VOLUME_CHANGE, onVolumeChange);
      EventBus.addListener(PlayerEvent.MUTE, onMute);
      EventBus.addListener(PlayerEvent.UNMUTE, onUnmute);

      EventBus.addListener(PlayerEvent.SEEK, onSeek);
      EventBus.addListener(PlayerEvent.SERVER_SEEK, onServerSeek);
      EventBus.addListener(PlayerEvent.TOPICS_SEEK, onTopicsSeek);

      EventBus.addListener(ErrorEvent.ERROR, onError);*/
    }

    private function setupEventListeners():void {
      //stage.addEventListener(Event.RESIZE, resize);
    }
  }
}