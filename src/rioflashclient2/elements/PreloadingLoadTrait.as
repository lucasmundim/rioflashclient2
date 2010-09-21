/*****************************************************
*
*  Copyright 2009 Adobe Systems Incorporated.  All Rights Reserved.
*
*****************************************************
*  The contents of this file are subject to the Mozilla Public License
*  Version 1.1 (the "License"); you may not use this file except in
*  compliance with the License. You may obtain a copy of the License at
*  http://www.mozilla.org/MPL/
*
*  Software distributed under the License is distributed on an "AS IS"
*  basis, WITHOUT WARRANTY OF ANY KIND, either express or implied. See the
*  License for the specific language governing rights and limitations
*  under the License.
*
*
*  The Initial Developer of the Original Code is Adobe Systems Incorporated.
*  Portions created by Adobe Systems Incorporated are Copyright (C) 2009 Adobe Systems
*  Incorporated. All Rights Reserved.
*
*****************************************************/
package rioflashclient2.elements
{
  import flash.events.Event;

  import rioflashclient2.elements.AsynchLoadingProxyLoadTrait;
  import org.osmf.media.MediaElement;
  import org.osmf.traits.LoadState;
  import org.osmf.traits.LoadTrait;
  import org.osmf.traits.MediaTraitType;
  import org.osmf.traits.PlayTrait;
  import org.osmf.traits.SeekTrait;

  /**
   * A LoadTrait which maps the "load" operation to the preloading of
   * a different MediaElement.
   *
   * The preload operation is defined as the load of the MediaElement,
   * followed by a play and pause in succession.  (The play/pause was
   * added because RTMP streams need to be played before they're seekable.)
   **/
  public class PreloadingLoadTrait extends AsynchLoadingProxyLoadTrait
  {
    /**
     * Constructor.
     **/
    public function PreloadingLoadTrait(proxiedElement:MediaElement)
    {
      super(proxiedElement.getTrait(MediaTraitType.LOAD) as LoadTrait);

      this.proxiedElement = proxiedElement;

      load();
    }

    /**
     * @private
     **/
    override protected function doCustomLoadLogic(eventToDispatch:Event):void
    {
      var playTrait:PlayTrait = proxiedElement.getTrait(MediaTraitType.PLAY) as PlayTrait;
      if (playTrait != null)
      {
        // Do a play and a pause in succession, to ensure the stream
        // is seekable.
        playTrait.play();
        playTrait.pause();

        calculatedLoadState = LoadState.READY;
        dispatchEvent(eventToDispatch);
      }
      else
      {
        dispatchEvent(eventToDispatch);
      }
    }

    private var proxiedElement:MediaElement;
  }
}