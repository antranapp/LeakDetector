# LeakDetectorCombine

`LeakDetector` is based on the implementation from [leakdetector](https://github.com/duyquang91/leakdetector) packge, which in turn is derived from the implementation of a leak detecktor in [UBER's RIB](https://github.com/uber/RIBs/tree/master/ios/RIBs/Classes/LeakDetector) framework.

Instead of depending on `RxSwift`, `LeakDetectorCombine` uses `Combine` framework instead, hence it only supports iOS 13+.
