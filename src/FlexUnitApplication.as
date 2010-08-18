package
{
	import Array;
	
	import flash.display.Sprite;
	
	import flexunit.flexui.FlexUnitTestRunnerUIAS;
	
	import testSuite.TestSuite;
	import testSuite.tests.TestPlayer;
	
	public class FlexUnitApplication extends Sprite
	{
		public function FlexUnitApplication()
		{
			onCreationComplete();
		}
		
		private function onCreationComplete():void
		{
			var testRunner:FlexUnitTestRunnerUIAS=new FlexUnitTestRunnerUIAS();
			this.addChild(testRunner); 
			testRunner.runWithFlexUnit4Runner(currentRunTestSuite(), "rioflashclient2");
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