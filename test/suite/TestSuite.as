package suite
{
	import rioflashclient2.event.EventBusTest;
	import rioflashclient2.model.LessonLoaderTest;
	
	[Suite]
	[RunWith("org.flexunit.runners.Suite")]
	public class TestSuite
	{
		public var test1:EventBusTest;
		public var test2:LessonLoaderTest;
	}
}