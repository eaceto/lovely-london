//
//  String+Extensions.swift
//  lovely-london
//
//  Created by Kimi on 20/09/2019.
//
import Foundation

extension String {
 
    func base64Decoded() -> String? {
        guard let data = Data(base64Encoded: self) else { return nil }
        return String(data: data, encoding: .utf8)
    }
}
