//
//  IDToken.swift
//  lovely-london
//
//  Created by Kimi on 20/09/2019.
//

import Foundation

public class IDToken {

    private(set) var rawIDToken: String
    private(set) var header: [String:Any]
    private(set) var payload: [String:Any]
    
    public init(raw: String, header: [String:Any], payload: [String:Any]) {
        self.rawIDToken = raw
        self.header = header
        self.payload = payload
    }
}
