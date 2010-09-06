package rioflashclient2.chrome.controlbar.widget {
  import rioflashclient2.event.EventBus;
  
  import flash.display.Sprite;
  import flash.text.AntiAliasType;
  import flash.text.TextField;
  import flash.text.TextFormat;
  import flash.text.TextFormatAlign;

  import org.osmf.events.TimeEvent;
  
  public class ProgressInformationLabel extends Sprite implements ILayoutWidget {
    private var timeInformationField:TextField;
    
    private var format:TextFormat;
    
    private var _currentTime:Number = 0;
    private var _duration:Number = 0;
    
    private static const TOP_PADDING:Number = 4;
    
    public function ProgressInformationLabel() {
      setupBusListeners();
      setupFormat();
      setupTimeInformationField();
      
      addChild(timeInformationField);
      formatLabel();
    }

    private function setupBusListeners():void {
      EventBus.addListener(TimeEvent.CURRENT_TIME_CHANGE, onCurrentTimeChange);
      EventBus.addListener(TimeEvent.DURATION_CHANGE, onDurationChange);
    }

    private function onCurrentTimeChange(e:TimeEvent):void {
      currentTime = e.time;
    }

    private function onDurationChange(e:TimeEvent):void {
      duration = e.time;
    }
    
    public function get label():String {
      return timeInformationField.text;
    }
    
    public function set currentTime(currentTime:Number):void {
      if (!isNaN(currentTime)) {
        _currentTime = currentTime;
        formatLabel();
      }
    }
    
    public function set duration(duration:Number):void {
      if (!isNaN(duration)) {
        _duration = duration;
        formatLabel();
      }
    }
    
    private function formatLabel():void {
      timeInformationField.text = formatTime(_currentTime) + '/' + formatTime(_duration);
    }
    
    private function formatTime(time:Number):String {
      var roundedTime:Number = Math.floor(time);
      var formattedTime:Array = [];
      
      if (roundedTime >= 3600) {
        formattedTime.push(fillWithZero(Math.floor(roundedTime/3600)));    // hours
      }
      
      formattedTime.push(fillWithZero(Math.floor((roundedTime%3600)/60))); // minutes
      formattedTime.push(fillWithZero(roundedTime%60));                    // seconds
      
      return formattedTime.join(':');
    }
    
    private function fillWithZero(number:Number):String {
      return number > 9 ? number.toString() : '0' + number;
    }
    
    private function setupFormat():void {
      format = new TextFormat();
      format.color = 0xFFFFFF;
      format.align = TextFormatAlign.RIGHT;
      format.font = "Arial";
      format.size = 10;
      format.bold = true;
    }
    
    private function setupTimeInformationField():void {
      timeInformationField = new TextField();
      timeInformationField.y = TOP_PADDING;
      timeInformationField.width = 100;
      timeInformationField.height = 26;
      timeInformationField.selectable = false;
      timeInformationField.defaultTextFormat = format;
      timeInformationField.antiAliasType = AntiAliasType.ADVANCED;
    }
    
    public function get offsetLeft():Number {
      return -10;
    }
    
    public function get offsetTop():Number {
      return 1;
    }
    
    public function get align():String {
      return WidgetAlignment.RIGHT;
    }
  }
}