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
     * Whether the control bar should be displayed or not.
     * 
     * @default true
     */
    public var displayControlBar:Boolean;

    /**
     * The buttons to be displayed in the control bar.
     * 
     * The given value should be a '|' separated list with the buttons to be
     * displayed. Notice that the order in which each button appears affects
     * the order in which they will be layed out.
     * 
     * Also notice that right aligned buttons should be ordered in the reverse
     * order in which they will actually appear. For example, using this:
     * 
     *   playPauseButton|volume|progressInformationLabel|fullScreenButton
     * 
     * Would render buttons as this:
     * 
     *   playPauseButton   -----------------------  fullScreenButton  |  progressInformationLabel  |  volume
     * 
     * While this:
     * 
     *   playPauseButton|fullScreenButton|volume|progressInformationLabel
     * 
     * Would render as:
     * 
     *   playPauseButton   -----------------------  progressInformationLabel  | volume  |  fullScreenButton
     * 
     * Only the order between buttons that have the same alignment will affect
     * rendering. You could do this:
     * 
     *   fullScreenButton|volume|playPauseButton|progressInformationLabel
     * 
     * And it would still render correctly:
     * 
     *   playPauseButton   -----------------------  progressInformationLabel  | volume  |  fullScreenButton
     * 
     * You may skip any button if you don't want it to be displayed:
     * 
     *   playPauseButton|fullScreenButton
     * 
     * Would render:
     * 
     *   playPauseButton   -----------------------  fullScreenButton
     * 
     * @default playPauseButton|fullScreenButton|volume|progressInformationLabel
     */
    public var controlBarButtons:Array;
    
    /**
     * The number of seconds to buffer before start playing the video.
     */
    public var bufferTime:Number;
	public var playerWidth:Number = 320;
	public var playerHeight:Number = 240;
	private static const DEFAULT_CONTROL_BAR_BUTTONS_LAYOUT:String = 'playPauseButton|fullScreenButton|volume|progressInformationLabel';

	
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
      setupControlBar();
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
      autoPlay = booleanValueOf(rawParameters.autoPlay, false);
    }

    private function setupControlBar():void {
      displayControlBar = booleanValueOf(rawParameters.displayControlBar, true);
      
      controlBarButtons = (rawParameters.controlBarButtons || DEFAULT_CONTROL_BAR_BUTTONS_LAYOUT).split('|');
    }
    
    private function setupBufferTime():void {
      bufferTime = new Number(rawParameters.bufferTime) || 3;
    }

    private function setupLessonXML():void {
      //lessonXML = rawParameters.aulaXML || 'Aula_002.xml';
      
      //lessonXML = 'Aula_002.xml';
      lessonXML = '/ufrj/palestras/hucff/palestra_nelson.xml';
      //lessonXML = '/ufjf/ciencias_exatas/dcc119/aula1/dcc119_aula1.xml';
      //lessonXML = '/ufrj/exemplos/exemplo_workshop_abertura_se/exemplo_frutas.xml';
      //lessonXML = 'iphone.xml';
    }

    private function booleanValueOf(value:Object, defaultValue:Boolean):Boolean {
      if (value == 'true') {
        return true;
      } else if (value == 'false') {
        return false;
      } else {
        return defaultValue;
      }
    }
  }
}

