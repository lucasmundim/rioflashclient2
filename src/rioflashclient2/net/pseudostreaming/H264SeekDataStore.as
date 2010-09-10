package rioflashclient2.net.pseudostreaming {

  public class H264SeekDataStore extends DefaultSeekDataStore {

    override protected function extractKeyFrameTimes(metaData:Object):Array {
      var times:Array = new Array();
      for (var j:Number = 0; j != metaData.seekpoints.length; ++j) {
        times[j] = Number(metaData.seekpoints[j]['time']);
        log.info("keyFrame[" + j + "] = " + times[j]);
      }
      return times;
    }

    override protected function queryParamValue(pos:Number):Number {
      return _keyFrameTimes[pos] + 0.01;
    }
  }
}