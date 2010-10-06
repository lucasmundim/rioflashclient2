package rioflashclient2.player {
  import caurina.transitions.Tweener;

  import flash.events.ErrorEvent;
  import flash.events.Event;

  import org.osmf.elements.VideoElement;
  import org.osmf.events.LoadEvent;
  import org.osmf.events.TimeEvent;
  import org.osmf.layout.ScaleMode;
  import org.osmf.logging.Log;
  import org.osmf.logging.Logger;
  import org.osmf.media.MediaPlayerSprite;
  import org.osmf.media.URLResource;

  import rioflashclient2.configuration.Configuration;
  import rioflashclient2.event.EventBus;
  import rioflashclient2.event.PlayerEvent;
  import rioflashclient2.media.PlayerMediaFactory;
  import rioflashclient2.model.Lesson;
  import rioflashclient2.model.Video;
  import rioflashclient2.net.pseudostreaming.DefaultSeekDataStore;

  public class Player extends MediaPlayerSprite {
    private var logger:Logger = Log.getLogger('Player');

    public var lesson:Lesson;
    public var video:Video;
    private var seekDataStore:DefaultSeekDataStore;
    private var originalVideoURL:String;
    private var duration:Number = 0;
    private var durationCached:Boolean = false;

    public function Player() {
      this.name = 'Player';
      super(null, null, new PlayerMediaFactory());

      if (!!stage) init();
      else addEventListener(Event.ADDED_TO_STAGE, init);
    }

    private function init(e:Event=null):void {
      setupMediaPlayer();
      setupInterface();
      setupBusDispatchers();
      setupBusListeners();
    }

    public function load(lesson:Lesson):void {
      this.video = (lesson.video() as Video);
      loadMedia(this.video.url());
      (this.media as VideoElement).client.addHandler("onMetaData", onMetadata);
      //resize();
    }

    public function loadMedia(url:String=""):void {
      if (!originalVideoURL) {
        originalVideoURL = url;
        logger.info('Loading video from url: ' + url);
      } else {
        logger.info('Server seeking to: ' + url);
      }

      this.resource = new URLResource(url);

      if (durationCached) {
        (this.media as VideoElement).defaultDuration = duration;
        logger.info('Video duration restored from cached duration: ' + duration);
      }
    }

    public function onMetadata(info:Object):void
    {
      logger.info('Loading video metadata...');
      seekDataStore = DefaultSeekDataStore.create(info);
      seekDataStore.reset();
      EventBus.dispatch(new PlayerEvent(PlayerEvent.NEED_TO_KEEP_PLAYAHEAD_TIME, seekDataStore.needToKeepPlayAheadTime()));
    }

    public function play():void {
      logger.info('Playing...');

      fadeIn();
      this.mediaPlayer.play();
    }

    public function pause():void {
      logger.info('Paused...');

      this.mediaPlayer.pause();
    }

    public function stop():void {
      logger.info('Stopping...');

      this.mediaPlayer.stop();
      fadeOut();
    }

    private function onLoad(e:PlayerEvent):void {
      load(e.data.lesson);
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

    private function onVolumeChange(e:PlayerEvent):void {
      logger.debug('Volume changed: ' + e.data);
      this.mediaPlayer.volume = e.data;
    }

    private function onMute(e:PlayerEvent):void {
      logger.debug('Volume muted.');
      this.mediaPlayer.muted = true;
    }

    private function onUnmute(e:PlayerEvent):void {
      logger.debug('Volume unmuted.');
      this.mediaPlayer.muted = false;
    }

    private function onVideoEnded(e:TimeEvent):void {
      logger.debug('Video ended.');

      EventBus.dispatch(new PlayerEvent(PlayerEvent.ENDED, { video: video }));
      stop();
    }

    private function onSeek(e:PlayerEvent):void {
      var seekPercentage:Number = (e.data as Number);
      var seekPosition:Number = calculatedSeekPositionGivenPercentage(seekPercentage);

      logger.info('Seeking to position {0} in seconds, given percentual {1}.', seekPosition, seekPercentage);

      this.mediaPlayer.seek(seekPosition);
    }

    private function onServerSeek(e:PlayerEvent):void {
      var seekPercentage:Number = (e.data as Number);
      var requestedSeekPosition:Number = calculatedSeekPositionGivenPercentage(seekPercentage)
      logger.info('Server seek requested to position {0} in seconds, given percentual {1}.', requestedSeekPosition, seekPercentage);
      serverSeekTo(requestedSeekPosition);
    }

    private function onTopicsSeek(e:PlayerEvent):void {
      var requestedSeekPosition:Number = e.data;
      logger.info('Server seek requested to position {0} in seconds.', requestedSeekPosition);
      serverSeekTo(requestedSeekPosition);
    }

    private function serverSeekTo(requestedSeekPosition:Number):void {
      if (seekDataStore.allowRandomSeek()) {
        var seekPosition:Number = seekDataStore.getNearestKeyFramePosition(requestedSeekPosition)
        logger.info('Server seeking to position {0} in seconds', seekDataStore.keyFrameTime());

        loadMedia(appendQueryString(originalVideoURL, seekPosition));
        EventBus.dispatch(new PlayerEvent(PlayerEvent.PLAYAHEAD_TIME_CHANGED, seekDataStore.keyFrameTime()));
        play();
      } else {
        logger.info('ServerSeek not supported by media element');
      }
    }

    private function onDurationChange(e:TimeEvent):void {
      if (e.time && e.time != 0 && !durationCached) {
        cacheDuration(e.time);
      }

      if (durationCached) {
        loadDurationFromCache();
      }
    }

    private function cacheDuration(_duration:Number):void {
      duration = _duration;
      durationCached = true;
      logger.info('Video duration cached');
      EventBus.dispatch(new PlayerEvent(PlayerEvent.DURATION_CHANGE, duration));
    }

    private function loadDurationFromCache():void {
      (this.media as VideoElement).defaultDuration = duration;
    }

    private function onError(e:ErrorEvent):void {
      fadeOut();
    }

    private function calculatedSeekPositionGivenPercentage(seekPercentage:Number):Number {
      return seekPercentage * duration;
    }

    public function hasVideoLoaded():Boolean {
      return this.media != null;
    }

    public function fadeIn():void {
      Tweener.addTween(this, { time: 2, alpha: 1, onStart: show });
    }

    public function fadeOut():void {
      Tweener.addTween(this, { time: 2, alpha: 0, onComplete: hide });
    }

    public function show():void {
      visible = true;
    }

    public function hide():void {
      visible = false;
      alpha = 0;
    }

    private function setupMediaPlayer():void {
      this.mediaPlayer.autoPlay = Configuration.getInstance().autoPlay;
    }

    private function setupInterface():void {
      this.scaleMode = ScaleMode.LETTERBOX;
      resize();
    }

    public function resize(newWidth:Number = 320, newHeight:Number = 240):void {
      if (stage != null) {
        this.width = newWidth;
        this.height = newHeight;
      }
    }

    public function setSize(newWidth:Number = 320, newHeight:Number = 240):void{
      this.width = newWidth;
      this.height = newHeight;
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

      EventBus.addListener(ErrorEvent.ERROR, onError);
    }

    private function setupEventListeners():void {
      //stage.addEventListener(Event.RESIZE, resize);
    }


    private function appendQueryString(url:String, start:Number):String {
      logger.debug("Seek requested to: " + start);
      if (start == 0) return url;
      return url + (url.indexOf("?") >= 0 ? "&" : "?") + "start=${start}".replace("${start}", start);
    }
  }
}