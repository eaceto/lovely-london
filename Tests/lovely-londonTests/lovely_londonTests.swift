import XCTest
@testable import lovely_london

final class lovely_londonTests: XCTestCase {
        
    func testWrongTokenFormat() {
        let algorithm = SignatureAlgorithm.RS256(publicKey: publicKey)
        let verifier = IDTokenVerifier().set(signatureAlgorithm: algorithm)
        
        verifier.verify(idToken: "",
                        onSucess: { token in XCTFail() },
                        onError: { error in
                            if case IDTokenVerificationError.invalidIDTokenFormat = error {
                                return
                                
                            }
                            XCTFail()
        })
    }
    
    func testWrongAlgorithm() {
        let algorithm = SignatureAlgorithm.RS256(publicKey: publicKey)
        let verifier = IDTokenVerifier().set(signatureAlgorithm: algorithm)
                
        verifier.verify(idToken: wrongAlgorithmJWT,
                        onSucess: { token in XCTFail() },
                        onError: { error in
                            if case IDTokenVerificationError.incorrectAlgorithm = error {
                                return
                            }
                            XCTFail()
        })
    }
    
    static var allTests = [
        ("testWrongTokenFormat", testWrongTokenFormat),
        ("testWrongAlgorithm", testWrongAlgorithm)
    ]
    
    var publicKey =
    """
        -----BEGIN PUBLIC KEY-----
        MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAnzyis1ZjfNB0bBgKFMSv
        vkTtwlvBsaJq7S5wA+kzeVOVpVWwkWdVha4s38XM/pa/yr47av7+z3VTmvDRyAHc
        aT92whREFpLv9cj5lTeJSibyr/Mrm/YtjCZVWgaOYIhwrXwKLqPr/11inWsAkfIy
        tvHWTxZYEcXLgAXFuUuaS3uF9gEiNQwzGTU1v0FqkqTBr4B8nW3HCN47XUu0t8Y0
        e+lf4s4OxQawWD79J9/5d3Ry0vbV3Am1FtGJiJvOwRsIfVChDpYStTcHTCMqtvWb
        V6L11BWkpzGXSW4Hv43qa+GSYOD2QU68Mb59oSk2OB+BtOLpJofmbGEGgvmwyCI9
        MwIDAQAB
        -----END PUBLIC KEY-----
    """
    
    var wrongAlgorithmJWT = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6IkpvaG4gRG9lIiwiaWF0IjoxNTE2MjM5MDIyfQ.SflKxwRJSMeKKF2QT4fwpMeJf36POk6yJV_adQssw5c"
    
    var wrongTokenTypeJWT = "eyJhbGciOiJSUzI1NiIsInR5cCI6Ildyb25nSldUIn0.eyJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6IkpvaG4gRG9lIiwiaWF0IjoxNTE2MjM5MDIyfQ.CSEheCRicRpYTYhqi4cNhJJPhpANwUnyN581T-4MKRE_4ctzlrl0k7kqY1sYofpxrF22KfjNZymQuLGegY77prj65jlEgOLJo5nSy3tQBv8VfZJMN2723wRM0_YZWOSJcZdN9yD_b8_1PpxKy9a8mw8pDbDOXlHzO8aoOVj4F0tl7oUN4YYlfZgntVp9AxgQQITAnXN41tKfMluIAIdlI95mIjYsJoE48XoCXLcdfaXAyifjGS-SxY1YNuQ8tKnyXioUaxG3KujtZBBPw-vP6D6cqzLNTLQ9o0u4cgz5NMp0XWnKdrhp5f_Khgsx7wIswtnoDJGa3RnIBi52MxV9zw"
    
  
    
}
