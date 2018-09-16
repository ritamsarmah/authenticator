//
//  HomeViewController.swift
//  SSO
//
//  Created by Ritam Sarmah on 8/28/18.
//  Copyright © 2018 Ritam Sarmah. All rights reserved.
//

import UIKit
import Kingfisher
import AVKit
import AVFoundation

class HomeViewController: UIViewController {
    
    var user: User?
    
    var profileImageView = UIImageView()
    var nameLabel = UILabel()
    var backgroundView = UIVisualEffectView()
    var signOutButton = UIButton(type: .system)
    
    var player: AVPlayer!
    var playerItem: AVPlayerItem!
    var playerLayer: AVPlayerLayer!
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateUI()
    }
    
    func updateUI() {
        guard let user = user else { fatalError() }
        
        // Configure background video
        if let path = Bundle.main.path(forResource: "bubbles", ofType: "mov") {
            let url = URL(fileURLWithPath: path)
            playerItem = AVPlayerItem(url: url)
            player = AVPlayer(playerItem: playerItem)
            NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object: self.player.currentItem, queue: nil, using: { (_) in
                DispatchQueue.main.async {
                    self.player.seek(to: kCMTimeZero)
                    self.player.play()
                }
            })
            playerLayer = AVPlayerLayer(player: player)
            view.layer.addSublayer(playerLayer)
            playerLayer.frame = view.frame
            player.play()
        }
        
        view.backgroundColor = .clear
        
        backgroundView.layer.masksToBounds = true
        backgroundView.layer.cornerRadius = 10
        backgroundView.effect = UIBlurEffect(style: .prominent)
        view.addSubview(backgroundView)
        backgroundView.translatesAutoresizingMaskIntoConstraints = false
        backgroundView.widthAnchor.constraint(equalToConstant: Constraint.BackgroundView.width).isActive = true
        backgroundView.heightAnchor.constraint(equalToConstant: Constraint.BackgroundView.height).isActive = true
        backgroundView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        backgroundView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        
        // Profile Image View
        profileImageView.kf.setImage(with: user.pictureUrl)
        profileImageView.layer.masksToBounds = true
        profileImageView.layer.cornerRadius = Constraint.ProfileImageView.width/2
        
        view.addSubview(profileImageView)
        profileImageView.translatesAutoresizingMaskIntoConstraints = false
        profileImageView.widthAnchor.constraint(equalToConstant: Constraint.ProfileImageView.width).isActive = true
        profileImageView.heightAnchor.constraint(equalToConstant: Constraint.ProfileImageView.height).isActive = true
        profileImageView.topAnchor.constraint(equalTo: backgroundView.topAnchor, constant: Constraint.ProfileImageView.topConstant).isActive = true
        profileImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        // Name Label
        nameLabel.text = user.fullName
        nameLabel.textColor = .black
        nameLabel.font = Font.DefaultBold
        
        view.addSubview(nameLabel)
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        nameLabel.topAnchor.constraint(equalTo: profileImageView.bottomAnchor, constant: Constraint.NameLabel.bottomConstant).isActive = true
        
        // Sign Out Button
        signOutButton.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        signOutButton.setTitle("Sign Out", for: .normal)
        signOutButton.setTitleColor(.white, for: .normal)
        signOutButton.backgroundColor = Color.Button.SignOut
        signOutButton.setBackgroundColor(color: signOutButton.backgroundColor!.lighter(), forState: .highlighted)
        signOutButton.layer.masksToBounds = true
        signOutButton.layer.cornerRadius = 10
        signOutButton.addTarget(self, action: #selector(logOut), for: .touchUpInside)
        
        view.addSubview(signOutButton)
        signOutButton.translatesAutoresizingMaskIntoConstraints = false
        signOutButton.widthAnchor.constraint(equalToConstant: Constraint.SignOutButton.width).isActive = true
        signOutButton.heightAnchor.constraint(equalToConstant: Constraint.SignOutButton.height).isActive = true
        signOutButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        signOutButton.bottomAnchor.constraint(equalTo: backgroundView.bottomAnchor, constant: Constraint.SignOutButton.bottomConstant).isActive = true
    }
    
    @objc func logOut() {
        Authenticator.shared.logOut()
        Presenter.toLogin(from: self, transition: .flipHorizontal)
    }
}

fileprivate enum Constraint {
    enum ProfileImageView {
        static let width: CGFloat = 100
        static let height: CGFloat = width
        static let topConstant: CGFloat = 40
    }
    
    enum NameLabel {
        static let bottomConstant: CGFloat = 16
    }
    
    enum SignOutButton {
        static let width: CGFloat = 200
        static let height: CGFloat = 40
        static let bottomConstant: CGFloat = -40
    }
    
    enum BackgroundView {
        static let width: CGFloat = 250
        static let height: CGFloat = 290
    }
}
