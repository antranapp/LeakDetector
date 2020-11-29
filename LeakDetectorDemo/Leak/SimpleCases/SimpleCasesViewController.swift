//
// Copyright © 2020 An Tran. All rights reserved.
//

import Foundation
import UIKit

// MARK: - Leak: Case 1:

// https://docs.swift.org/swift-book/LanguageGuide/AutomaticReferenceCounting.html#//apple_ref/doc/uid/TP40014097-CH20-ID48

class Person {
    let name: String
    init(name: String) { self.name = name }
    var apartment: LeakApartment?
    deinit { print("\(name) is being deinitialized") }
}

class LeakApartment {
    let unit: String
    init(unit: String) { self.unit = unit }
    var tenant: Person?
    deinit { print("Apartment \(unit) is being deinitialized") }
}

class SimpleCasesViewController1: LeakDetectableViewController {
    
    var john: Person?
    var unit4A: LeakApartment?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        prepareButton()

        john = Person(name: "John Appleseed")
        unit4A = LeakApartment(unit: "4A")
        john!.apartment = unit4A
        unit4A!.tenant = john
    }
        
    private func prepareButton() {
        let button = UIButton()
        button.setTitle("Release objects", for: .normal)
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
        executeLeakDetector(for: john!)
        john = nil
        unit4A = nil
    }

}

// MAKR: - No Leak: Case 1

class NoLeakPerson {
    let name: String
    init(name: String) { self.name = name }
    var apartment: NoLeakApartment?
    deinit { print("\(name) is being deinitialized") }
}

class NoLeakApartment {
    let unit: String
    init(unit: String) { self.unit = unit }
    weak var tenant: NoLeakPerson?
    deinit { print("Apartment \(unit) is being deinitialized") }
}

class NoLeakSimpleCasesViewController1: LeakDetectableViewController {
    
    var john: NoLeakPerson?
    var unit4A: NoLeakApartment?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        prepareButton()

        john = NoLeakPerson(name: "John Appleseed")
        unit4A = NoLeakApartment(unit: "4A")
        john!.apartment = unit4A
        unit4A!.tenant = john
    }
        
    private func prepareButton() {
        let button = UIButton()
        button.setTitle("Release objects", for: .normal)
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
        executeLeakDetector(for: john!)
        john = nil
        unit4A = nil
    }

}
