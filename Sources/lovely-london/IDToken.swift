//
//  IDToken.swift
//  lovely-london
//
//  Created by Kimi on 20/09/2019.
//

import Foundation

public class IDToken {

    private(set) var rawIDToken : String
    
    public init(raw: String) {
        rawIDToken = raw
    }
}
