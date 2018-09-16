//
//  Authenticator.swift
//  SSO
//
//  Created by Ritam Sarmah on 8/29/18.
//  Copyright © 2018 Ritam Sarmah. All rights reserved.
//

import FacebookCore
import FacebookLogin
import GoogleSignIn
import TwitterKit
import SafariServices

protocol AuthenticatorDelegate: AnyObject, GIDSignInUIDelegate {
    func authenticator(_ authenticator: Authenticator, didLogInFor user: User?, withError error: Error?)
    func authenticator(_ authenticator: Authenticator, didLogOutFor user: User?, withError error: Error?)
}

/**
 Info.plist must be initialized with the following:
 
 **Facebook**
 - FacebookAppID = `YOUR_APP_ID`
 - FacebookDisplayName = `YOUR_DISPLAY_NAME`
 - Add `fbYOUR_APP_ID` under URL Types > URL Schemes
 - Add `fbauth2` under LSApplicationQueriesSchemes
 
 
 **Twitter**
 - Add `twitterkit-(YOUR_CONSUMER_KEY)` under URL Types > URL Schemes
 - Add `twitter`, `twitterAuth` under LSApplicationQueriesSchemes
 
 Additionally, the Callback URL for your Twitter App Details (accessible via [Twitter's Developer Site](https://developer.twitter.com/en/apps))
 should be set to `twitterkit-YOUR_CONSUMER_KEY://`
 */
class Authenticator: NSObject, GIDSignInDelegate {
    
    public enum LoginType {
        case facebook, google, twitter
    }
    
    // MARK: - Properties
    
    static let shared = Authenticator()
    
    // MARK: Public
    
    public var ignoresCancelErrors = true
    
    public weak var delegate: AuthenticatorDelegate? {
        didSet {
            GIDSignIn.sharedInstance().uiDelegate = delegate
        }
    }
    
    public var user: User? {
        // Facebook
        if let userProfile = UserProfile.current {
            return User(userProfile: userProfile)
        }
        
        // Google
        if let currentUser = GIDSignIn.sharedInstance().currentUser {
            return User(googleUser: currentUser)
        }
        
        // Twitter
        if let twitterUser = twitterUser {
            return User(twitterUser: twitterUser)
        }
        
        return nil
    }
    
    public var isLoggedIn: Bool {
        return currentLoginType != nil
    }
    
    public var currentLoginType: LoginType? {
        if isFacebookConfigured && UserProfile.current != nil {
            return .facebook
        } else if isGoogleConfigured && GIDSignIn.sharedInstance().hasAuthInKeychain() {
            return .google
        } else if isTwitterConfigured && TWTRTwitter.sharedInstance().sessionStore.session()?.userID != nil {
            return .twitter
        }
        return nil
    }
    
    // MARK: Private
    
    private let fbLoginManager = LoginManager()
    
    private let cancelErrorDescriptions = [
        "The user canceled the sign-in flow.",  // Google
        "User cancelled login flow.",           // Twitter
        "User cancelled login from Twitter App" // Twitter
    ]
    
    private var twitterUser: TWTRUser?
    
    private var isFacebookConfigured: Bool = false
    
    private var isGoogleConfigured: Bool = false
    
    private var isTwitterConfigured: Bool = false
    
    // MARK: - Functions
    
    // MARK: Initialization
    
    override private init() {
        super.init()
    }
    
    /// Call this function from the UIApplicationDelegate.application(application:didFinishLaunchingWithOptions:) function of the AppDelegate of your app.
    /// It should be invoked for the proper initialization of the Facebook SDK.
    func configFacebook(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) {
        SDKApplicationDelegate.shared.application(application, didFinishLaunchingWithOptions: launchOptions)
        UserProfile.updatesOnAccessTokenChange = true
        isFacebookConfigured = true
    }
    
    /// Call this function from the UIApplicationDelegate.application(application:didFinishLaunchingWithOptions:) function of the AppDelegate of your app.
    /// It should be invoked for the proper initialization of the Google SDK.
    func configGoogle(clientID: String) {
        GIDSignIn.sharedInstance().delegate = self
        GIDSignIn.sharedInstance().clientID = clientID
        isGoogleConfigured = true
    }
    
    /// Call this function from the UIApplicationDelegate.application(application:didFinishLaunchingWithOptions:) function of the AppDelegate of your app.
    /// It should be invoked for the proper initialization of the Twitter SDK.
    func configTwitter(consumerKey: String, consumerSecret: String) {
        TWTRTwitter.sharedInstance().start(withConsumerKey: consumerKey, consumerSecret: consumerSecret)
        isTwitterConfigured = true
    }
    
    /// Call this function from the UIApplicationDelegate.applicationWillResignActive(application:) function of the AppDelegate of your app
    /// It should be invoked for logging app events for the Facebook SDK.
    func applicationWillResignActive(_ application: UIApplication) {
        AppEventsLogger.activate()
    }
    
