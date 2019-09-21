//
//  LLTokenValidator.swift
//  lovely-london
//
//  Created by Ezequiel Aceto on 20/09/2019.
//

import Foundation

public class IDTokenVerifier {

    private(set) var signatureVerificator = SignatureVerificator.none
    
    public func set(signatureAlgorithm: SignatureAlgorithm) -> IDTokenVerifier {
        signatureVerificator = SignatureVerificator(with: signatureAlgorithm)
        return self
    }
    
    public func verify(idToken: String,
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

        if let headerError = validate(header: header) {
            onError?(headerError)
            return
        }
                
        onError?(IDTokenVerificationError.unknownError(idToken: idToken, signatureVerificator: signatureVerificator))
    }
}

// Header Verification
extension IDTokenVerifier {
        
    func validate(header: String) -> Error? {
        guard let json = header.asJSONObject() else {
            return IDTokenVerificationError.invalidIDTokenFormat(message: "Expected a JSON a header, got \(header).")
        }

        if case SignatureAlgorithm.none = signatureVerificator.algorithm {
            return nil
        }
        
        guard let alg = json["alg"] as? String else {
            return IDTokenVerificationError.missingRequiredParam(param: "alg", message: "Missing \"alg\" at header, got \(header).")
        }

        guard alg == signatureVerificator.algorithm.name else {
            return IDTokenVerificationError.incorrectAlgorithm(expected: "\(signatureVerificator.algorithm.name)", got: "\(alg)")
        }
         
        return nil
    }
    
}
