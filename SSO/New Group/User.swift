//
//  UserAccount.swift
//  SSO
//
//  Created by Ritam Sarmah on 8/28/18.
//  Copyright © 2018 Ritam Sarmah. All rights reserved.
//

import Foundation
import FacebookCore
import GoogleSignIn
import TwitterKit

class User: NSCopying {
    
    let fullName: String!
    
    let firstName: String?
    
    let middleName: String?
    
    let lastName: String?
    
    let pictureUrl: URL?
    
    let email: String?
    
    init(fullName: String, firstName: String?, middleName: String?, lastName: String?, pictureUrl: URL?, email: String?) {
        self.fullName = fullName
        self.firstName = firstName
        self.middleName = middleName
        self.lastName = lastName
        self.pictureUrl = pictureUrl
        self.email = email
    }
    
    init(userProfile: UserProfile) {
        self.fullName = userProfile.fullName
        self.firstName = userProfile.firstName
        self.middleName = userProfile.middleName
        self.lastName = userProfile.lastName
        self.pictureUrl = userProfile.imageURLWith(.square, size: CGSize(width: 200, height: 200))
        self.email = nil
    }
    
    init(googleUser: GIDGoogleUser) {
        self.fullName = googleUser.profile.name
        self.firstName = googleUser.profile.givenName
        self.middleName = nil
        self.lastName = googleUser.profile.familyName
        self.pictureUrl = googleUser.profile.imageURL(withDimension: 200)
        self.email = googleUser.profile.email
    }
    
    init(twitterUser: TWTRUser) {
        self.fullName = twitterUser.name
        self.firstName = nil
        self.middleName = nil
        self.lastName = nil
        self.pictureUrl = URL(string: twitterUser.profileImageLargeURL)
        self.email = nil
    }
    
    func copy(with zone: NSZone? = nil) -> Any {
        let copy = User(fullName: fullName, firstName: firstName, middleName: middleName, lastName: lastName, pictureUrl: pictureUrl, email: email)
        return copy
    }
    
}
