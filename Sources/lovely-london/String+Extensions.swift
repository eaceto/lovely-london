//
//  String+Extensions.swift
//  lovely-london
//
//  Created by Kimi on 20/09/2019.
//
import Foundation

extension String {
 
    func base64URLDecoded() -> String? {
        var mutableSelf = self.replacingOccurrences(of: "-", with: "+").replacingOccurrences(of: "_", with: "/")
        let numberOfEqualsToAdd = mutableSelf.lengthOfBytes(using: .utf8) % 4
        if numberOfEqualsToAdd > 0 {
            for _ in 0..<numberOfEqualsToAdd {
                mutableSelf.append(contentsOf: "=")
            }
        }

        guard let data = Data(base64Encoded: mutableSelf) else { return nil }
        return String(data: data, encoding: .utf8)
    }
    
    func asJSONObject() -> [String : Any]? {
        guard let data = self.data(using: .utf8),
            let json = (try? JSONSerialization.jsonObject(with: data, options: [])) as? [String : Any] else {
            return nil
        }
        return json
    }
}
