//
//  IDTokenVerificationError.swift
//  lovely-london
//
//  Created by Ezequiel Aceto on 20/09/2019.
//

import Foundation

enum IDTokenVerificationError: Error {
    case invalidIDTokenFormat(message: String)
    case incorrectAlgorithm(message: String)
    case unknownError(idToken: String, signatureVerificator: SignatureVerificator)
}
