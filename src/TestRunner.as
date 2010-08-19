package
{
	import Array;
	
	import flash.display.Sprite;
	//import mx.core.Singleton;
	//import flash.system.*;
	
	//import org.flexunit.flexui.TestRunnerBase;
	//import mx.logging.LogEventLevel;
	//import org.flexunit.internals.TextListener;
	import org.flexunit.internals.TraceListener;
	import org.flexunit.listeners.CIListener;
	//import org.flexunit.listeners.UIListener;
	import org.flexunit.runner.FlexUnitCore;
	
	//import org.flexunit.runner.notification.async.XMLListener;
	
	import testSuite.TestSuite;
	import testSuite.tests.TestPlayer;
	
	public class TestRunner extends Sprite
	{
		public function TestRunner()
		{
			//var resourceManagerImpl:Object = flash.system.ApplicationDomain.currentDomain.getDefinition("mx.resources::ResourceManagerImpl");
			//Singleton.registerClass("mx.resources::IResourceManager", Class(resourceManagerImpl));
			//Singleton.registerClass("mx.styles::IStyleManager2", Class(ApplicationDomain.currentDomain.getDefinition("mx.styles::StyleManagerImpl")));
			
			onCreationComplete();
		}
		
		private function onCreationComplete():void
		{
			var core : FlexUnitCore = new FlexUnitCore();
			
			//var uiListener:TestRunnerBase = new TestRunnerBase();
			//this.addChild(uiListener);
			
			/**If you don't need graphical test results, comment out the line below and the MXML declaring
			the TestRunnerBase. **/
			//core.addListener(new UIListener(uiListener));
			core.addListener(new CIListener());
			
			//Leaving this one in allows you to see the results in Flash Builder as well if it is open
      //Else, it will just fail and go on. The name in the quotes below is your project name
      //core.addListener(new XMLListener("rioflashclient2"));

			/**If you would like to see text output in verbose mode, umcomment either of the follow listeners **/
			core.addListener( new TraceListener() );  // - For AS3 Projects
			//core.addListener( TextListener.getDefaultTextListener( LogEventLevel.DEBUG ) ); // - For Flex Projects
			
			core.run(currentRunTestSuite());
		}
		
		public function currentRunTestSuite():Array
		{
			var testsToRun:Array = new Array();
			//testsToRun.push(testSuite.tests.TestPlayer);
			testsToRun.push(testSuite.TestSuite);
			return testsToRun;
		}
	}
}