//
//  SignatureVerificator.swift
//  lovely-london
//
//  Created by Ezequiel Aceto on 20/09/2019.
//

import Foundation
import CommonCrypto


enum SignatureVerificationError : Error {
    case undefinedAlgorithm
    case missingPublicKey
    case missingAlgorithmPadding
    case couldNotGetUTF8Data(from: String)
    case couldNotComputeDigest(for: String)
    case unableToVerifyDataWithPublicKey
}

public class SignatureVerificator {
    
    public static let none = SignatureVerificator(with: .none, publicKey: nil)
    
    private(set) var algorithm: SignatureAlgorithm
    private(set) var publicKey: SecKey?
    
    
    init(with algorithm: SignatureAlgorithm, publicKey pubKey: String?) {
        self.algorithm = algorithm
        if let pubKey = pubKey {
            self.publicKey = RSAHelper.publicKey(from: pubKey)
        }
    }
    
    func verify(header: String, and payload: String, with tokenSignature: String) -> Error? {
        if case SignatureAlgorithm.none = algorithm {
            return SignatureVerificationError.undefinedAlgorithm
        }
        guard let publicKey = publicKey else {
            return SignatureVerificationError.missingPublicKey
        }
        guard let padding = algorithm.padding() else {
            return SignatureVerificationError.missingAlgorithmPadding
        }
        guard let tokenSignatureData = Data(base64Encoded: tokenSignature) else {
            return SignatureVerificationError.couldNotGetUTF8Data(from: tokenSignature)
        }
        
        let dataToVerify = "\(header).\(payload)"
        guard let hashedData = algorithm.digest(string: dataToVerify) else {
            return SignatureVerificationError.couldNotComputeDigest(for: dataToVerify)
        }

        
        if verify(hashedData: hashedData, signature: tokenSignatureData, with: publicKey, and: padding) {
            return nil
        }
        
        return SignatureVerificationError.unableToVerifyDataWithPublicKey
    }
    
    public func verify(hashedData: Data, signature: Data, with key: SecKey, and padding: SecPadding) -> Bool {
        let result = signature.withUnsafeBytes { signatureRawPointer in
            hashedData.withUnsafeBytes { signedHashRawPointer in
                SecKeyRawVerify(
                    key,
                    padding,
                    signedHashRawPointer,
                    hashedData.count,
                    signatureRawPointer,
                    signature.count
                )
            }
        }
        
        switch result {
        case errSecSuccess:
            return true
        default:
            return false
        }
    }
    
}
