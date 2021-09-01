//
// Copyright © 2021 An Tran. All rights reserved.
//

import Combine
import Foundation

class NoLeakCombineServiceViewController1: ChildViewController {
    
    private var cancellables = Set<AnyCancellable>()
    
    private var boolValue: Bool = false
    
    private var service = Service()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        service.fetch()
            .flatMap {
                self.transform($0)
            }
            .sink {
                self.setValue($0)
            }
            .store(in: &cancellables)
        
    }
    
    private func transform(_ value: Bool) -> AnyPublisher<Bool, Never> {
        Just(value)
            .map { !$0 }
            .eraseToAnyPublisher()
    }
    
    private func setValue(_ value: Bool) {
        boolValue = value
    }
}

private class Service {
    func fetch() -> AnyPublisher<Bool, Never> {
        Just(true).eraseToAnyPublisher()
    }
}
