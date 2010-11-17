package rioflashclient2.chrome.controlbar.widget
{
  import rioflashclient2.event.EventBus;
  import rioflashclient2.event.PlayerEvent;

  import flash.events.MouseEvent;

  public class VideoFullScreenButton extends FullScreenButton
  {
    public function VideoFullScreenButton()
    {
      super();
    }

    override protected function onClick(e:MouseEvent):void {
      if (currentState == fullScreenState) {
        EventBus.dispatch(new PlayerEvent(PlayerEvent.EXIT_FULL_SCREEN, { mode: "video" }), EventBus.INPUT);
      } else {
        EventBus.dispatch(new PlayerEvent(PlayerEvent.ENTER_FULL_SCREEN, { mode: "video" }), EventBus.INPUT);
      }
    }
  }
}