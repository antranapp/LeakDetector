//
// Copyright © 2021 An Tran. All rights reserved.
//

import Foundation
import UIKit

class AnimatorViewController: ChildViewController {
    
    private var closureStorage: Any?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        leakyViewPropertyAnimator()
    }
    
    // Copied from https://github.com/almaleh/weak-self/blob/391493f19f8012d13451dc9db36042ac5b34ffb9/WeakSelf/PresentedController.swift
    /* This leaks the controller because we aren't executing the animation immediately. Instead we store it in a property
     * as an escaping closure without using [weak self]. As a result, the closure maintains a strong reference
     * to self, while self also has a strong reference to the closure, thereby causing a leak */
    private func leakyViewPropertyAnimator() {
        // color won't actually change, because we aren't executing the animation
        let anim = UIViewPropertyAnimator(duration: 2.0, curve: .linear) { self.view.backgroundColor = .red }
        anim.addCompletion { _ in self.view.backgroundColor = .white }
        closureStorage = anim
    }
}

class NoLeakAnimatorViewController1: ChildViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        uiViewAnimate()
    }
    
    // Copied from https://github.com/almaleh/weak-self/blob/391493f19f8012d13451dc9db36042ac5b34ffb9/WeakSelf/PresentedController.swift
    // This is a non-escaping closure (executes immediately), therefore we don't need [weak self]
    func uiViewAnimate() {
        UIView.animate(withDuration: 3.0) { self.view.backgroundColor = .red }
    }

}

class NoLeakAnimatorViewController2: ChildViewController {
    
    private var closureStorage: Any?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        nonLeakyViewPropertyAnimator()
    }
    
    // Copied from https://github.com/almaleh/weak-self/blob/391493f19f8012d13451dc9db36042ac5b34ffb9/WeakSelf/PresentedController.swift
    /* If we pass references to the properties we want to manipulate directly to the closure, instead of using self,
     * we will no longer leak the controller, even without using [weak self] */
    func nonLeakyViewPropertyAnimator() {
        let view = self.view
        // color won't actually change, because we aren't executing the animation
        let anim = UIViewPropertyAnimator(duration: 2.0, curve: .linear) { view?.backgroundColor = .red }
        anim.addCompletion { _ in view?.backgroundColor = .white }
        closureStorage = anim
    }
}

class NoLeakAnimatorViewController3: ChildViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        nonLeakyViewPropertyAnimator()
    }
    
    // Copied from https://github.com/almaleh/weak-self/blob/391493f19f8012d13451dc9db36042ac5b34ffb9/WeakSelf/PresentedController.swift
    // If we start the animation immediately, it won't leak the controller, even without [weak self]
    func nonLeakyViewPropertyAnimator() {
        let anim = UIViewPropertyAnimator(duration: 2.0, curve: .linear) { self.view.backgroundColor = .red }
        anim.addCompletion { _ in self.view.backgroundColor = .white }
        anim.startAnimation()
    }
}
