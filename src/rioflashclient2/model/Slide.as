package rioflashclient2.model {
  public class Slide {
    public var time:int;
    public var relative_path:String;
    
    public function Slide() {
    }
    
    public static function createFromRaw(rawSlide:XML):Slide {
      var slide:Slide = new Slide();
      slide.time = rawSlide.@time;
      slide.relative_path = rawSlide.@relative_path;
      return slide;
    }

    public function valid():Boolean {
      return true;
    }
    
    public function url():String {
      return "http://"
    }
  }
}