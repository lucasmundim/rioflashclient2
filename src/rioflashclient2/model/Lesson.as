package rioflashclient2.model {
  import rioflashclient2.event.EventBus;
  import rioflashclient2.event.PlayerEvent;
  import rioflashclient2.configuration.Configuration;

  import flash.events.Event;

  import org.osmf.events.TimeEvent;

  import br.com.stimuli.loading.BulkLoader;
  import br.com.stimuli.loading.BulkProgressEvent;

  public class Lesson {
    public var loader:BulkLoader;
    
    public var filename:String;
    public var filesize:String;
    public var title:String;
    public var type:String;
    public var professor:String;
    public var course:String;
    public var coursecode:String;
    public var grad_program:String;
    public var source:String;
    public var bitrate:String;
    public var duration:String;
    public var resolution_x:String;
    public var resolution_y:String;
    public var index:String;
    public var sync:String;
    private var _video:Video;
    private var slides:Array = new Array();
    private var topics:Array = new Array();
    
    public function Lesson() {
      // do nothing
    }
    
    public function valid():Boolean {
      return hasVideo() && videoValid() && allSlidesValid() && allTopicsValid();
    }

    public function videoValid():Boolean {
      return _video.valid();
    }

    public function video():Video {
      return _video;
    }

    public function hasVideo():Boolean {
      return video != null;
    }
    
    public function allSlidesValid():Boolean {
      return slides.every(function(slide:Slide, index:int, array:Array):Boolean {
        return slide.valid();
      });
    }

    public function allTopicsValid():Boolean {
      return topics.every(function(topic:Topic, index:int, array:Array):Boolean {
        return topic.valid();
      });
    }
    
    public function parse(xml:XML):void {
      filename = xml.obj_filename;
      filesize = xml.obj_filesize;
      title = xml.obj_title;
      type = xml.obj_type;
      professor = xml.professor;
      course = xml.course
      coursecode = xml.coursecode
      grad_program = xml.grad_program
      source = xml.source
      bitrate = xml.bitrate
      duration = xml.duration
      resolution_x = xml.resolution.r_x
      resolution_y = xml.resolution.r_y
      index = xml.related_media.rm_item.(rm_type == 'index').rm_filename;
      sync = xml.related_media.rm_item.(rm_type == 'sync').rm_filename;
      _video = new Video(resourceURL(xml.related_media.rm_item.(rm_type == 'video').rm_filename));

      setupInputBusListeners();
    }

    private function onInputPlay(e:PlayerEvent):void {
      video().play();
    }

    private function onInputPause(e:PlayerEvent):void {
      video().pause();
    }

    private function onInputStop(e:PlayerEvent):void {
      video().stop();
    }

    private function setupInputBusListeners():void {
      EventBus.addListener(PlayerEvent.PLAY, onInputPlay, EventBus.INPUT);
      EventBus.addListener(PlayerEvent.PAUSE, onInputPause, EventBus.INPUT);
      EventBus.addListener(PlayerEvent.STOP, onInputStop, EventBus.INPUT);

      EventBus.addListener(PlayerEvent.SEEK, EventBus.dispatch, EventBus.INPUT);
      EventBus.addListener(PlayerEvent.SERVER_SEEK, EventBus.dispatch, EventBus.INPUT);
      EventBus.addListener(TimeEvent.CURRENT_TIME_CHANGE, EventBus.dispatch, EventBus.INPUT);
    }

    public function loadTopicsAndSlides():void {
      loader = new BulkLoader('index-sync-load');
      
      loader.add(resourceURL(this.sync), { id: "sync-xml" });
      loader.add(resourceURL(this.index), { id: "index-xml" });
      
      loader.addEventListener(BulkLoader.COMPLETE, onAllItemsLoaded);
      
      loader.start();
    }
    
    public function onAllItemsLoaded(evt : Event) : void {
      var syncXML:XML = new XML(loader.getText("sync-xml"));
      var indexXML:XML = new XML(loader.getText("index-xml"));

      for each (var slide:XML in syncXML.slide) {
        slides.push(Slide.createFromRaw(slide));
      }
      
      for each (var topic:XML in indexXML.ind_item) {
        topics.push(Topic.createFromRaw(topic));
      }
      Topic.toXML(topics);
    }
    
    public function resourceURL(resource:String):String {
      return Configuration.getInstance().lessonHost + Configuration.getInstance().lessonBaseURI + '?file=/ufrj/palestras/hucff/' + resource;
    }
  }
}