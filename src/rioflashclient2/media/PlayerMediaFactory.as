package rioflashclient2.media {
  import rioflashclient2.net.RioServerNetLoader;

  import org.osmf.elements.VideoElement;
  import org.osmf.media.MediaElement;
  import org.osmf.media.MediaFactory;
  import org.osmf.media.MediaFactoryItem;
  import org.osmf.net.NetLoader;

  public class PlayerMediaFactory extends MediaFactory {
    private var netLoader:NetLoader;
  
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
    }
  }
}
