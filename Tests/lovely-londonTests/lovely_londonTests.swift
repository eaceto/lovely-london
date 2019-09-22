import XCTest
@testable import lovely_london

final class lovely_londonTests: XCTestCase {
        
    func testWrongTokenFormat() {
        let algorithm = SignatureAlgorithm.RS256(publicKey: publicKey)
        let verifier = IDTokenVerifier().set(signatureAlgorithm: algorithm)
        
        verifier.verify(idToken: "",
                        onSuccess: { token in XCTFail() },
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
                        onSuccess: { token in XCTFail() },
                        onError: { error in
                            if case IDTokenVerificationError.incorrectAlgorithm = error {
                                return
                            }
                            XCTFail()
        })
    }
    
    func testMissingIssuer() {
        let algorithm = SignatureAlgorithm.RS256(publicKey: publicKey)
        let verifier = IDTokenVerifier()
            .set(signatureAlgorithm: algorithm)
            .require(claim: .issuer("auth0"))
                
        verifier.verify(idToken: missingIssuerJWT,
                        onSuccess: { token in XCTFail() },
                        onError: { error in
                            if case IDTokenVerificationError.missingRequiredClaim(claim: let claim, payload: _) = error,
                                claim == StandardClaim.issuer.rawValue {
                                return
                            }
                            XCTFail()
        })
    }
    
    func testIncorrectIssuer() {
        let algorithm = SignatureAlgorithm.RS256(publicKey: publicKey)
        let verifier = IDTokenVerifier()
            .set(signatureAlgorithm: algorithm)
            .require(claim: .issuer("auth1"))
                
        verifier.verify(idToken: incorrectIssuerJWT,
                        onSuccess: { token in XCTFail() },
                        onError: { error in
                            if case IDTokenVerificationError.incorrentRequiredClaim(claim: let claim, expected: _, got: _) = error,
                                claim == StandardClaim.issuer.rawValue {
                                return
                            }
                            XCTFail()
        })
    }
       
    func testExpiredToken() {
        let algorithm = SignatureAlgorithm.RS256(publicKey: publicKey)
                let verifier = IDTokenVerifier()
            .set(signatureAlgorithm: algorithm)
            .require(claim: .issuer("auth0"))
                
        verifier.verify(idToken: expiredJWT,
                        onSuccess: { token in XCTFail() },
                        onError: { error in
                            if case IDTokenVerificationError.tokenExpired(expiration: _) = error {
                                return
                            }
                            XCTFail()
        })
    }
    
    func testTokenIssueAtInTheFuture() {
        let algorithm = SignatureAlgorithm.RS256(publicKey: publicKey)
                let verifier = IDTokenVerifier()
            .set(signatureAlgorithm: algorithm)
            .require(claim: .issuer("auth0"))
                
        verifier.verify(idToken: incorrectIssueAtJWT,
                        onSuccess: { token in XCTFail() },
                        onError: { error in
                            if case IDTokenVerificationError.issueAtInTheFuture(issueAt: _) = error {
                                return
                            }
                            XCTFail()
        })
    }
    
    func testTokenUseNotBefore() {
        let algorithm = SignatureAlgorithm.RS256(publicKey: publicKey)
                let verifier = IDTokenVerifier()
            .set(signatureAlgorithm: algorithm)
            .require(claim: .issuer("auth0"))
                
        verifier.verify(idToken: incorrectNotBeforeJWT,
                        onSuccess: { token in XCTFail() },
                        onError: { error in
                            if case IDTokenVerificationError.tokenCannotBeUsedBefore(notBefore: _) = error {
                                return
                            }
                            XCTFail()
        })
    }
    
