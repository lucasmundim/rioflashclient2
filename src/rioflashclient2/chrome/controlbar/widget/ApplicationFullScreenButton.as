package rioflashclient2.chrome.controlbar.widget
{
  import rioflashclient2.event.EventBus;
  import rioflashclient2.event.PlayerEvent;

  import flash.events.MouseEvent;

  public class ApplicationFullScreenButton extends FullScreenButton
  {
    public function ApplicationFullScreenButton()
    {
      super();
    }

    override protected function onClick(e:MouseEvent):void {
      if (currentState == fullScreenState) {
        EventBus.dispatch(new PlayerEvent(PlayerEvent.EXIT_FULL_SCREEN, { mode: "application" }), EventBus.INPUT);
      } else {
        EventBus.dispatch(new PlayerEvent(PlayerEvent.ENTER_FULL_SCREEN, { mode: "application" }), EventBus.INPUT);
      }
    }
  }
}