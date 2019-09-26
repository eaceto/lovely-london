//
//  SignatureAlgorithm.swift
//  lovely-london
//
//  Created by Ezequiel Aceto on 20/09/2019.
//

import Foundation
import CommonCrypto

public enum SignatureAlgorithm {
    case RS256
    case RS384
    case RS512
    case none
    
    static func from(string: String) -> SignatureAlgorithm? {
        switch string {
        case "RS256":
            return .RS256
        case "RS384":
            return .RS384
        case "RS512":
            return .RS512
        default:
            return nil
        }
    }
    
    var description: String {
        switch self {
        case .RS256,
             .RS384,
             .RS512:
            return "\(self.name)"
        case .none:
            return "No signature algorithm defined"
        }
    }
    
    var name: String {
        switch self {
        case .RS256:
            return "RS256"
        case .RS384:
            return "RS384"
        case .RS512:
            return "RS512"
        case .none:
            return "none"
        }
    }
    
    func digestLength() -> Int32 {
        switch self {
        case .RS256:
            return CC_SHA256_DIGEST_LENGTH
        case .RS384:
            return CC_SHA384_DIGEST_LENGTH
        case .RS512:
            return CC_SHA512_DIGEST_LENGTH
        default:
            return CC_SHA1_DIGEST_LENGTH
        }
    }
    
    func digest(string: String) -> Data? {
        switch self {
        case .RS256:
            return string.sha256()
        case .RS384:
            return string.sha384()
        case .RS512:
            return string.sha512()
        default:
            return nil
        }
    }
    
    func padding() -> SecPadding? {
        switch self {
        case .RS256:
            return SecPadding.PKCS1SHA256
        case .RS384:
            return SecPadding.PKCS1SHA384
        case .RS512:
            return SecPadding.PKCS1SHA512
        default:
            return nil
        }
    }

}
