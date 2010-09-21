package rioflashclient2.media {
  import org.osmf.elements.SWFElement;
  import org.osmf.elements.VideoElement;
  import org.osmf.media.MediaElement;
  import org.osmf.media.MediaFactory;
  import org.osmf.media.MediaFactoryItem;
  import org.osmf.net.NetLoader;
  
  import rioflashclient2.net.RioServerNetLoader;
  import rioflashclient2.net.RioServerSWFLoader;

  public class PlayerMediaFactory extends MediaFactory {
    private var netLoader:NetLoader;
  	private var swfLoader:RioServerSWFLoader;
    public function PlayerMediaFactory() {
      super();

      init();
    }

    private function init():void {
      netLoader = new RioServerNetLoader();
      addItem
        ( new MediaFactoryItem
          ( "org.osmf.elements.video"
          , netLoader.canHandleResource
          , function():MediaElement
            {
              return new VideoElement(null, netLoader);
            }
          )
        );
		swfLoader = new RioServerSWFLoader();
		addItem
		( new MediaFactoryItem
			( "org.osmf.elements.swf"
				, swfLoader.canHandleResource
				, function():MediaElement
				{
					return new SWFElement(null, swfLoader);
				}
			)
		);
    }
  }
}
