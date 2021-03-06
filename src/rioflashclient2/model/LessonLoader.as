package rioflashclient2.model {
  import rioflashclient2.configuration.Configuration;
  import rioflashclient2.event.EventBus;
  import rioflashclient2.event.LessonEvent;

  import flash.events.ErrorEvent;
  import flash.events.Event;
  import flash.events.EventDispatcher;
  import flash.events.IOErrorEvent;
  import flash.events.SecurityErrorEvent;
  import flash.events.TextEvent;
  import flash.net.URLLoader;
  import flash.net.URLRequest;

  import org.osmf.logging.Log;
  import org.osmf.logging.Logger;

  public class LessonLoader extends GenericLoader {

    public function LessonLoader() { }

    protected override function loaded(data:*):void {
      var lesson:Lesson = new Lesson();
      lesson.parse(new XML(data));
      lesson.loadTopicsAndSlides();

      if (lesson.valid()) {
        EventBus.dispatch(new LessonEvent(LessonEvent.LOADED, lesson));
        logger.info('Lesson loaded.');
      } else {
        EventBus.dispatch(new ErrorEvent(ErrorEvent.ERROR, false, false, 'Lesson is not valid.'));
        logger.error('Lesson is not valid.');
      }
    }

    protected override function url():String {
      return Configuration.getInstance().resourceURL(Configuration.getInstance().lessonXML);
    }
  }
}