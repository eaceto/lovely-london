//
//  RSAHelper.swift
//  lovely-london
//
//  Created by Kimi on 24/09/2019.
//

import Foundation
import Security
import CommonCrypto

enum RSAError : Error {
    case couldNotGetData(from: String)
    case couldNotCreateADigest(for: String)
    case invalidBlockSize(for: SecKey, expectedLessThan: Int, got: Int)
    case coldNotEncrypt(string: String, withErrorCode: OSStatus)
}

public class RSAHelper {
    
    public static func publicKey(from encodedPEM: String) -> SecKey? {
        var pem = encodedPEM
        
        // remove the header string
        let pemHeader = String("-----BEGIN PUBLIC KEY-----")
        let pemTail = "-----END PUBLIC KEY-----"
        
        // remove the header string
        if let upperBound = pem.range(of: pemHeader)?.upperBound {
            pem = String(pem[upperBound...])
        }
        
        // remove the tail string
        if let lowerBound = pem.range(of: pemTail)?.lowerBound {
            pem = String(pem[..<lowerBound])
        }
        
        guard let data = Data(base64Encoded: pem, options: [Data.Base64DecodingOptions.ignoreUnknownCharacters]) else {
            return nil
        }

        if #available(iOS 10.0, iOSMac 10.0, OSX 10.0, watchOS 2.0, *) {
            let attrs: [CFString: Any] = [
                kSecAttrKeyType: kSecAttrKeyTypeRSA,
                kSecAttrKeyClass: kSecAttrKeyClassPublic
            ]
            
            var error: Unmanaged<CFError>?
            guard let key = SecKeyCreateWithData(data as CFData, attrs as CFDictionary, &error) else {
                return nil
            }
            return key
        }
        
        fatalError("Unimplemented public key creation under iOS 9 or below")
    }
}
