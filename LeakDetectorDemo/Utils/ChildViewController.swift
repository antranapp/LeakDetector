//
// Copyright © 2021 An Tran. All rights reserved.
//

import UIKit

class ChildViewController: UIViewController {
    
    private var buttonTitle: String
    private var buttonAction: (() -> Void)?
    
    init(buttonTitle: String = "Go Back", buttonAction: (() -> Void)? = nil) {
        self.buttonTitle = buttonTitle
        self.buttonAction = buttonAction
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
        let button = UIButton()
        button.setTitle(buttonTitle, for: .normal)
        button.setTitleColor(.blue, for: .normal)
        button.addTarget(self, action: #selector(goBack), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(button)
        
        NSLayoutConstraint.activate([
            button.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            button.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        ])
    }
    
    @objc func goBack() {
        if let buttonAction = buttonAction {
            buttonAction()
        } else {
            navigationController?.popViewController(animated: true)
        }
    }
}
