//
//  Alert.swift
//  VideoStreamer
//
//  Created by Ritam Sarmah on 8/9/18.
//  Copyright © 2018 Ritam Sarmah. All rights reserved.
//

import UIKit

struct Alert {
    
    private init() {}
    
    private static let okAction = UIAlertAction(title: "OK", style: .default)
    private static let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
    
    private static func presentAlert(on viewController: UIViewController, title: String?, message: String?, actions: [UIAlertAction]) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        actions.forEach { alert.addAction($0) }
        DispatchQueue.main.async {
            viewController.present(alert, animated: true)
        }
    }
    
    private static func presentActionSheet(on viewController: UIViewController, title: String?, message: String?, actions: [UIAlertAction]) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .actionSheet)
        actions.forEach { alert.addAction($0) }
        DispatchQueue.main.async {
            viewController.present(alert, animated: true)
        }
    }
    
    // MARK: Downloading
    
    static func presentLoginError(on viewController: UIViewController, message: String) {
        presentAlert(on: viewController, title: "Login Error", message: message, actions: [okAction])
    }
}
