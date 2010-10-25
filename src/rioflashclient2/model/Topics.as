package rioflashclient2.model {
  import rioflashclient2.configuration.Configuration;
  public class Topics {
    public var rawXML:XML;
    public var parsedXML:XML;
    public var topicTimes:Array = new Array();

    public function Topics(xml:XML) {
      rawXML = xml;
      parsedXML = parse(rawXML);
    }

    public function parse(xml:XML):XML {
      var item:XML = <node />

      if (xml.hasOwnProperty("text")) {
        item.@label = Configuration.getInstance().formatTime(xml.time) + " - " + xml.text;;
        item.@time = xml.time;
        topicTimes.push(xml.time);
      } else {
        item.@label = 'Root';
      }

      for each (var childNode:XML in xml.ind_item) {
        item.appendChild(parse(childNode));
      }

      return item;
    }

    public function toXML():XML {
      return parsedXML;
    }
  }
}