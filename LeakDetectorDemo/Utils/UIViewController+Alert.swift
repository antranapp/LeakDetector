//
// Copyright © 2021 An Tran. All rights reserved.
//

import Foundation
import UIKit

extension UIViewController {
    func showAlert(_ message: String) {
        let alertController = UIAlertController(title: "Alert", message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .cancel) { _ in }
        alertController.addAction(action)
        present(alertController, animated: true, completion: nil)
    }
}
