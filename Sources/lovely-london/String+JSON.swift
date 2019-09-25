//
//  String+JSON.swift
//  lovely-london
//
//  Created by Kimi on 24/09/2019.
//

import Foundation

extension String {
    
    func asJSONObject() -> [String : Any]? {
        guard let data = self.data(using: .utf8),
            let json = (try? JSONSerialization.jsonObject(with: data, options: [])) as? [String : Any] else {
                return nil
        }
        return json
    }
    
}
