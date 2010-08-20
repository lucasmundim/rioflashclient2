package rioflashclient2.configuration
{
	public class Configuration {
		
		private static var _instance:Configuration;
		public var lessonXmlUrl:String; 
		
		public static function getInstance():Configuration {
			if(_instance == null) {
				_instance = new Configuration();
			}
			return _instance;
		}
		
		public function Configuration() {}
		
		public function load(parameters:Object):void
		{
			lessonXmlUrl = parameters.lessonXmlUrl || "http://edad.rnp.br/redirect.rio?file=/ufrj/palestras/hucff/palestra_nelson.xml";
		}
	}
}
