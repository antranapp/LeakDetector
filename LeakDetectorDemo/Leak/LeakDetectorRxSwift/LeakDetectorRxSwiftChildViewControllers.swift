//
// Copyright © 2021 An Tran. All rights reserved.
//

import LeakDetectorCombine
import RxCocoa
import RxSwift
import UIKit

// MARK: - Leak

final class LeakDetectorRxSwiftViewController1: ChildViewController {

    let disposeBag = DisposeBag()
    let leakRelay = PublishRelay<Bool>()

    override func viewDidLoad() {
        super.viewDidLoad()

        leakRelay.asSignal()
            .emit(onNext: { _ in
                // self is being hold strongly here, generates a retain cycle
                self.view.tag = 111
            })
            .disposed(by: disposeBag)
    }
}


// MARK: - No Leak

final class NoLeakLeakDetectorRxSwiftViewController1: ChildViewController {

    let disposeBag = DisposeBag()
    let leakRelay = PublishRelay<Bool>()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Capture `self` as weak to avoid retain cycle
        leakRelay.asSignal()
            .emit(onNext: { [weak self] _ in
                self?.view.tag = 111
            })
            .disposed(by: disposeBag)
    }

}
