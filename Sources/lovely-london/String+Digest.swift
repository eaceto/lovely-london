//
//  String+Digest.swift
//  lovely-london
//
//  Created by Kimi on 24/09/2019.
//

import Foundation
import CommonCrypto

extension String {
    
    func sha256() -> Data? {
        if let stringData = self.data(using: .utf8) {
            return digestSHA256(input: stringData as NSData) as Data
        }
        return nil
    }
    
    func sha384() -> Data? {
        if let stringData = self.data(using: .utf8) {
            return digestSHA384(input: stringData as NSData) as Data
        }
        return nil
    }
    
    func sha512() -> Data? {
        if let stringData = self.data(using: .utf8) {
            return digestSHA512(input: stringData as NSData) as Data
        }
        return nil
    }
    
    private func digestSHA256(input : NSData) -> NSData {
        let digestLength = Int(CC_SHA256_DIGEST_LENGTH)
        var hash = [UInt8](repeating: 0, count: digestLength)
        CC_SHA256(input.bytes, UInt32(input.length), &hash)
        return NSData(bytes: hash, length: digestLength)
    }

    private func digestSHA384(input : NSData) -> NSData {
        let digestLength = Int(CC_SHA384_DIGEST_LENGTH)
        var hash = [UInt8](repeating: 0, count: digestLength)
        CC_SHA384(input.bytes, UInt32(input.length), &hash)
        return NSData(bytes: hash, length: digestLength)
    }
    
    private func digestSHA512(input : NSData) -> NSData {
        let digestLength = Int(CC_SHA512_DIGEST_LENGTH)
        var hash = [UInt8](repeating: 0, count: digestLength)
        CC_SHA512(input.bytes, UInt32(input.length), &hash)
        return NSData(bytes: hash, length: digestLength)
    }
    
    /*
    private  func hexStringFromData(input: NSData) -> String {
        var bytes = [UInt8](repeating: 0, count: input.length)
        input.getBytes(&bytes, length: input.length)
        
        var hexString = ""
        for byte in bytes {
            hexString += String(format:"%02x", UInt8(byte))
        }
        
        return hexString
    }
    */
}
