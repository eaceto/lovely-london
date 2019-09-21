//
//  SignatureAlgorithm.swift
//  lovely-london
//
//  Created by Ezequiel Aceto on 20/09/2019.
//

import Foundation

public enum SignatureAlgorithm {
    case RS256(publicKey: String)
    case RS386(publicKey: String)
    case RS512(publicKey: String)
    case none
    
    var description: String {
        switch self {
        case .RS256(let publicKey),
             .RS386(let publicKey),
             .RS512(let publicKey):
            return "\(self.name) public key: \(publicKey)"
        case .none:
            return "No signature verification"
        }
    }
    
    var name: String {
        switch self {
        case .RS256:
            return "RS256"
        case .RS386:
            return "RS386"
        case .RS512:
            return "RS512"
        case .none:
            return "none"
        }
    }
}
