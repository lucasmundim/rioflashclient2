package rioflashclient2.net.pseudostreaming {

import rioflashclient2.net.pseudostreaming.DefaultSeekDataStore;

public class FLVSeekDataStore extends DefaultSeekDataStore {

    override protected function extractKeyFrameFilePositions(metaData:Object):Array {
        log.debug("extractKeyFrameFilePositions");
        var keyFrames:Object = extractKeyFrames(metaData);
        if (!keyFrames) return null;
        return keyFrames.filepositions;
    }

    override protected function extractKeyFrameTimes(metaData:Object):Array {
        log.debug("extractKeyFrameTimes");
        var keyFrames:Object = extractKeyFrames(metaData);
        if (!keyFrames) return null;
        
        var keyFrameTimes:Array = keyFrames.times;
        if (!keyFrameTimes) {
            log.error("clip does not have keyframe metadata, cannot use pseudostreaming");
        }
        return keyFrameTimes as Array;
    }
    
    private function extractKeyFrames(metaData:Object):Object {
        var keyFrames:Object = metaData.keyframes;
        log.debug("keyFrames: " + keyFrames); // commented
        if (!keyFrames) {
            log.info("No keyframes in this file, random seeking cannot be done");
            return null;
        }
        return keyFrames;
    }

    override protected function queryParamValue(pos:Number):Number {
        return _keyFrameFilePositions[pos] as Number;
    }


    override public function inBufferSeekTarget(target:Number):Number {
        return target;
    }

    override public function currentPlayheadTime(time:Number, start:Number):Number {
        return time - start;
    }
	}
}