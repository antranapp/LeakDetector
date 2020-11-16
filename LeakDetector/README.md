# LeakDetectorCombine

`LeakDetector` is based on the implementation from [leakdetector](https://github.com/duyquang91/leakdetector) packge, which in turn is derived from the implementation of a leak detecktor in [UBER's RIB](https://github.com/uber/RIBs/tree/master/ios/RIBs/Classes/LeakDetector) framework.

Instead of depending on `RxSwift`, `LeakDetectorCombine` uses `Combine` framework instead, hence it only supports iOS 13+.

I accidently found another implementation of this `LeakDetector` from [LifeCycleKit](https://github.com/ashare80/LifecycleKit) which shares many similar ideas. The implementation in `LifeCycleKit` has much nicer APIs though. So I recommend you to take a look at the implementation of the `LeakDetector` in `LifeCycleKit` as well.  
