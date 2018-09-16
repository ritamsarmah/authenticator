//
//  LoginButton.swift
//  SSO
//
//  Created by Ritam Sarmah on 9/11/18.
//  Copyright © 2018 Ritam Sarmah. All rights reserved.
//

import UIKit

@IBDesignable class LoginButton: UIButton {
    
    /*
     // Only override draw() if you perform custom drawing.
     // An empty implementation adversely affects performance during animation.
     override func draw(_ rect: CGRect) {
     // Drawing code
     }
     */
    
    private enum Color {
        static let Facebook = UIColor(red: 0.231, green: 0.349, blue: 0.596, alpha: 1.0)
        static let Twitter = UIColor(red: 0.031, green: 0.627, blue: 0.914, alpha: 1.0)
        static let Google = UIColor(red: 0.863, green: 0.294, blue: 0.227, alpha: 1.0)
        
        static func color(for type: Authenticator.LoginType) -> UIColor {
            switch type {
            case .facebook:
                return Color.Facebook
            case .twitter:
                return Color.Twitter
            case .google:
                return Color.Google
            }
        }
    }
    
    fileprivate enum Constraint {
        static let width: CGFloat = 50
        static let height: CGFloat = 50
        static let inset: CGFloat = 13
    }
    
    var type: Authenticator.LoginType
    
    init(type: Authenticator.LoginType) {
        self.type = type
        
        super.init(frame: CGRect(x: 0, y: 0, width: Constraint.width, height: Constraint.height))
        
        configure(with: type)
        
        translatesAutoresizingMaskIntoConstraints = false
        widthAnchor.constraint(equalToConstant: Constraint.width).isActive = true
        heightAnchor.constraint(equalToConstant: Constraint.height).isActive = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.type = .facebook
        super.init(coder: aDecoder)
        configure(with: self.type)
    }
    
    private func configure(with type: Authenticator.LoginType) {
        switch type {
        case .facebook:
            let image = UIImage(named: "facebook")?.withRenderingMode(.alwaysTemplate)
            addTarget(self, action: #selector(facebookLoginClicked), for: .touchUpInside)
            setImage(image, for: .normal)
        case .google:
            let image = UIImage(named: "google")?.withRenderingMode(.alwaysTemplate)
            addTarget(self, action: #selector(googleLoginClicked), for: .touchUpInside)
            setImage(image, for: .normal)
        case .twitter:
            let image = UIImage(named: "twitter")?.withRenderingMode(.alwaysTemplate)
            addTarget(self, action: #selector(twitterLoginClicked), for: .touchUpInside)
            setImage(image, for: .normal)
        }
        
        imageEdgeInsets = UIEdgeInsets(top: Constraint.inset,
                                            left: Constraint.inset,
                                            bottom: Constraint.inset,
                                            right: Constraint.inset)
        imageView?.contentMode = .scaleAspectFit
        imageView?.tintColor = .white
        tintColor = .white
        backgroundColor = Color.color(for: type)
        setBackgroundColor(color: backgroundColor!.darker(), forState: .highlighted)
        setBackgroundColor(color: backgroundColor!.darker(), forState: .focused)
        setBackgroundColor(color: backgroundColor!.darker(), forState: .selected)
        layer.masksToBounds = true
        layer.cornerRadius = 6
    }
    
    @objc private func googleLoginClicked() {
        Authenticator.shared.logIn(with: .google)
    }
    
    @objc private func facebookLoginClicked() {
        Authenticator.shared.logIn(with: .facebook)
    }
    
    @objc private func twitterLoginClicked() {
        Authenticator.shared.logIn(with: .twitter)
    }
}

class LoginButtonGroup: UIStackView {
    
    var buttonSize: CGFloat = LoginButton.Constraint.width {
        didSet {
            updateConstraints()
        }
    }
    
    override var axis: UILayoutConstraintAxis {
        didSet {
            updateConstraints()
        }
    }
    
    private(set) var buttons = [LoginButton]()
    private var widthConstraint: NSLayoutConstraint?
    private var heightConstraint: NSLayoutConstraint?
    
    init(types: [Authenticator.LoginType]) {
        super.init(frame: CGRect.zero)
        for type in types {
            let button = LoginButton(type: type)
            buttons.append(button)
            addArrangedSubview(button)
        }
        
        spacing = DefaultConstraint.spacing
        distribution = .equalSpacing
        axis = .horizontal
        
        updateConstraints()
    }
    
    required init(coder: NSCoder) {
        super.init(coder: coder) 
    }

    override func updateConstraints() {
        super.updateConstraints()
        
        translatesAutoresizingMaskIntoConstraints = false
        frame = CGRect.zero
      
        for button in buttons {
            button.widthAnchor.constraint(equalToConstant: buttonSize).isActive = true
            button.heightAnchor.constraint(equalToConstant: buttonSize).isActive = true
        }
        
        widthConstraint?.isActive = false
        heightConstraint?.isActive = false
        
        let longSide = (buttonSize * CGFloat(buttons.count)) + (spacing * CGFloat(buttons.count - 1))
        switch axis {
        case .horizontal:
            widthConstraint = widthAnchor.constraint(equalToConstant: longSide)
            heightConstraint = heightAnchor.constraint(equalToConstant: buttonSize)
        case .vertical:
            widthConstraint = widthAnchor.constraint(equalToConstant: buttonSize)
            heightConstraint = heightAnchor.constraint(equalToConstant: longSide)
        }
        
        widthConstraint?.isActive = true
        heightConstraint?.isActive = true
    }
    
    private enum DefaultConstraint {
        static let spacing: CGFloat = 16
    }
    
}
