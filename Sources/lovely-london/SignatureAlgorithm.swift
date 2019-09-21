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
    
    var description: String {
        switch self {
        case .RS256(let publicKey):
            return "RSA256 public key: \(publicKey)"
        case .RS386(let publicKey):
            return "RSA386 public key: \(publicKey)"
        case .RS512(let publicKey):
            return "RSA512 public key: \(publicKey)"
        }
    }
}
