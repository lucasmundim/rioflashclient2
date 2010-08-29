package runner {
  import org.flexunit.runner.notification.Failure;
  import org.flexunit.runner.notification.RunListener;
  
  public class FailureCheckerListener extends RunListener {
    public var failures:Number = 0;
    
    override public function testAssumptionFailure(failure:Failure):void {
      failures += 1;
      trace('Failures: ' + failures);
    }
    
    override public function testFailure(failure:Failure):void {
      failures += 1;
      trace('Failures: ' + failures);
    }
  }
}