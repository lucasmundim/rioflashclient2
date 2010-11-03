package rioflashclient2.chrome.controlbar.widget {
  import com.yahoo.astra.fl.controls.Tree;
  import com.yahoo.astra.fl.controls.treeClasses.*;

  import fl.events.ListEvent;

  import flash.events.Event;
  import flash.events.MouseEvent;

  import org.osmf.events.TimelineMetadataEvent;
  import org.osmf.logging.Log;
  import org.osmf.logging.Logger;
  import org.osmf.metadata.CuePoint;

  import rioflashclient2.configuration.Configuration;
  import rioflashclient2.event.EventBus;
  import rioflashclient2.event.LessonEvent;
  import rioflashclient2.event.PlayerEvent;
  import rioflashclient2.event.SlideEvent;
  import rioflashclient2.model.Lesson;
  import rioflashclient2.model.Topics;

  public class TopicsNavigator extends Tree {
    private var logger:Logger = Log.getLogger('TopicsNavigator');
    private var duration:Number = 0;
    private var lesson:Lesson;
    private var topics:Topics;

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
      this.width = 320;
      this.height = stage.height - Configuration.getInstance().playerHeight;
    }

    private function onClick(ev:ListEvent):void {
      EventBus.dispatch(new PlayerEvent(PlayerEvent.TOPICS_SEEK, ev.item.time), EventBus.INPUT);
    }

    private function onDurationChange(e:PlayerEvent):void {
      duration = e.data;
    }

    private function onTopicCuePoint(event:TimelineMetadataEvent):void
    {
      var cuePoint:CuePoint = event.marker as CuePoint;
      logger.info("Topic CuePoint reached=" + cuePoint.time);
      highlightTopic(cuePoint.time);
    }

    private function highlightTopic(time:Number):void {
      this.selectedIndex = this.dataProvider.getItemIndex(this.findNode('time', time.toString()))
    }

    private function onSeek(e:PlayerEvent):void {
      var seekPercentage:Number = (e.data as Number);
      var seekPosition:Number = calculatedSeekPositionGivenPercentage(seekPercentage);
      highlightTopic(findNearestTopic(seekPosition));
    }

    private function onSlideChanged(e:SlideEvent):void {
      highlightTopic(findNearestTopic(e.slide.time));
    }

    private function findNearestTopic(seekPosition:Number):Number {
      var last:Number = this.topics.topicTimes[0];
      for each (var topicTime:Number in this.topics.topicTimes) {
        if (seekPosition < topicTime) {
          return last;
        }
        last = topicTime;
      }
      return last;
    }

    private function calculatedSeekPositionGivenPercentage(seekPercentage:Number):Number {
      return seekPercentage * duration;
    }

    private function setupEventListeners():void {
      this.addEventListener(ListEvent.ITEM_CLICK, onClick);
    }

    private function setupBusListeners():void {
      EventBus.addListener(LessonEvent.RESOURCES_LOADED, onLessonResourcesLoaded);
      EventBus.addListener(TimelineMetadataEvent.MARKER_TIME_REACHED, onTopicCuePoint);
      EventBus.addListener(PlayerEvent.SEEK, onSeek);
      EventBus.addListener(PlayerEvent.SERVER_SEEK, onSeek);
      EventBus.addListener(PlayerEvent.DURATION_CHANGE, onDurationChange);
      EventBus.addListener(SlideEvent.SLIDE_CHANGED, onSlideChanged, EventBus.INPUT);
    }

    private function onLessonResourcesLoaded(e:LessonEvent):void {
      this.lesson = (e.lesson as Lesson);
      this.topics = (this.lesson.topics as Topics);
      var topicsXML:XML = e.lesson.topics.toXML();
      this.dataProvider = new TreeDataProvider(topicsXML);
      this.openAllNodes();
    }
  }
}