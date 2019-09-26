//
//  LLTokenValidator.swift
//  lovely-london
//
//  Created by Ezequiel Aceto on 20/09/2019.
//

import Foundation

public class IDTokenVerifier {

    private(set) var signatureVerificator = SignatureVerificator.none
    private(set) var leeway : TimeInterval = 0.0
    
    public init() {}
    
    private var requiredClaims : [String:Claim] = {
        var claims = [String:Claim]()
        
        // Expiration is always a required claim
        claims[StandardClaim.expiration.rawValue] = Claim.expiration
        
        return claims
    }()

    public func set(signatureAlgorithm: SignatureAlgorithm, and publicKey: String) -> IDTokenVerifier {
        signatureVerificator = SignatureVerificator(with: signatureAlgorithm, publicKey: publicKey)
        return self
    }
    
    public func set(signatureAlgorithm: SignatureAlgorithm, and secKey: SecKey) -> IDTokenVerifier {
        signatureVerificator = SignatureVerificator(with: signatureAlgorithm, secKey: secKey)
        return self
    }
    
    public func set(signatureAlgorithm: SignatureAlgorithm) -> IDTokenVerifier {
        signatureVerificator = SignatureVerificator(with: signatureAlgorithm)
        return self
    }
    
    public func require(claims: [Claim]) -> IDTokenVerifier {
        self.requiredClaims = claims.reduce(into: [:], { result, claim in
            result[claim.name] = claim
        })
        return self
    }
    
    public func require(claim: Claim) -> IDTokenVerifier {
        self.requiredClaims[claim.name] = claim
        return self
    }
    
    public func allowClockDifference(in seconds: TimeInterval) -> IDTokenVerifier {
        self.leeway = seconds
        return self
    }
    
    public func verify(idToken: String,
                       onSuccess: ((IDToken)->Void)?,
                       onError: ((Error)->Void)?) {
        
        let tokenParts = idToken.components(separatedBy: ".")
        
        guard tokenParts.count == 3 else {
            let error = IDTokenVerificationError.invalidIDTokenFormat(message: "ID Token must have 3 parts (header, payload and signature), got \(tokenParts.count)")
            onError?(error)
            return
        }
        
        // Validate Header
        guard let header = tokenParts[0].base64URLDecoded() else {
            let error = IDTokenVerificationError.invalidIDTokenFormat(message: "Invalid ID Token header. Could not decode from Base64URL")
            onError?(error)
            return
        }
        guard let headerJSON = header.asJSONObject() else {
            onError?(IDTokenVerificationError.invalidIDTokenFormat(message: "Expected a JSON as header, got \(header)."))
            return
        }
        if let headerError = validate(header: header, with: headerJSON) {
            onError?(headerError)
            return
        }

        // Validate Payload.
        guard let payload = tokenParts[1].base64URLDecoded() else {
            let error = IDTokenVerificationError.invalidIDTokenFormat(message: "Invalid ID Token payload. Could not decode from Base64URL")
            onError?(error)
            return
        }
        guard let payloadJSON = payload.asJSONObject() else {
            onError?(IDTokenVerificationError.invalidIDTokenFormat(message: "Expected a JSON as payload, got \(payload)."))
            return
        }
        if let payloadError = validate(payload: payload, with: payloadJSON) {
            onError?(payloadError)
            return
        }
        
        // Validate Signature
        guard case SignatureAlgorithm.none = signatureVerificator.algorithm else {
            let tokenSignature = tokenParts[2].base64FromBase64URL()
            if let signatureError = signatureVerificator.verify(header: tokenParts[0], and: tokenParts[1], with: tokenSignature) {
                onError?(signatureError)
            }
            return
        }
              
        onSuccess?(IDToken(raw: idToken, header: headerJSON, payload: payloadJSON))
    }
}

// Header Verification
extension IDTokenVerifier {
        
    func validate(header: String, with json: [String:Any]) -> Error? {
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

// Payload Verification
extension IDTokenVerifier {
    
    func validate(payload: String, with json: [String:Any]) -> Error? {
        if let error = verifyIssuer(in: payload, with: json) {
            return error
        }
        
        if let error = verifyExpiration(in: payload, with: json) {
            return error
        }
        
        if let iat = json[StandardClaim.issueAt.rawValue] as? TimeInterval, let error = verifyIssueAt(date: iat) {
            return error
        }

        if let nbf = json[StandardClaim.notBefore.rawValue] as? TimeInterval, let error = verifyNotBefore(date: nbf) {
            return error
        }
        
        return nil
    }
    
    func verifyIssuer(in payload: String, with json: [String:Any]) -> Error? {
        let issuerClaimName = StandardClaim.issuer.rawValue
        
        guard let verifierIssuer = requiredClaims[issuerClaimName],
             let verifierisIssuerValue = verifierIssuer.value as? String else {
             return IDTokenVerificationError.missingConfiguration(claim: issuerClaimName, message:"Missing \"issuer\" in required claims. Call \"require(Claim.issuer(<< your expected issuer>>)\" on your IDTokenVerifier object. ")
        }
        
        guard let tokenIssuerValue = json[issuerClaimName] as? String else {
            return IDTokenVerificationError.missingRequiredClaim(claim: issuerClaimName, payload: payload)
        }
        
        guard verifierisIssuerValue == tokenIssuerValue else {
            return IDTokenVerificationError.incorrentRequiredClaim(claim: issuerClaimName, expected: verifierisIssuerValue, got: tokenIssuerValue)
        }
        
        return nil
    }
    
    func verifyExpiration(in payload: String, with json: [String:Any]) -> Error? {
        let expClaimName = StandardClaim.expiration.rawValue
        
        guard let tokenExpValue = json[expClaimName] as? TimeInterval else {
            return IDTokenVerificationError.missingRequiredClaim(claim: expClaimName, payload: payload)
        }
                
        let checkpoint = Date().timeIntervalSince1970
        
        if tokenExpValue + leeway < checkpoint {
            return IDTokenVerificationError.tokenExpired(expiration: Date(timeIntervalSince1970: tokenExpValue))
        }
        
        return nil
    }
    
    func verifyIssueAt(date iat: TimeInterval) -> Error? {
        let now = Date().timeIntervalSince1970
        
        return  (iat > now + leeway) ? IDTokenVerificationError.issueAtInTheFuture(issueAt: Date(timeIntervalSince1970: iat)) : nil
    }
    
    func verifyNotBefore(date nbf: TimeInterval) -> Error? {
        let now = Date().timeIntervalSince1970
        
        return  (nbf > now + leeway) ? IDTokenVerificationError.tokenCannotBeUsedBefore(notBefore: Date(timeIntervalSince1970: nbf)) : nil
    }
    
}
