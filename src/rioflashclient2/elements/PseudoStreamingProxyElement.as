package rioflashclient2.elements
{
  import __AS3__.vec.Vector;

  import flash.net.NetStream;

  import org.osmf.elements.ProxyElement;
  import org.osmf.events.LoadEvent;
  import org.osmf.events.MediaElementEvent;
  import org.osmf.media.MediaElement;
  import org.osmf.net.NetStreamLoadTrait;
  import org.osmf.traits.LoadState;
  import org.osmf.traits.LoadTrait;
  import org.osmf.traits.MediaTraitType;
  import org.osmf.traits.SeekTrait;
  import org.osmf.traits.TimeTrait;

  public class PseudoStreamingProxyElement extends ProxyElement
  {
    private var resource_file:String;

    public function PseudoStreamingProxyElement(proxiedElement:MediaElement, resource_file:String)
    {
      super(proxiedElement);
      this.resource_file = resource_file;
      var loadTrait:NetStreamLoadTrait = proxiedElement.getTrait(MediaTraitType.LOAD) as NetStreamLoadTrait;
      loadTrait.addEventListener(LoadEvent.LOAD_STATE_CHANGE, onLoadStateChange);
    }

    protected function createPseudoStreamingProxySeekTrait():SeekTrait
    {
      var loadTrait:NetStreamLoadTrait = proxiedElement.getTrait(MediaTraitType.LOAD) as NetStreamLoadTrait;
      var stream:NetStream = loadTrait.netStream;
      var timeTrait:TimeTrait = (proxiedElement.getTrait(MediaTraitType.TIME)) as TimeTrait;

      return new PseudoStreamingSeekTrait(timeTrait, loadTrait, stream, resource_file);
    }

    override protected function setupTraits():void
    {
      super.setupTraits();
      var traitsToBlock:Vector.<String> = new Vector.<String>();
      traitsToBlock.push(MediaTraitType.SEEK);
      super.blockedTraits = traitsToBlock;
    }

    override public function set proxiedElement(value:MediaElement):void
    {
      super.proxiedElement = value;
    }

    private function processNewSeekTrait():void
    {
      var pseudoStreamingSeekTrait:SeekTrait = createPseudoStreamingProxySeekTrait();
      addTrait(MediaTraitType.SEEK, pseudoStreamingSeekTrait);
      super.blockedTraits = new Vector.<String>();
    }

    private function onLoadStateChange(event:LoadEvent):void
    {
      if (event.loadState == LoadState.READY)
      {
        processNewSeekTrait();
      }
    }
  }
}