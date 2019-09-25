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
    case incorrectAlgorithm(expected: String, got: String)
    case missingRequiredClaim(claim: String, payload: String)
    case missingConfiguration(claim: String, message: String)
    case incorrentRequiredClaim(claim: String, expected: String, got: String)
    case tokenExpired(expiration: Date)
    case issueAtInTheFuture(issueAt: Date)
    case tokenCannotBeUsedBefore(notBefore: Date)
    case unknownError(idToken: String, signatureVerificator: SignatureVerificator)
}
