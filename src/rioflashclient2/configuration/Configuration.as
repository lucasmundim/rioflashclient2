package rioflashclient2.configuration {
  import org.osmf.logging.Log;
  import org.osmf.logging.Logger;

  /**
   * ...
   * @author 
   */
  public class Configuration {
    /**
     * The environment that should be used to get configurations that may change
     * based on where the application is deployed.
     * 
     * The default environment is set to 'production', so that it is not needed
     * in production, and thus, remain hidden from malicious users attempting
     * to hack into the player.
     */
    public var environment:String;
    
    /**
     * Defines the default configurations per environments.
		 *
		 * "http://edad.rnp.br/redirect.rio?file=/ufrj/palestras/hucff/palestra_nelson.xml";
     */
    public var defaultConfigsPerEnvironments:Object = {
      development: {
				lessonHost: 'http://edad.rnp.br',
				lessonBaseURI: '/redirect.rio'
      },
      staging: {
        lessonHost: 'http://edad.rnp.br',
				lessonBaseURI: '/redirect.rio'
      },
      production: {
        lessonHost: 'http://edad.rnp.br',
				lessonBaseURI: '/redirect.rio'
      }
    }
    
    /**
     * The host used to get the lesson XML.
     */
    public var lessonHost:String;
    
    /**
    * The base lesson URI 
    */
    public var lessonBaseURI:String;

		/**
    * The lesson XML file
    */
    public var lessonXML:String;
    
    /**
     * Whether the player should begin playing right away or wait for user input.
     */
    public var autoPlay:Boolean;
    
    /**
     * The number of seconds to buffer before start playing the video.
     */
    public var bufferTime:Number;
    
    private var rawParameters:Object;
    private var logger:Logger = Log.getLogger('Configuration');
    
    private static var _instance:Configuration;
    
    public static function getInstance():Configuration {
      if (_instance == null) {
        _instance = new Configuration();
      }
      
      return _instance;
    }
    
    public function Configuration() {
      // do nothing
    }
    
    public function readParameters(parameters:Object):void {
      this.rawParameters = parameters;
      
      logger.info('Loading configurations...');
      
      setupEnvironment();
      loadEnvironment();

      setupAutoPlay();
      setupBufferTime();
			setupLessonXML();
      
      logger.info("Configurations loaded.");
    }
    
    public function environmentConfig(configName:String):String {
      return defaultConfigsPerEnvironments[environment][configName];
    }
    
    private function setupEnvironment():void {
      environment = rawParameters.environment ? rawParameters.environment : 'production';
    }
    
    private function loadEnvironment():void {
      logger.info('Loading {0} environment configurations...', environment);
      
      setupHosts();
    }
    
    private function setupHosts():void {
      lessonHost = environmentConfig('lessonHost');
			lessonBaseURI = environmentConfig('lessonBaseURI');
    }
    
    private function setupAutoPlay():void {
      autoPlay = new Boolean(rawParameters.autoPlay) || false;
    }
    
    private function setupBufferTime():void {
      bufferTime = new Number(rawParameters.bufferTime) || 3;
    }

		private function setupLessonXML():void {
			lessonXML = rawParameters.aulaXML || '/ufrj/palestras/hucff/palestra_nelson.xml'
		}
  }
}

