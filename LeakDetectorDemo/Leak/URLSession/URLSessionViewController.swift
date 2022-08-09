//
// Copyright © 2021 An Tran. All rights reserved.
//

// Copied from: https://gist.github.com/almaleh/7e918ee284e67b2a8297b558f22a68ba

import Foundation
import UIKit

final class LeakURLSessionViewController1: ChildViewController {
    
    private var closureStorage: Any?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupURLSession()
    }
    
    /* If we store a URLSession task without executing it immediately it will
     * leak the controller, unless we use [weak self] */
    func setupURLSession() {
        let url = URL(string: "https://www.github.com")!
        let task = URLSession.shared.downloadTask(with: url) { localURL, _, _ in
            guard let localURL = localURL else { return }
            let contents = (try? String(contentsOf: localURL)) ?? "No contents"
            print(contents)
            print(self.view.description)
        }
        closureStorage = task
    }
}

final class NoLeakURLSessionViewController1: ChildViewController {
    
    private var closureStorage: Any?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupURLSession()
    }
    
    /* If you execute the URLSession task immediately, but set a long timeout interval, it will delay the deallocation
     * of your controller until you either cancel the task, get a response back, or timeout. Using [weak self] will
     * prevent that delay. Note: Using port 81 on the url helps simulate a request timeout */
    func setupURLSession() {
        let url = URL(string: "https://www.google.com:81")!
               
        let sessionConfig = URLSessionConfiguration.default
        // Simulate time out after 3 seconds. In reality, we will need to configure our
        // LeakDetector to avoid false-positive detection because this view controller
        // will not be leaked but it will have a delayed allocation because of
        // the long-running network call
        sessionConfig.timeoutIntervalForRequest = 3
        sessionConfig.timeoutIntervalForResource = 3
        let session = URLSession(configuration: sessionConfig)
       
        let task = session.downloadTask(with: url) { localURL, _, error in
            guard let localURL = localURL else { return }
            let contents = (try? String(contentsOf: localURL)) ?? "No contents"
            print(contents)
            print(self.view.description)
        }
        task.resume()
    }
}
