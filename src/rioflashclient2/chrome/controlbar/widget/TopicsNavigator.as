package rioflashclient2.chrome.controlbar.widget {
	import rioflashclient2.event.EventBus;
	import rioflashclient2.event.LessonEvent;
	import rioflashclient2.event.PlayerEvent;
	
  import com.yahoo.astra.fl.controls.Tree;
  import com.yahoo.astra.fl.controls.treeClasses.*;
  
  import flash.events.Event;
	import fl.events.ListEvent;
  import flash.events.MouseEvent;

  public class TopicsNavigator extends Tree {
    public function TopicsNavigator() {
      if (!!stage) init();
      else addEventListener(Event.ADDED_TO_STAGE, init);
    }
    
    private function init(e:Event=null):void {
			setupEventListeners();
      setupBusListeners();
			resize();
    }

		private function resize():void {
			this.width = 300;
			this.height = stage.height;
		}
		
		private function onClick(ev:ListEvent):void {  
			trace(ev.item.time);
			EventBus.dispatch(new PlayerEvent(PlayerEvent.TOPICS_SEEK, ev.item.time));
		}
		
		private function setupEventListeners():void {
			this.addEventListener(ListEvent.ITEM_CLICK, onClick);
    }

    private function setupBusListeners():void {
      EventBus.addListener(LessonEvent.RESOURCES_LOADED, onLessonResourcesLoaded);
    }

		private function onLessonResourcesLoaded(e:LessonEvent):void {
			var topicsXML:XML = e.lesson.topics.toXML();
			this.dataProvider = new TreeDataProvider(topicsXML);
			this.openAllNodes();
		}
	}
}