//
//  Presenter.swift
//  SSO
//
//  Created by Ritam Sarmah on 8/29/18.
//  Copyright © 2018 Ritam Sarmah. All rights reserved.
//

import UIKit

class Presenter {
    
    private init() {}
    
    private static let defaultTransition: UIModalTransitionStyle = .coverVertical
    
    private static func segue(from fromVC: UIViewController, to toVC: UIViewController, transition: UIModalTransitionStyle) {
        toVC.modalTransitionStyle = transition
        DispatchQueue.main.async {
            fromVC.present(toVC, animated: true)
        }
    }
    
    static func toHome(from viewController: UIViewController, user: User, transition: UIModalTransitionStyle = defaultTransition) {
        let homeViewController = HomeViewController()
        homeViewController.user = user
        segue(from: viewController, to: homeViewController, transition: transition)
    }
    
    static func toLogin(from viewController: UIViewController, transition: UIModalTransitionStyle = defaultTransition) {
        let loginViewController = LoginViewController()
        segue(from: viewController, to: loginViewController, transition: transition)
    }
    
}
