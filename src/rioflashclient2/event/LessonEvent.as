package rioflashclient2.event {
  import rioflashclient2.model.Lesson;
  
  import flash.events.Event;
  
  /**
   * ...
   * @author 
   */
  public class LessonEvent extends Event {
    static public const LOADED   :String = "Lesson Loaded"
    static public const RELOADED :String = "Lesson Reloaded"
    
    public var lesson:Lesson;
    
    public function LessonEvent(type:String, lesson:Lesson=null, bubbles:Boolean=false, cancelable:Boolean=false) { 
      super(type, bubbles, cancelable);
      
      this.lesson = lesson;
    } 
    
    public override function clone():Event {
      return new LessonEvent(type, this.lesson, bubbles, cancelable);
    }
    
    public override function toString():String {
      return formatToString("LessonEvent", "type", "lesson", "bubbles", "cancelable", "eventPhase"); 
    }
  }
}
