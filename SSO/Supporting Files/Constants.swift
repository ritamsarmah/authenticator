//
//  Constants.swift
//  SSO
//
//  Created by Ritam Sarmah on 8/27/18.
//  Copyright © 2018 Ritam Sarmah. All rights reserved.
//

import UIKit

// MARK: - UI

enum Color {
    enum Theme {
        static let Background = UIColor(red: 0.169, green: 0.184, blue: 0.239, alpha: 1.0)
        static let Main = UIColor(red: 0.0, green: 0.639, blue: 0.886, alpha: 1.0)
        static let Text = UIColor.white
        static let PlaceholderText = UIColor.lightGray
    }
    
    static let Facebook = UIColor(red: 0.231, green: 0.349, blue: 0.596, alpha: 1.0)
    static let Twitter = UIColor(red: 0.031, green: 0.627, blue: 0.914, alpha: 1.0)
    static let Google = UIColor(red: 0.863, green: 0.294, blue: 0.227, alpha: 1.0)
    
    enum Button {
        static let SignOut = UIColor(red: 1.0, green: 0.3, blue: 0.3, alpha: 1.0)
    }
}

enum Font {
    private static let fontName = "AppleSDGothicNeo"
    static let Default = UIFont(name: "\(fontName)-Light", size: 16)
    static let DefaultBold = UIFont(name: "\(fontName)-Medium", size: 24)
    static let DefaultThin = UIFont(name: "\(fontName)-Thin", size: 10)
}
