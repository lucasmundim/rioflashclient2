/*
*    Copyright (c) 2010, Globo Comunicações e Participações S.A. All Rights Reserved.
*/

package rioflashclient2.model {
  import rioflashclient2.configuration.Configuration;
  import rioflashclient2.event.EventBus;
  import rioflashclient2.event.LessonEvent;
  import rioflashclient2.logging.EventfulLoggerFactory;
  
  import flash.events.ErrorEvent;
  import flash.events.Event;
  import flash.net.URLLoader;
  
  import flexunit.framework.Assert;
  
  import org.flexunit.async.Async;
  import org.osmf.logging.Log;
  
  public class LessonLoaderTest {
    private var lessonXML:String;
    private var lessonLoader:LessonLoader;
    
    [Before]
    public function setUp():void {
      Configuration.getInstance().lessonHost = 'fixtures';
      Configuration.getInstance().lessonBaseURI = '/xmls/';
      Log.loggerFactory = new EventfulLoggerFactory();
      lessonXML = 'palestra_nelson.xml';
      lessonLoader = new LessonLoader(lessonXML);
    }
    
    [After]
    public function tearDown():void {
      Configuration.getInstance().lessonHost = '';
      Configuration.getInstance().lessonBaseURI = '';
    }
    
    [Test(async, timeout="3000")]
    public function shouldDispatchLessonEventLoadedToEventBusWhenLessonDataIsLoadedAndParsed():void {
      Async.proceedOnEvent(this, EventBus.getInstance(), LessonEvent.LOADED);
      lessonLoader.load();
    }
    
    [Test(async, timeout="3000")]
    public function shouldPutLoadedLessonDataWithTheLessonLoadedEvent():void {
      var loaded:Function = function(e:LessonEvent, ...args):void {
        Assert.assertNotNull(e.lesson);
      };
      
      Async.handleEvent(this, EventBus.getInstance(), LessonEvent.LOADED, loaded);
      lessonLoader.load();
    }
    
    [Test(async, timeout="3000")]
    public function shouldNotDispatchLessonEventLoadedToEventBusWhenLessonDataCannotBeLoaded():void {
      Async.failOnEvent(this, EventBus.getInstance(), LessonEvent.LOADED);
      EventBus.getInstance().addEventListener(ErrorEvent.ERROR, function(e:Event):void {});
      lessonXML = 'inexistent_lesson_xml';
      lessonLoader = new LessonLoader(lessonXML);
      lessonLoader.load();
    }
    
    [Test(async, timeout="3000")]
    public function shouldDispatchErrorEventToEventBusWhenLessonDataCannotBeLoaded():void {
      Async.proceedOnEvent(this, EventBus.getInstance(), ErrorEvent.ERROR);
      lessonXML = 'inexistent_lesson_xml';
      lessonLoader = new LessonLoader(lessonXML);
      lessonLoader.load();
    }
    
    [Test(async, timeout="3000")]
    public function shouldNotDispatchLessonEventLoadedToEventBusWhenLessonDataIsInvalid():void {
      Async.failOnEvent(this, EventBus.getInstance(), LessonEvent.LOADED);
      EventBus.getInstance().addEventListener(ErrorEvent.ERROR, function(e:Event):void {});
      lessonXML = 'invalid_lesson_xml';
      lessonLoader = new LessonLoader(lessonXML);
      lessonLoader.load();
    }
    
    [Test(async, timeout="3000")]
    public function shouldDispatchErrorEventToEventBusWhenLessonDataIsInvalid():void {
      Async.proceedOnEvent(this, EventBus.getInstance(), ErrorEvent.ERROR);
      lessonXML = 'invalid_lesson_xml';
      lessonLoader = new LessonLoader(lessonXML);
      lessonLoader.load();
    }
  }
}