package rioflashclient2.player {
  import caurina.transitions.Tweener;

  import flash.events.ErrorEvent;
  import flash.events.Event;

  import org.osmf.elements.VideoElement;
  import org.osmf.events.*;
  import org.osmf.events.LoadEvent;
  import org.osmf.events.TimeEvent;
  import org.osmf.events.TimelineMetadataEvent;
  import org.osmf.layout.ScaleMode;
  import org.osmf.logging.Log;
  import org.osmf.logging.Logger;
  import org.osmf.media.MediaElement;
  import org.osmf.media.MediaPlayerSprite;
  import org.osmf.media.URLResource;
  import org.osmf.metadata.CuePoint;
  import org.osmf.metadata.CuePointType;
  import org.osmf.metadata.TimelineMarker;
  import org.osmf.metadata.TimelineMetadata;
  import org.osmf.net.NetLoader;
  import org.osmf.traits.LoadTrait;
  import org.osmf.traits.MediaTraitType;
  import org.osmf.traits.TimeTrait;

  import rioflashclient2.configuration.Configuration;
  import rioflashclient2.event.EventBus;
  import rioflashclient2.event.PlayerEvent;
  import rioflashclient2.event.SlideEvent;
  import rioflashclient2.media.PlayerMediaFactory;
  import rioflashclient2.model.Lesson;
  import rioflashclient2.model.Slide;
  import rioflashclient2.model.Topics;
  import rioflashclient2.model.Video;
  import rioflashclient2.net.RioServerNetLoader;
  import rioflashclient2.net.pseudostreaming.DefaultSeekDataStore;

  public class Player extends MediaPlayerSprite {
    private var logger:Logger = Log.getLogger('Player');

    public var lesson:Lesson;
    public var video:Video;
    public var topics:Topics;
    private var slides:Array;
    private var seekDataStore:DefaultSeekDataStore;
    private var duration:Number = 0;
    private var durationCached:Boolean = false;
    private var slideSync:Boolean = true;

    private var playaheadTime:Number = 0;
    private var _downloadProgressPercentage:Number;
    private var bytesTotal:Number = 0;

    private var topicsTimelineMetadata:TimelineMetadata;
    private var slidesTimelineMetadata:TimelineMetadata;

    private var netLoader:NetLoader;

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
      this.topics = (lesson.topics as Topics);
      this.slides = lesson.slides;
      loadMedia();
      (this.media as VideoElement).client.addHandler("onMetaData", onMetadata);
    }

    public function loadMedia(seekPosition:Number=0):void {
      var url:String = Configuration.getInstance().resourceURL(this.video.file(), seekPosition);
      if (seekPosition == 0) {
        logger.info('Loading video from url: ' + url);
      } else {
        logger.info('Server seeking to: ' + url);
      }

      //this.resource = new URLResource(url);

      netLoader = new RioServerNetLoader();
      var videoElement:VideoElement = new VideoElement(null, netLoader);
      videoElement.resource = new URLResource(url);
      this.media = videoElement;

      topicsTimelineMetadata = new TimelineMetadata(videoElement);
      topicsTimelineMetadata.addEventListener(TimelineMetadataEvent.MARKER_TIME_REACHED, EventBus.dispatch, false, 0, true);
      addTopicsMetadata(this.topics);

      slidesTimelineMetadata = new TimelineMetadata(videoElement);
      slidesTimelineMetadata.addEventListener(TimelineMetadataEvent.MARKER_TIME_REACHED, EventBus.dispatch, false, 0, true);
      addSlidesMetadata(this.slides);

      if (durationCached) {
        (this.media as VideoElement).defaultDuration = duration;
        logger.info('Video duration restored from cached duration: ' + duration);
      }
    }

    public function addTopicsMetadata(topics:Topics):void {
      for each (var topicTime:Number in topics.topicTimes) {
        var cuePoint:CuePoint = new CuePoint(CuePointType.ACTIONSCRIPT, topicTime, "Topic", null);
        topicsTimelineMetadata.addMarker(cuePoint);
      }
    }

    public function addSlidesMetadata(slides:Array):void {
      for (var i:uint = 0; i < slides.length; i++) {
        var cuePoint:CuePoint = new CuePoint(CuePointType.ACTIONSCRIPT, slides[i].time, "Slide_" + (i + 1), null);
        slidesTimelineMetadata.addMarker(cuePoint);
      }
    }

    private function onCuePoint(event:TimelineMetadataEvent):void
    {
      var cuePoint:CuePoint = event.marker as CuePoint;
      var diff:Number = cuePoint.time - this.mediaPlayer.currentTime;
      logger.info("CuePoint type=" + cuePoint.name + " reached=" + cuePoint.time + ", currentTime:" + this.mediaPlayer.currentTime + ", diff="+diff);
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
      if (seekPercentage <= 0) {
        seekPercentage = 1 / duration;
      }
      var seekPosition:Number = calculatedSeekPositionGivenPercentage(seekPercentage);
      seekTo(seekPercentage, seekPosition);
    }

    private function onTopicsSeek(e:PlayerEvent):void {
      var seekPosition:Number = e.data;
      var seekPercentage:Number = seekPosition / duration;

      seekTo(seekPercentage, seekPosition);
    }

    private function onSlideSyncChanged(e:SlideEvent):void {
      slideSync = e.slide.sync;
    }

    private function onSlideChanged(e:SlideEvent):void {
      if (slideSync) {
        logger.info('Slide syncing to {0}', e.slide.time);
        var seekPosition:Number = e.slide.time;
        var seekPercentage:Number = seekPosition / duration;

        seekTo(seekPercentage, seekPosition);
      }
    }

    private function seekTo(seekPercentage:Number, seekPosition:Number):void {
      if (isInBuffer(seekPercentage)) {
        logger.info('Seeking to position {0} in seconds, given percentual {1}.', seekPosition, seekPercentage);
        this.mediaPlayer.seek(seekPosition);
      } else {
        logger.info('Server seek requested to position {0} in seconds, given percentual {1}.', seekPosition, seekPercentage);
        serverSeekTo(seekPosition);
      }
    }

    private function serverSeekTo(requestedSeekPosition:Number):void {
      if (seekDataStore.allowRandomSeek()) {
        var seekPosition:Number = seekDataStore.getNearestKeyFramePosition(requestedSeekPosition);
        logger.info('Server seeking to position {0} in seconds', seekDataStore.keyFrameTime());
        loadMedia(seekPosition);

        if (requestedSeekPosition == 1) {
          EventBus.dispatch(new PlayerEvent(PlayerEvent.PLAYAHEAD_TIME_CHANGED, 1));
        } else {
          EventBus.dispatch(new PlayerEvent(PlayerEvent.PLAYAHEAD_TIME_CHANGED, seekDataStore.keyFrameTime()));
        }

        play();
      } else {
        logger.info('ServerSeek not supported by media element');
      }
    }

    private function isInBuffer(seekPercentage:Number):Boolean {
      return isAfterPlayahead(seekPercentage) && seekPercentage <= downloadProgressPercentage;
    }

    private function isAfterPlayahead(seekPercentage:Number): Boolean {
      return (seekPercentage * duration) >= playaheadTime;
    }

    public function get downloadProgressPercentage():Number {
      return _downloadProgressPercentage;
    }

    public function set downloadProgressPercentage(percentage:Number):void {
      _downloadProgressPercentage = percentage;
    }

    private function onBytesLoadedChange(e:LoadEvent):void {
      updateDownloadProgress(e.bytes);
    }

    private function onBytesTotalChange(e:LoadEvent):void {
      bytesTotal = e.bytes;
    }

    private function updateDownloadProgress(bytesLoaded:Number):void {
      if (bytesTotal > 0) {
        downloadProgressPercentage = bytesLoaded / bytesTotal;
      } else {
        downloadProgressPercentage = 0;
      }
    }

    private function onPlayaheadTimeChanged(e:PlayerEvent):void {
      playaheadTime = e.data;
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
      EventBus.addListener(LoadEvent.BYTES_LOADED_CHANGE, onBytesLoadedChange);
      EventBus.addListener(LoadEvent.BYTES_TOTAL_CHANGE, onBytesTotalChange);

      EventBus.addListener(PlayerEvent.VOLUME_CHANGE, onVolumeChange);
      EventBus.addListener(PlayerEvent.MUTE, onMute);
      EventBus.addListener(PlayerEvent.UNMUTE, onUnmute);

      EventBus.addListener(PlayerEvent.SEEK, onSeek);
      EventBus.addListener(PlayerEvent.TOPICS_SEEK, onTopicsSeek);
      EventBus.addListener(PlayerEvent.PLAYAHEAD_TIME_CHANGED, onPlayaheadTimeChanged);

      EventBus.addListener(ErrorEvent.ERROR, onError);
      EventBus.addListener(TimelineMetadataEvent.MARKER_TIME_REACHED, onCuePoint);

      EventBus.addListener(SlideEvent.SLIDE_CHANGED, onSlideChanged, EventBus.INPUT);
      EventBus.addListener(SlideEvent.SLIDE_SYNC_CHANGED, onSlideSyncChanged, EventBus.INPUT);
    }
  }
}