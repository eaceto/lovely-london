//
//  Claim.swift
//  lovely-london
//
//  Created by Kimi on 21/09/2019.
//

import Foundation

public enum Claim {

    case issuer(_: String)
    case expiration
    case issueAt
    case notBefore
    case audience(_: String)
    case subject(_: String)
    case authTime
    case custom(claim: String, value: Any)
    
    var name: String {
        switch self {
        case .issuer:
            return StandardClaim.issuer.rawValue
        case .expiration:
            return StandardClaim.expiration.rawValue
        case .issueAt:
            return StandardClaim.issueAt.rawValue
        case .notBefore:
            return StandardClaim.notBefore.rawValue
        case .audience:
            return StandardClaim.audience.rawValue
        case .subject:
            return StandardClaim.subject.rawValue
        case .authTime:
            return StandardClaim.authTime.rawValue
        case .custom(let claim, _):
            return "\(claim)"
        }
    }
    
    var value: Any? {
        switch self {
        case .issuer(let iss):
            return iss
        case .expiration:
            return nil
        case .issueAt:
            return nil
        case .notBefore:
            return nil
        case .audience(let aud):
            return aud
        case .subject(let sub):
            return sub
        case .authTime:
            return nil
        case .custom( _, let value):
            return value
        }
    }
}

enum StandardClaim : String {
    case issuer = "iss"
    case expiration = "exp"
    case issueAt = "iat"
    case notBefore = "nbf"
    case audience = "aud"
    case subject = "sub"
    case authTime = "auth_time"
}
