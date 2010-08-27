package rioflashclient2.player {
  import caurina.transitions.Tweener;
  
  import rioflashclient2.configuration.Configuration;
  import rioflashclient2.event.EventBus;
  import rioflashclient2.event.LessonEvent;
  import rioflashclient2.event.PlayerEvent;
  import rioflashclient2.model.Lesson;
  
  import flash.events.Event;
  
  import org.osmf.events.LoadEvent;
  import org.osmf.events.TimeEvent;
  import org.osmf.layout.ScaleMode;
  import org.osmf.logging.Log;
  import org.osmf.logging.Logger;
  import org.osmf.media.MediaPlayerSprite;
  import org.osmf.media.URLResource;
  
  public class Player extends MediaPlayerSprite {
    private var logger:Logger = Log.getLogger('Player');
    
    public var lesson:Lesson;
    
    public function Player() {
      this.name = 'Player';
      
      if (!!stage) init();
      else addEventListener(Event.ADDED_TO_STAGE, init);
    }
    
    private function init(e:Event=null):void {
      setupMediaPlayer(); // TODO: This should not be here, maybe in a model???
      setupInterface();
      setupBusDispatchers();
      setupBusListeners();
      setupEventListeners();
      
      //hide();
    }
    
    public function load():void {
      logger.info('Loading video from url: ' + lesson.videoURL());
      
      this.resource = new URLResource(lesson.videoURL());
      resize();
    }
    
    public function play():void {
      logger.info('Playing...');
      
      if (isStopped()) {
        fadeIn();
      }
      
      this.mediaPlayer.play();
    }
    
    public function pause():void {
      if (this.mediaPlayer.playing) {
        logger.info('Paused...');
        this.mediaPlayer.pause();
      }
    }
    
    public function stop():void {
      if (!this.isStopped()) {
        logger.info('Stopping...');
        
        this.mediaPlayer.stop();
      }
      
      fadeOut();
    }
    
    private function onLessonLoaded(e:LessonEvent):void {
      lesson = e.lesson;
    }
    
    private function onReadyToPlay(e:PlayerEvent):void {
      load();
      play();
    }
    
    private function onPlay(e:PlayerEvent):void {
      if (hasVideoLoaded()) {
        play();
      }
    }
    
    private function onPause(e:PlayerEvent):void {
      pause();
    }
    
    private function onStop(e:PlayerEvent):void {
      stop();
    }
    
    private function onVolumeChange(e:PlayerEvent):void {
      logger.debug('Volume changed: ' + e.data);
      var volume:Number = e.data;
      this.mediaPlayer.volume = volume;
      this.mediaPlayer.muted = (volume == 0);
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
      stop();
    }
    
    private function onSeek(e:PlayerEvent):void {
      if (mediaPlayer.canSeek) {
        var seekPercentage:Number = (e.data as Number);
        var seekPosition:Number = calculatedSeekPositionGivenPercentage(seekPercentage);
        
        logger.debug('Seeking to position {0} in seconds, given percentual {1}.', seekPosition, seekPercentage);
        
        this.mediaPlayer.seek(seekPosition);
      }
    }
    
    private function calculatedSeekPositionGivenPercentage(seekPercentage:Number):Number {
      return seekPercentage * this.mediaPlayer.duration;
    }
    
    public function hasVideoLoaded():Boolean {
      return this.resource != null;
    }
    
    public function isStopped():Boolean {
      return !this.mediaPlayer.playing && !this.mediaPlayer.paused;
    }
    
    public function fadeIn():void {
      this.alpha = 0;
      Tweener.addTween(this, { time: 2, alpha: 1, onStart: show });
    }
    
    public function fadeOut():void {
      this.alpha = 1;
      Tweener.addTween(this, { time: 2, alpha: 0, onComplete: hide });
    }
    
    public function show():void {
      visible = true;
    }
    
    public function hide():void {
      visible = false;
    }
    
    private function setupMediaPlayer():void {
      this.mediaPlayer.autoPlay = Configuration.getInstance().autoPlay;
    }
    
    private function setupInterface():void {
      this.scaleMode = ScaleMode.LETTERBOX;
      
      resize();
    }
    
    private function resize(e:Event=null):void {
      if (stage != null) {
        this.width = stage.stageWidth;
        this.height = stage.stageHeight;
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
      EventBus.addListener(LessonEvent.LOADED, onLessonLoaded);
      
      EventBus.addListener(PlayerEvent.PLAY, onPlay);
      EventBus.addListener(PlayerEvent.PAUSE, onPause);
      EventBus.addListener(PlayerEvent.STOP, onStop);
      
      EventBus.addListener(PlayerEvent.READY_TO_PLAY, onReadyToPlay);
      
      EventBus.addListener(TimeEvent.COMPLETE, onVideoEnded);
      
      EventBus.addListener(PlayerEvent.VOLUME_CHANGE, onVolumeChange);
      EventBus.addListener(PlayerEvent.MUTE, onMute);
      EventBus.addListener(PlayerEvent.UNMUTE, onUnmute);
      
      EventBus.addListener(PlayerEvent.SEEK, onSeek);
    }
    
    private function setupEventListeners():void {
      stage.addEventListener(Event.RESIZE, resize);
    }
  }
}