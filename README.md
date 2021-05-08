# LeakDetector

## Introduction

`LeakDetector` is based on the implementation from [leakdetector](https://github.com/duyquang91/leakdetector) packge, which in turn is derived from the implementation of a leak detecktor in [UBER's RIB](https://github.com/uber/RIBs/tree/master/ios/RIBs/Classes/LeakDetector) framework.

Instead of depending on `RxSwift`, `LeakDetectorCombine` uses `Combine` framework instead, hence it only supports iOS 13+.

I accidently found another implementation of this `LeakDetector` from [LifeCycleKit](https://github.com/ashare80/LifecycleKit) which shares many similar ideas. The implementation in `LifeCycleKit` has much nicer APIs though. So I recommend you to take a look at the implementation of the `LeakDetector` in `LifeCycleKit` as well.  

## Demo

There is a demo project to demostrate different use cases of the library.

![demo](./Docs/demo.gif)

This demo app focuses on common mistakes that could lead to retain cycles/memory leaks.

## TODO

- [ ] Leak by UICollectionView + DataSource

## References:

- RIBs: [https://github.com/uber/RIBs/tree/master/ios/RIBs](https://github.com/uber/RIBs/tree/master/ios/RIBs)
- LifeCycleKit: [https://github.com/ashare80/LifecycleKit](https://github.com/ashare80/LifecycleKit)
- You don’t (always) need [weak self]: [https://medium.com/flawless-app-stories/you-dont-always-need-weak-self-a778bec505ef](https://medium.com/flawless-app-stories/you-dont-always-need-weak-self-a778bec505ef)
- Everything you need to know about Memory Leaks in iOS: [https://medium.com/flawless-app-stories/all-about-memory-leaks-in-ios-cdd450d0cc34](https://medium.com/flawless-app-stories/all-about-memory-leaks-in-ios-cdd450d0cc34)
- swift-leak-check: [https://github.com/grab/swift-leak-check](https://github.com/grab/swift-leak-check)
- LifetimeTracker: [https://github.com/krzysztofzablocki/LifetimeTracker](https://github.com/krzysztofzablocki/LifetimeTracker()
- The Nested Closure Trap: [https://medium.com/flawless-app-stories/the-nested-closure-trap-356a0145b6d](https://medium.com/flawless-app-stories/the-nested-closure-trap-356a0145b6d)
