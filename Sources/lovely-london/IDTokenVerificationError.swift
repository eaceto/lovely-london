//
//  IDTokenVerificationError.swift
//  lovely-london
//
//  Created by Ezequiel Aceto on 20/09/2019.
//

import Foundation

enum IDTokenVerificationError: Error {
    case invalidIDTokenFormat(message: String)
    case missingRequiredParam(param: String, message: String)
    case incorrectTokenType(expected: String, got: String)
    case incorrectAlgorithm(expected: String, got: String)
    case unknownError(idToken: String, signatureVerificator: SignatureVerificator)
}
