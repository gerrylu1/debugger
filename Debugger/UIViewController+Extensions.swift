//
//  UIViewController+Extensions.swift
//  Debugger
//
//  Created by Gerry Low on 2020-06-27.
//  Copyright © 2020 Gerry Low. All rights reserved.
//

import UIKit

extension UIViewController {
    
    func showAlert(title: String?, message: String?, on viewController: UIViewController) {
        let alertVC = UIAlertController(title: title ?? "", message: message ?? "Unknown error.", preferredStyle: .alert)
        alertVC.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        viewController.present(alertVC, animated: true, completion: nil)
    }
    
    func showAlertOKCancel(title: String?, message: String?, on viewController: UIViewController, completion: @escaping () -> Void) {
        let alertVC = UIAlertController(title: title ?? "", message: message ?? "Unknown message.", preferredStyle: .alert)
        alertVC.addAction(UIAlertAction(title: "OK", style: .default, handler: { (_) in
            completion()
        }))
        alertVC.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        viewController.present(alertVC, animated: true, completion: nil)
    }
    
    func showAlertOnDelete(title: String?, message: String?, on viewController: UIViewController, onDelete: @escaping () -> Void) {
        let alertVC = UIAlertController(title: title ?? "", message: message ?? "Unknown message.", preferredStyle: .alert)
        alertVC.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { (_) in
            onDelete()
        }))
        alertVC.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        viewController.present(alertVC, animated: true, completion: nil)
    }
    
    func showAlertTwoActionsWithCancel(title: String?, message: String?, on viewController: UIViewController, actionOneTitle: String, actionTwoTitle: String, actionOneCompletion: @escaping () -> Void, actionTwoCompletion: @escaping () -> Void) {
        let alertVC = UIAlertController(title: title ?? "", message: message ?? "Unknown message.", preferredStyle: .alert)
        alertVC.addAction(UIAlertAction(title: actionOneTitle, style: .default, handler: { (_) in
            actionOneCompletion()
        }))
        alertVC.addAction(UIAlertAction(title: actionTwoTitle, style: .default, handler: { (_) in
            actionTwoCompletion()
        }))
        alertVC.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        viewController.present(alertVC, animated: true, completion: nil)
    }
    
}
