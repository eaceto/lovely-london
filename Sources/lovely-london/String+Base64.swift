//
//  String+Extensions.swift
//  lovely-london
//
//  Created by Kimi on 20/09/2019.
//
import Foundation

extension String {
 
    func base64URLDecoded() -> String? {
        guard let data = Data(base64Encoded: self.base64FromBase64URL()) else { return nil }
        return String(data: data, encoding: .utf8)
    }
    
    func base64FromBase64URL() -> String {
        let decoded = self.replacingOccurrences(of: "-", with: "+").replacingOccurrences(of: "_", with: "/")
        let padding = String(repeating: "=", count: decoded.count % 4)
        return "\(decoded)\(padding)"
    }
    
    func base64Encoded() -> String? {
        return self.data(using: .utf8)?.base64EncodedString()
    }
    
}
