package rioflashclient2.chrome.controlbar.widget {
  
  public interface ILayoutWidget {
    function get offsetLeft():Number;
    function get offsetTop():Number;
    
    function get align():String;
    
    function get width():Number;
    function set width(value:Number):void;
    function get height():Number;
    function set height(value:Number):void;
    function get x():Number;
    function set x(value:Number):void;
    function get y():Number;
    function set y(value:Number):void;
  }
}