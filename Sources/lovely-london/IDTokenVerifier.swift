//
//  LLTokenValidator.swift
//  lovely-london
//
//  Created by Ezequiel Aceto on 20/09/2019.
//

import Foundation

public class IDTokenVerifier {

    public static func verify(idToken: String,
                              using signatureVerificator: SignatureVerificator,
                              onSucess: ((IDToken)->Void)?,
                              onError: ((Error)->Void)?) {
        
        let tokenParts = idToken.components(separatedBy: ".")
        
        guard tokenParts.count == 3 else {
            let error = IDTokenVerificationError.invalidIDTokenFormat(message: "ID Token must have 3 parts (header, payload and signature), got \(tokenParts.count)")
            onError?(error)
            return
        }
        
        guard let header = tokenParts[0].base64URLDecoded() else {
            let error = IDTokenVerificationError.invalidIDTokenFormat(message: "Invalid ID Token header. Could not decode from Base64")
            onError?(error)
            return
        }

        if let headerError = IDTokenVerifier.validate(header: header, with: signatureVerificator.algorithm) {
            onError?(headerError)
            return
        }
        
        
        onError?(IDTokenVerificationError.unknownError(idToken: idToken, signatureVerificator: signatureVerificator))
    }
}

// Header Verification
extension IDTokenVerifier {
        
    internal static func validate(header: String, with algorithm: SignatureAlgorithm) -> Error? {
        guard let json = header.asJSONObject() else {
            return IDTokenVerificationError.invalidIDTokenFormat(message: "Expected a JSON a header, got \(header).")
        }

        guard let alg = json["alg"] as? String else {
            return IDTokenVerificationError.missingRequiredParam(param: "alg", message: "Missing \"alg\" at header, got \(header).")
        }

        guard alg == algorithm.name else {
            return IDTokenVerificationError.incorrectAlgorithm(expected: "\(algorithm.name)", got: "\(alg)")
        }
         
        return nil
    }
    
}
