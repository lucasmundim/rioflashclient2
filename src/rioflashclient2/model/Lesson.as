package rioflashclient2.model {
  import rioflashclient2.event.EventBus;
  import rioflashclient2.event.PlayerEvent;
	import rioflashclient2.configuration.Configuration;

	import flash.events.Event;

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
		public var video:String;
		private var slides:Array = new Array();
		private var topics:Array = new Array();
    
    public function Lesson() {
      // do nothing
    }
    
    public function valid():Boolean {
      return allSlidesValid() && allTopicsValid();
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
			video = xml.related_media.rm_item.(rm_type == 'video').rm_filename;
    }

		public function loadTopicsAndSlides():void {
			loader = new BulkLoader('index-sync-load');
			
		  loader.add(Configuration.getInstance().lessonHost + Configuration.getInstance().lessonBaseURI + '?file=/ufrj/palestras/hucff/' + this.sync, { id: "sync-xml" });
			loader.add(Configuration.getInstance().lessonHost + Configuration.getInstance().lessonBaseURI + '?file=/ufrj/palestras/hucff/' + this.index, { id: "index-xml" });
			
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

			EventBus.dispatch(new PlayerEvent(PlayerEvent.READY_TO_PLAY));
		}
		
		public function videoURL():String {
			return Configuration.getInstance().lessonHost + Configuration.getInstance().lessonBaseURI + '?file=/ufrj/palestras/hucff/' + this.video
		}
  }
}