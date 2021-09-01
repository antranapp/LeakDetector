//
// Copyright © 2021 An Tran. All rights reserved.
//

import Combine
import Foundation
import LeakDetectorCombine

class NoLeakFutureViewController1: ChildViewController {
    
    private var cancellables = Set<AnyCancellable>()
    
    private var publisher: Future<Bool, Error>?
        
    override func viewDidLoad() {
        super.viewDidLoad()

        publisher = processAsync()
        
        publisher?.sink(
            receiveCompletion: { result in
                switch result {
                case .failure(let error):
                    self.display(error.localizedDescription)
                case .finished:
                    self.display("finished")
                }
            },
            receiveValue: {
                self.display(String($0))
            }
        )
        .store(in: &cancellables)
    }
    
    private func transform(_ value: Bool) -> AnyPublisher<Bool, Never> {
        Just(value)
            .map { !$0 }
            .eraseToAnyPublisher()
    }
    
    private func display(_ status: String) {
        print(status)
    }
    
    private func processAsync() -> Future<Bool, Error> {
        let future = Future<Bool, Error> { promise in
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.view.tag = 111
                promise(.success(true))
            }
        }
        return future
    }
}

class NoLeakFutureViewController2: ChildViewController {
    
    private var cancellables = Set<AnyCancellable>()
    
    private var boolValue: Bool = false
        
    override func viewDidLoad() {
        super.viewDidLoad()

        processAsync().sink(
            receiveCompletion: { result in
                switch result {
                case .failure(let error):
                    self.display(error.localizedDescription)
                case .finished:
                    self.display("finished")
                }
            },
            receiveValue: {
                self.setValue($0)
            }
        )
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
    
    private func display(_ status: String) {
        print(status)
    }
    
    private func processAsync() -> Future<Bool, Error> {
        let future = Future<Bool, Error> { promise in
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.view.tag = 111
                promise(.success(true))
            }
        }
        return future
    }
}
