//
// Copyright © 2021 An Tran. All rights reserved.
//

import Foundation
import UIKit

// MARK: - Leak - Case 1

// Copied form https://docs.swift.org/swift-book/LanguageGuide/AutomaticReferenceCounting.html#//apple_ref/doc/uid/TP40014097-CH20-ID48
final class LeakyHTMLElement {

    let name: String
    let text: String?

    lazy var asHTML: () -> String = {
        if let text = self.text {
            return "<\(self.name)>\(text)</\(self.name)>"
        } else {
            return "<\(self.name) />"
        }
    }

    init(name: String, text: String? = nil) {
        self.name = name
        self.text = text
    }

    deinit {
        print("\(name) is being deinitialized")
    }

}

final class LazyVarViewController1: LeakDetectableViewController {
    
    private var heading: LeakyHTMLElement? = LeakyHTMLElement(name: "h1", text: "Hello")
    
    override func viewDidLoad() {
        super.viewDidLoad()

        prepareButton()
    }
        
    private func prepareButton() {
        let button = UIButton()
        button.setTitle("Release heading", for: .normal)
        button.setTitleColor(.blue, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(releaseHeading), for: .touchUpInside)
        view.addSubview(button)
        
        NSLayoutConstraint.activate([
            button.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            button.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        ])
    }
    
    @objc private func releaseHeading() {
        executeLeakDetector(for: heading!)
        heading = nil
    }

}

// MARK: - No Leak - Case 1

final class NoLeakHTMLElement {

    let name: String
    let text: String?

    lazy var asHTML: () -> String = { [unowned self] in
        if let text = self.text {
            return "<\(self.name)>\(text)</\(self.name)>"
        } else {
            return "<\(self.name) />"
        }
    }

    init(name: String, text: String? = nil) {
        self.name = name
        self.text = text
    }

    deinit {
        print("\(name) is being deinitialized")
    }

}

final class NoLeakLazyVarViewController1: LeakDetectableViewController {
    
    private var heading: NoLeakHTMLElement? = NoLeakHTMLElement(name: "h1", text: "Hello")
    
    override func viewDidLoad() {
        super.viewDidLoad()

        prepareButton()
    }
        
    private func prepareButton() {
        let button = UIButton()
        button.setTitle("Release heading", for: .normal)
        button.setTitleColor(.blue, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(releaseHeading), for: .touchUpInside)
        view.addSubview(button)
        
        NSLayoutConstraint.activate([
            button.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            button.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        ])
    }
    
    @objc private func releaseHeading() {
        executeLeakDetector(for: heading!)
        heading = nil
    }

}