    /// Call this function from the UIApplicationDelegate.application(app:openURL:options:) function of the AppDelegate of your app
    /// It should be invoked to log in with native apps as part of the authorization flow.
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any]) -> Bool {
        if SDKApplicationDelegate.shared.application(app, open: url, options: options) {
            return true
        } else if TWTRTwitter.sharedInstance().application(app, open: url, options: options) {
            return true
        } else if GIDSignIn.sharedInstance().handle(url as URL?,
                                                    sourceApplication: options[.sourceApplication] as? String,
                                                    annotation: options[.annotation]) {
            return true
        }
        return false
    }
    
    private func checkConfig(for type: LoginType) {
        switch type {
        case .facebook:
            if !isFacebookConfigured {
                preconditionFailure("Attempt made to authenticate with Facebook without initialization. Please add configFacebook(:) to UIApplicationDelegate.application(application:didFinishLaunchingWithOptions:)")
            }
        case .google:
            if !isGoogleConfigured {
                preconditionFailure("Attempt made to authenticate with Google without initialization. Please add configGoogle(:) to UIApplicationDelegate.application(application:didFinishLaunchingWithOptions:)")
            }
        case .twitter:
            if !isTwitterConfigured {
                preconditionFailure("Attempt made to authenticate with Twitter without initialization. Please add configTwitter(:) to UIApplicationDelegate.application(application:didFinishLaunchingWithOptions:)")
            }
        }
    }
    
    // MARK: Authentication
    
    /// Automatically logs in a previously authenticated user without interaction
    func logInSilently() {
        if isFacebookConfigured, let userProfile = UserProfile.current {
            delegate?.authenticator(self, didLogInFor: User(userProfile: userProfile), withError: nil)
        } else if isGoogleConfigured && GIDSignIn.sharedInstance().hasAuthInKeychain() {
            GIDSignIn.sharedInstance().signInSilently()
        } else if isTwitterConfigured, let userId = TWTRTwitter.sharedInstance().sessionStore.session()?.userID {
            let twitterClient = TWTRAPIClient(userID: userId)
            twitterClient.loadUser(withID: userId, completion: { (twitterUser, error) in
                if let twitterUser = twitterUser {
                    self.twitterUser = twitterUser
                    self.delegate?.authenticator(self, didLogInFor: self.user, withError: nil)
                } else {
                    self.delegate?.authenticator(self, didLogInFor: nil, withError: error)
                }
            })
        } else {
            self.delegate?.authenticator(self, didLogInFor: nil, withError: nil)
        }
    }
    
    /// Begin login process with specified account type
    func logIn(with type: LoginType) {
        checkConfig(for: type)
        switch type {
        case .facebook:
            fbLoginManager.logIn(readPermissions: [.publicProfile], viewController: nil) { (result) in
                switch result {
                case .success(_, _, let token):
                    UserProfile.fetch(userId: token.userId!, completion: { (fetchResult) in
                        switch fetchResult {
                        case .success:
                            self.delegate?.authenticator(self, didLogInFor: self.user, withError: nil)
                        case .failed(let error):
                            self.handleLoginError(with: error)
                        }
                    })
                case .cancelled:
                    self.handleLoginError(with: nil)
                case .failed(let error):
                    self.handleLoginError(with: error)
                }
            }
        case .google:
            GIDSignIn.sharedInstance().signIn()
        case .twitter:
            TWTRTwitter.sharedInstance().logIn { (session, error) in
                guard let userId = session?.userID else {
                    self.handleLoginError(with: error)
                    return
                }
                
                let twitterClient = TWTRAPIClient(userID: userId)
                twitterClient.loadUser(withID: userId, completion: { (twitterUser, error) in
                    guard let twitterUser = twitterUser else {
                        self.handleLoginError(with: error)
                        return
                    }
                    self.twitterUser = twitterUser
                    self.delegate?.authenticator(self, didLogInFor: User(twitterUser: twitterUser), withError: error)
                })
            }
        }
    }
    
    /// Logs out an authenticated user
    func logOut() {
        guard let currentLoginType = currentLoginType, let tempUser = user?.copy() as? User else {
            return
        }
        
        switch currentLoginType {
        case .facebook:
            fbLoginManager.logOut()
        case .google:
            GIDSignIn.sharedInstance().signOut()
        case .twitter:
            let store = TWTRTwitter.sharedInstance().sessionStore
            if let userId = store.session()?.userID {
                store.logOutUserID(userId)
            }
            twitterUser = nil
        }
        
        delegate?.authenticator(self, didLogOutFor: tempUser, withError: nil)
    }
    
    private func handleLoginError(with error: Error?) {
        if let error = error, self.ignoresCancelErrors && self.cancelErrorDescriptions.contains(error.localizedDescription) {
            self.delegate?.authenticator(self, didLogInFor: nil, withError: nil)
        } else {
            self.delegate?.authenticator(self, didLogInFor: nil, withError: error)
        }
    }
    
    private func handleLogoutError(with error: Error?) {
        if let error = error, self.ignoresCancelErrors && self.cancelErrorDescriptions.contains(error.localizedDescription) {
            self.delegate?.authenticator(self, didLogOutFor: nil, withError: nil)
        } else {
            self.delegate?.authenticator(self, didLogOutFor: nil, withError: error)
        }
    }
    
    // MARK: GIDSignInDelegate
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        guard let googleUser = user else {
            handleLoginError(with: error)
            return
        }
        delegate?.authenticator(self, didLogInFor: User(googleUser: googleUser), withError: error)
    }
    
    func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!, withError error: Error!) {
        guard let googleUser = user else {
            handleLogoutError(with: error)
            return
        }
        delegate?.authenticator(self, didLogOutFor: User(googleUser: googleUser), withError: error)
    }
}

