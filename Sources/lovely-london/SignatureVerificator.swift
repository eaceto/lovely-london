//
//  SignatureVerificator.swift
//  lovely-london
//
//  Created by Ezequiel Aceto on 20/09/2019.
//

import Foundation



public class SignatureVerificator {
    
    public static let none = SignatureVerificator(with: .none)
    
    private(set) var algorithm: SignatureAlgorithm
    
    init(with algorithm: SignatureAlgorithm) {
        self.algorithm = algorithm
    }
    
}
