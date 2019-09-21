//
//  LLTokenValidator.swift
//  lovely-london
//
//  Created by Ezequiel Aceto on 20/09/2019.
//

import Foundation

class IDTokenVerifier {

    
    public static func verify(idToken: String,
                              using signatureVerificator: SignatureVerificator,
                              onSucess: ((IDToken)->Void)?,
                              onError: ((Error)->Void)?) {
        
        let tokenParts = idToken.split(separator: ".")
        
        guard tokenParts.count == 3 else {
            let error = IDTokenVerificationError.invalidIDTokenFormat(message: "ID Token must have 3 parts (header, payload and signature), got \(tokenParts.count)")
            onError?(error)
            return
        }
        
        guard let header = String(tokenParts[0]).base64Decoded() else {
            let error = IDTokenVerificationError.invalidIDTokenFormat(message: "Invalid ID Token header. Could not decode from Base64")
            onError?(error)
            return
        }

        guard let payload = String(tokenParts[1]).base64Decoded() else {
                let error = IDTokenVerificationError.invalidIDTokenFormat(message: "Invalid ID Token payload. Could not decode from Base64")
                onError?(error)
                return
        }

        guard let signature = String(tokenParts[2]).base64Decoded() else {
                let error = IDTokenVerificationError.invalidIDTokenFormat(message: "Invalid ID Token signature. Could not decode from Base64")
                onError?(error)
                return
        }

        if !signatureVerificator.matches(header: header) {
            let error = IDTokenVerificationError.incorrectAlgorithm(message: "Expected signature algorithm: \(signatureVerificator.algorithm), got header \(header)")
            onError?(error)
            return
        }
        
        
        onError?(IDTokenVerificationError.unknownError(idToken: idToken, signatureVerificator: signatureVerificator))
    }
}
