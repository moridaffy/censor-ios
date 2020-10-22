//
//  UIViewController+Alerts.swift
//  censor
//
//  Created by Maxim Skryabin on 21.10.2020.
//

import UIKit

extension UIViewController {
    
    func showAlert(title: String?,
                   body: String?,
                   button: String?,
                   actions: [UIAlertAction]?,
                   preferredStyle: UIAlertController.Style = .alert,
                   onDismiss: (() -> Void)? = nil) {
        let alert = UIAlertController(title: title, message: body, preferredStyle: preferredStyle)
        for action in (actions ?? []) {
            alert.addAction(action)
        }
        if let button = button {
            let lastButton = UIAlertAction(title: button, style: .cancel, handler: { _ in
                onDismiss?()
                alert.dismiss(animated: true, completion: nil)
            })
            alert.addAction(lastButton)
        }
        
        present(alert, animated: true, completion: nil)
    }
    
    func showAlertError(error: Error?, desc: String?, critical: Bool, onDismiss: (() -> Void)? = nil) {
        var body: String = desc ?? "Произошла неизвестная ошибка"
        if let error = error {
            body += "\n\(error)"
        }
        let button: String? = critical ? nil : "Ок"
        
        showAlert(title: "Ошибка", body: body, button: button, actions: nil, onDismiss: onDismiss)
    }
}