    func testStandardToken() {
        let algorithm = SignatureAlgorithm.RS256(publicKey: publicKey)
        let verifier = IDTokenVerifier()
            .set(signatureAlgorithm: algorithm)
            .require(claim: .issuer("auth0"))
            .allowClockDifference(in: 5.0) // 5 seconds of clock difference for exp, iat and nbf
                
        verifier.verify(idToken: validStandardJWT,
                        onSuccess: { _ in },
                        onError: { error in
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
    
    var missingIssuerJWT = "eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9.eyJleHAiOjE2OTYyMzkwMjIsImlhdCI6MTUxNjIzOTAyMn0.fG7qofL7or-0uZlz6eL2nOYDovSiK3tg826RBaVDnVJp2kpCPdVi_xRHIyTjhyFhLHxmNnVLbCUYM0tsZOvGjb1Sx3McGe85oCxj9AB_--1GUBsPxNcLU-L-lsm4ncY2qUqncdxTvSj0b1fUPKdfbsVHKeA59lItmC8cPcjWPEyIHJBUCV2b6rJqtSBYNiFGwv-M0jOmhC9Oj08a8pXuIsvT9VwkUCgqDyDOK8VNED9DaJiluWfi-gcc2U6Gxr3sfrs9GTeCWmsgUq4F9QFGHz7SDoDTfqDeW8yrD5HlXT48IdC8Jp1TdEBWchG4yDbHJRoLxw3AjFAc2pUvVmlNVA"
    
    var incorrectIssuerJWT = "eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9.eyJleHAiOjE2OTYyMzkwMjIsImlhdCI6MTUxNjIzOTAyMiwiaXNzIjoiYXV0aDAifQ.aRONbG0uTTJGsy2qNZdcorJsGcEidgsBwurIvCi2_KZcetH4hugjD0roG3yMsI3ShMA73d9hPstAFDJmv02T6JJ6lm_Qw2gG8ZhnI9xRfDYfW4FmGk_1eiG-Mj47FN2qhT4OFsSK7K1zUYhBwUv1d5-PPFPE2pRH2w83u7SVQta47ZL80x8t2m_EBP3CFG-jlXlpZ8XhPfA5rfGEAsD1imjqlRM0WJE892J7bjJUl5SGrBmFhYKJhdFCENJi_cD21tBAsbqzkadiknWIla7jhPssTMlSAHoUQQet5c8NBi3Mrd8kslQEv8-YwigXWVdfDEhmvmm2TWFKvq-z8DWM4A"
        
    var expiredJWT = "eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9.eyJleHAiOjE1MTYyMzkwMjIsImlhdCI6MTUxNjIzOTAyMiwiaXNzIjoiYXV0aDAifQ.OAwRtg8H1P9z5KpWWAOTAi7FGdvmoh6hnhcP7wn2hXcynprJtY4O6AI4fP4-Oli-Sgp-2LdEoL7UwEpOGv7I3pmiMuMVK0jQet19ueM7A0srQL3KM4CVBZX7f3wE6ZJdB_9N0ZpFO1HZofFQIJMfpcpNpRFh8cESdr-Emy61hWaN4DrBKf1oAZ7VMLwspuLl8XnnFWTmbHa7uEiBaJLBbRT_u1-nMR78P7IWbvUoBWeJPLmKsG7BUAhkD5gET8TfNNvwLNSIHKvCuKmDdO1LTd7_sAszwrkGAaj_Zw42GPrDyWak3SQM3Spvhv-Yl0LquDLUNDQd0RSuZ2bkF3i4WQ"
    
    var incorrectIssueAtJWT = "eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9.eyJleHAiOjE2OTYyMzkwMjIsImlhdCI6MTYwNjIzOTAyMiwiaXNzIjoiYXV0aDAifQ.gDeZtJfQrrK48wP6nuqNznDoXS9eObmWf4ygQ2R6j3HmvrImioEfI7iF01xyHHHdAivwZowQ3ZYIE7hWDhqIAqNMKXmxEsC2vGvuegrdfNW44McjQVj4xROghebkiQTmvQ7Y0ZuXKtUqSyikzylTis4YjAcTaBiX8wPkxiGxoZ2_duZydgboF4hGjCMJyd6i03TxA8V5psmm8b9yfWy35D8_QTikiZPSW4yAR-0A57YA0cRE2V3HW3iJmANJrkZ8McNj--HyGgOh_v6Aw_5Y1nuJft-ZOY_jNYb2-FO-UpKAaCIBmDCSFwXBQNrdG9WcDtRJfmscks0ehh3cO2KERw"
    
    var incorrectNotBeforeJWT = "eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9.eyJleHAiOjE2OTYyMzkwMjIsIm5iZiI6MTYwNjIzOTAyMiwiaWF0IjoxNTA2MjM5MDIyLCJpc3MiOiJhdXRoMCJ9.heNbqPo-I0z_zaDSh3hMGiIVl6GgNi_kM5OjcSesEXS9gMEk3X7Cg-OPVJqknSVAt8U9ZLyNtxsyQBpEBoJr4xe0weMPNxHBBMH-e7YipvGQ3_9Bz6khLh5qiLvLbPZxq5OTI_A_f86XKNHN_8Vqh_S7mKYnx_CNMdIxbHVspZhmfiCfGo_ZgP5OpKvjtSyXfTnhdq1g_oCGgYmuPjpLAKPqsACRpuXzoIxHf-osq-6QRGCzXIFLYW57aR-g3Iwz1It2FNYPXkHru7nIdYkRT5hqkqcw8H3kPRNoj0ejbYGS-slnWqYyp1fPh34qmV5otEUNJdDSEfoPc9uqAbE1sg"
    
    var validStandardJWT = "eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9.eyJleHAiOjE2OTYyMzkwMjIsIm5iZiI6MTUwNjIzOTAyMiwiaWF0IjoxNTA2MjM5MDIyLCJpc3MiOiJhdXRoMCJ9.ihZBS394KmeZkqLeo7FCdxbmlpiS4xAdoaIGYLmUbrdjbctOXRIHQYt2eA8EV3GSWtMcpLFXZmMiqvzE5QRA86L0ath5e75qM957BFVsiL6BIkL5Bnxl-I9tL_FYhxb3oUwstPPjCuftF02fYAktz71IQ2cRsPPmxRXiUP9W5Rnfez_gdoE1iHRtf7FloBU7Oa_jeNdJz0i4znPCUkXviscomFrSqeuclWDyFT0vP-QYEb5-_wS00DM8JYrBNah-WXMjXngZZplikn3oS8vKSx4n77nAWygwwD80DZEgCVzO_R2tcinCoZeXoe_pJE5S8h80z-5GKGf3xdTrd7z3-g"

}
