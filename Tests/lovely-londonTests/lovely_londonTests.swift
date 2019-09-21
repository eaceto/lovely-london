import XCTest
@testable import lovely_london

final class lovely_londonTests: XCTestCase {
    
    func testSuccessful() {
        let algorithm = SignatureAlgorithm.RS256(publicKey: publicKey)
        
        IDTokenVerifier.verify(idToken: successfulToken,
                               using: SignatureVerificator(with: algorithm),
                               onSucess: { token in
                                XCTAssertTrue(true)
        },
                               onError: { error in
                                debugPrint("\(error)")
                                XCTFail()
        })
    }
    
    func testWrongIDTokenFormat() {
        let algorithm = SignatureAlgorithm.RS256(publicKey: publicKey)
        
        IDTokenVerifier.verify(idToken: "",
                               using: SignatureVerificator(with: algorithm),
                               onSucess: { token in
                                XCTFail()
        },
                               onError: { error in
                                if case IDTokenVerificationError.invalidIDTokenFormat = error {
                                    return
                                }
                                XCTFail()
        })
    }

    var client_id = "g3FuJvQoSYfdzChSBg0BhwnC3tXCv5Nj"
    
    static var allTests = [
        ("testSuccessful", testSuccessful),
        ("testWrongIDTokenFormat", testWrongIDTokenFormat)
    ]
    
    var publicKey = """
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
    
    var successfulToken = "eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiIsImtpZCI6Ik1ERTBNemhCTURFM00wUXdORFUwTmtNMU1FWkJNamN3TkVGR016UkVSa0l4TVRsQ1JESTNRZyJ9.eyJuaWNrbmFtZSI6ImRlbW8iLCJuYW1lIjoiZGVtb0BmbGFtaW5nb2FwcC5jb20iLCJwaWN0dXJlIjoiaHR0cHM6Ly9zLmdyYXZhdGFyLmNvbS9hdmF0YXIvNDI4NDY3M2YwNWY5YWUxYWFjN2JhZjIxYWJiYzY4YjQ_cz00ODAmcj1wZyZkPWh0dHBzJTNBJTJGJTJGY2RuLmF1dGgwLmNvbSUyRmF2YXRhcnMlMkZkZS5wbmciLCJ1cGRhdGVkX2F0IjoiMjAxOS0wOS0yMFQyMjoxMzozNy40MzJaIiwiZW1haWwiOiJkZW1vQGZsYW1pbmdvYXBwLmNvbSIsImVtYWlsX3ZlcmlmaWVkIjpmYWxzZSwiaXNzIjoiaHR0cHM6Ly9mbG1uZ28uYXV0aDAuY29tLyIsInN1YiI6ImF1dGgwfDVkM2ExNTRhODlkNzA2MGRmMmM3OGEzMCIsImF1ZCI6ImczRnVKdlFvU1lmZHpDaFNCZzBCaHduQzN0WEN2NU5qIiwiaWF0IjoxNTY5MDE3NjIwLCJleHAiOjE1NjkwNTM2MjAsImF1dGhfdGltZSI6MTU2OTAxNzYxN30.ac142O2eSzk86b-nSOmeI5NBhMPSx07XgRprhsgxVElmPF6C3-dlQ5gapNtaAGp3YjkzL9jbch4rfDzZLV6jq9Clwl9sa2WzYrMMganf27J60ziIz_O9XLRuxtng815ygQgo1GjDR5y8I_2lD0R2iQ1QeUo2iUZJudvXLXA_ILs0a20AMxESvZKKEno1IkbLcbMenHTZiF6y23u8uTODquEpqsyS1IlSsfdDOHnSDcg6Q981lRXXnqO3spGdT2hNQNNR3OrnDY-GFL_X1Wlc4qkHG6L1lacptITcTrBVZMj5ktxHy_90MHZ5x5K6WW3QXmxZ35IKVxpGaeYoDqq9qQ"
    
}
