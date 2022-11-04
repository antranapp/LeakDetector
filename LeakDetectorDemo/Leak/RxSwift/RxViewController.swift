//
// Copyright © 2021 An Tran. All rights reserved.
//

import LeakDetectorCombine
import RxCocoa
import RxSwift
import UIKit

// MARK: - Leak

class RxSwiftViewController1: ChildViewController {
    
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

class RxSwiftViewController2: ChildViewController {
    
    private let disposeBag = DisposeBag()
    private lazy var button = UIButton()

    override func viewDidLoad() {
        super.viewDidLoad()
        button.rx.tap.subscribe(onDisposed: {
            // self is being hold strongly here, generates a retain cycle
            self.view.tag = 111
        })
        .disposed(by: disposeBag)
    }
}

class RxSwiftViewController3: ChildViewController {

    private let disposeBag = DisposeBag()
    private lazy var button = UIButton()

    override func viewDidLoad() {
        super.viewDidLoad()
        button.rx.tap.subscribe(onDisposed: {
            // self is being hold strongly here, generates a retain cycle
            self.view.tag = 111
        })
        .disposed(by: disposeBag)
    }
}

// MARK: - No Leak

class NoLeakRxSwiftViewController1: ChildViewController {
    
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

class NoLeakRxSwiftViewController2: ChildViewController {
    
    private let disposeBag = DisposeBag()
    private lazy var button = UIButton()

    override func viewDidLoad() {
        super.viewDidLoad()
        button.rx.tap.subscribe(onDisposed: { [weak self] in
            self?.view.tag = 111
        })
        .disposed(by: disposeBag)
    }
}
