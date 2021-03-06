﻿package rioflashclient2.chrome.controlbar.widget {
  import caurina.transitions.Tweener;

  import rioflashclient2.assets.PlayPauseButtonAsset;
  import rioflashclient2.event.EventBus;
  import rioflashclient2.event.PlayerEvent;

  import flash.events.Event;
  import flash.events.MouseEvent;

  public class PlayPauseButton extends PlayPauseButtonAsset {
    private var currentState:String;

    private var playingState:String = 'playing';
    private var pausedState:String = 'paused';

    public function PlayPauseButton() {
      if (!!stage) init();
      else addEventListener(Event.ADDED_TO_STAGE, init);
    }

    private function init(e:Event=null):void {
      setupEventListeners();
      setupBusListeners();
      setupInterface();
      setPausedState();
    }

    private function setupEventListeners():void {
      addEventListener(MouseEvent.ROLL_OVER, onMouseOver);
      addEventListener(MouseEvent.ROLL_OUT, onMouseOut);
      addEventListener(MouseEvent.CLICK, onClick);
    }

    private function setupBusListeners():void {
      EventBus.addListener(PlayerEvent.PLAY, onPlay);
      EventBus.addListener(PlayerEvent.PAUSE, onPause);
      EventBus.addListener(PlayerEvent.ENDED, onEnded);
    }

    private function setupInterface():void {
      buttonMode = true;
    }

    public function setPlayingState():void {
      currentState = playingState;
      gotoAndStop(currentState);
    }

    public function setPausedState():void {
      currentState = pausedState;
      gotoAndStop(currentState);
    }

    private function onMouseOver(e:MouseEvent):void {
      gotoAndStop(currentState + "_over");
    }

    private function onMouseOut(e:MouseEvent):void {
      gotoAndStop(currentState);
    }

    private function onClick(e:MouseEvent=null):void {
      if (currentState == playingState) {
        EventBus.dispatch(new PlayerEvent(PlayerEvent.PAUSE), EventBus.INPUT);
      } else {
        EventBus.dispatch(new PlayerEvent(PlayerEvent.PLAY), EventBus.INPUT);
      }
    }

    private function onPlay(e:PlayerEvent):void {
      setPlayingState();
    }

    private function onPause(e:PlayerEvent):void {
      setPausedState();
    }

    private function onEnded(e:PlayerEvent):void {
      setPausedState();
    }

    public function get offsetLeft():Number {
      return 0;
    }

    public function get offsetTop():Number {
      return 0;
    }

    public function get align():String {
      return WidgetAlignment.LEFT;
    }
  }
}
