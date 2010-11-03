package rioflashclient2.event {

  import flash.events.Event;

  public class SlideEvent extends Event {
    public static const NEXT_SLIDE      :String = "onNextSlide";
    public static const PREV_SLIDE      :String = "onPrevSlide";
    public static const LAST_SLIDE      :String = "onLastSlide";
    public static const FIRST_SLIDE     :String = "onFirstSlide";
    public static const CURRENT_SLIDE   :String = "onCurrentSlide";
    public static const SLIDE_CHANGED   :String = "onSlideChanged";

    public var slide:*;

    public function SlideEvent(type:String, slide:*=null, bubbles:Boolean=false, cancelable:Boolean=false) {
      super(type, bubbles, cancelable);
      this.slide = slide;
    }

    public override function clone():Event {
      return new SlideEvent(type, this.slide, bubbles, cancelable);
    }

    public override function toString():String {
      return formatToString("SlideEvent", "type", "slide", "bubbles", "cancelable", "eventPhase");
    }
  }
}
