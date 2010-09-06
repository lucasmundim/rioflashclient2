package rioflashclient2.model {
  public class Topic {
    public var time:int;
    public var text:String;
    
    public function Topic() {
    }
    
    public static function createFromRaw(rawTopic:XML):Topic {
      var topic:Topic = new Topic();
      topic.time = rawTopic.time;
      topic.text = rawTopic.text;
      return topic;
    }

    public static function toXML(topics:Array):String {
      for each (var topic:Topic in topics) {
        trace(topic.text);
      }
    }

    public function valid():Boolean {
      return true;
    }
    
    public function url():String {
      return "http://"
    }
  }
}