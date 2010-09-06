package rioflashclient2.net.pseudostreaming {

import flash.events.ErrorEvent;

import org.osmf.logging.Log;
import org.osmf.logging.Logger;

public class DefaultSeekDataStore {
    protected var log:Logger = Log.getLogger(this);
    protected var _keyFrameTimes:Array;
    protected var _keyFrameFilePositions:Array;
    private var _prevSeekTime:Number = 0;

    private function init(metaData:Object):void {
        if (! metaData) return;
        log.debug("will extract keyframe metadata");
        try {
            _keyFrameTimes = extractKeyFrameTimes(metaData);
            _keyFrameFilePositions = extractKeyFrameFilePositions(metaData);
        } catch (e:Error) {
            log.error("error getting keyframes " + e.message);
            EventBus.dispatch(new ErrorEvent(ErrorEvent.ERROR, false, false, e.message));
        }
        // Debug
        log.info("_keyFrameTimes array lenth is " + (_keyFrameTimes ? _keyFrameTimes.length+"" : "null array"));
        log.info("_keyFrameFilePositions array lenth is " + (_keyFrameFilePositions ? _keyFrameFilePositions.length+"" : "null array"));
    }

    public static function create(metaData:Object):DefaultSeekDataStore {
        var log:Logger = Log.getLogger('DefaultSeekDataStore');
        log.debug("extracting keyframe times and filepositions");
        var store:DefaultSeekDataStore = new FLVSeekDataStore();
        store.init(metaData);
        return store;
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


    public function getQueryStringStartValue(seekPosition: Number, rangeBegin:Number = 0, rangeEnd:Number = undefined):Number {
        if (!rangeEnd) {
            rangeEnd = _keyFrameTimes.length - 1;
        }
//        if (rangeBegin == rangeEnd) return queryParamValue(rangeBegin);
        if (rangeBegin == rangeEnd) { 
             _prevSeekTime =_keyFrameTimes[rangeBegin];
             return queryParamValue(rangeBegin);
        }

        var rangeMid:Number = Math.floor((rangeEnd + rangeBegin)/2);
        if (_keyFrameTimes[rangeMid] >= seekPosition)
            return getQueryStringStartValue(seekPosition, rangeBegin, rangeMid);
        else
            return getQueryStringStartValue(seekPosition, rangeMid+1, rangeEnd);
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
  }
}
