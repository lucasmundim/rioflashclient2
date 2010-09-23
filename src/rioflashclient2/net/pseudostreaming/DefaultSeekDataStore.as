package rioflashclient2.net.pseudostreaming {
  import rioflashclient2.event.EventBus;

  import flash.events.ErrorEvent;

  import org.osmf.logging.Log;
  import org.osmf.logging.Logger;

  public class DefaultSeekDataStore {
    protected var log:Logger = Log.getLogger('DefaultSeekDataStore');
    protected var _keyFrameTimes:Array;
    protected var _keyFrameFilePositions:Array;
    protected var _startKeyFrameTime:Number;
    private var _prevSeekTime:Number = 0;
    private var _needToKeepPlayAheadTime:Boolean = false;

    private function init(metaData:Object):void {
      if (!metaData) return;
      log.debug("Will extract keyframe metadata...");
      try {
        _keyFrameTimes = extractKeyFrameTimes(metaData);
        _keyFrameFilePositions = extractKeyFrameFilePositions(metaData);
        if (metaData.seekpoints) {
          _needToKeepPlayAheadTime = true;
        }
      } catch (e:Error) {
        log.error("Error getting keyframes: " + e.message);
        EventBus.dispatch(new ErrorEvent(ErrorEvent.ERROR, false, false, e.message));
      }
      // Debug
      log.debug("KeyFrameTimes array lenth is " + (_keyFrameTimes ? _keyFrameTimes.length+"" : "null array"));
      log.debug("KeyFrameFilePositions array lenth is " + (_keyFrameFilePositions ? _keyFrameFilePositions.length+"" : "null array"));
      log.info("KeyFrames metadata loaded.");
    }

    public static function create(metaData:Object):DefaultSeekDataStore {
      var log:Logger = Log.getLogger('DefaultSeekDataStore');
      var store:DefaultSeekDataStore;

      if (metaData.seekpoints) {
        log.info("Loading h264 keyframes metadata...");
        store = new H264SeekDataStore();
      } else {
        log.info("Loading flv keyframes metadata...");
        store = new FLVSeekDataStore();
      }

      store.init(metaData);
      return store;
    }

    public function needToKeepPlayAheadTime():Boolean {
      return _needToKeepPlayAheadTime;
    }

    public function allowRandomSeek():Boolean {
      return _keyFrameTimes != null && _keyFrameTimes.length > 0;
    }

    protected function extractKeyFrameFilePositions(metadata:Object):Array {
      return null;
    }

    protected function extractKeyFrameTimes(metadata:Object):Array {
      return null;
    }

    internal function get dataAvailable():Boolean {
      return _keyFrameTimes != null;
    }


    public function getNearestKeyFramePosition(seekPosition: Number, rangeBegin:Number = 0, rangeEnd:Number = undefined):Number {
      if (!rangeEnd) {
        rangeEnd = _keyFrameTimes.length - 1;
      }

      if (rangeBegin == rangeEnd) {
        _prevSeekTime =_keyFrameTimes[rangeBegin];
        return queryParamValue(rangeBegin);
      }

      var rangeMid:Number = Math.floor((rangeEnd + rangeBegin)/2);
      if (_keyFrameTimes[rangeMid] >= seekPosition)
        return getNearestKeyFramePosition(seekPosition, rangeBegin, rangeMid);
      else
        return getNearestKeyFramePosition(seekPosition, rangeMid+1, rangeEnd);
    }

    protected function queryParamValue(pos:Number):Number {
      return _keyFrameFilePositions[pos];
    }

    public function reset():void {
      _prevSeekTime = 0;
    }

    public function inBufferSeekTarget(target:Number):Number {
      return target - _prevSeekTime;
    }

    public function currentPlayheadTime(time:Number, start:Number):Number {
      return time - start + _prevSeekTime;
    }

    public function keyFrameTime():Number {
      return _startKeyFrameTime;
    }
  }
}
