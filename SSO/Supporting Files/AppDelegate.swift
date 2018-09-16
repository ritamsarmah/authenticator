//
//  AppDelegate.swift
//  SSO
//
//  Created by Ritam Sarmah on 8/27/18.
//  Copyright © 2018 Ritam Sarmah. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Initialize login services
        Authenticator.shared.configFacebook(application, didFinishLaunchingWithOptions: launchOptions)
        Authenticator.shared.configGoogle(clientID: Keys.GoogleClientID)
        Authenticator.shared.configTwitter(consumerKey: Keys.TwitterConsumerKey, consumerSecret: Keys.TwitterConsumerSecret)
        
        UIApplication.shared.statusBarStyle = .lightContent
        
        window = UIWindow(frame: UIScreen.main.bounds)
        window!.rootViewController = LoginViewController()
        window!.makeKeyAndVisible()
        return true
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        Authenticator.shared.applicationWillResignActive(application)
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        return Authenticator.shared.application(app, open: url, options: options)
    }
    
}

