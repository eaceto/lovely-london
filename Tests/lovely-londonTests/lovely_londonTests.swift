import XCTest
@testable import lovely_london

final class lovely_londonTests: XCTestCase {
    
    func testWrongTokenFormat() {
        let algorithm = SignatureAlgorithm.RS256
        let verifier = IDTokenVerifier().set(signatureAlgorithm: algorithm, and: publicKey)
        
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
        let algorithm = SignatureAlgorithm.RS256
        let verifier = IDTokenVerifier().set(signatureAlgorithm: algorithm, and: publicKey)
        
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
        let algorithm = SignatureAlgorithm.RS256
        let verifier = IDTokenVerifier()
            .set(signatureAlgorithm: algorithm, and: publicKey)
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
        let algorithm = SignatureAlgorithm.RS256
        let verifier = IDTokenVerifier()
            .set(signatureAlgorithm: algorithm, and: publicKey)
            .require(claim: .issuer("auth1"))
        
        verifier.verify(idToken: incorrectIssuerJWT,
                        onSuccess: { token in XCTFail() },
                        onError: { error in
                            if case IDTokenVerificationError.incorrentRequiredClaim(claim: let claim,
                                                                                    expected: let expectedValue,
                                                                                    got: let tokenValue) = error,
                                claim == StandardClaim.issuer.rawValue {
                                
                                debugPrint("An error ocurred while verifying the token at claim:\(claim). Expected value \(expectedValue), got: \(tokenValue)")
                                
                                return
                            }
                            XCTFail()
        })
    }
    
    func testExpiredToken() {
        let algorithm = SignatureAlgorithm.RS256
        let verifier = IDTokenVerifier()
            .set(signatureAlgorithm: algorithm, and: publicKey)
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
        let algorithm = SignatureAlgorithm.RS256
        let verifier = IDTokenVerifier()
            .set(signatureAlgorithm: algorithm, and: publicKey)
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
        let algorithm = SignatureAlgorithm.RS256
        let verifier = IDTokenVerifier()
            .set(signatureAlgorithm: algorithm, and: publicKey)
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
        let algorithm = SignatureAlgorithm.RS256
        let verifier = IDTokenVerifier()
            .set(signatureAlgorithm: algorithm, and: publicKey)
            .require(claim: .issuer("auth1"))
            .allowClockDifference(in: 5.0) // 5 seconds of clock difference for exp, iat and nbf
 
        verifier.verify(idToken: validStandardJWT,
                        onSuccess: { _ in },
                        onError: { error in
                            debugPrint("\(error)")
                            XCTFail()
        })
    }
    
    func testSignatureUsingRSA256() {
        let expectedSignature = "HEOXslXVh5EcpK_PvmI-ODhK8bwLu-w4t5CFWASCYiQV59HXFZUm3PGCCN2Jj7l1QmNmEgcht25E5ltOBDnpTADov8uUf-B9EhDb8X7A4x9t532pbCUPPNjfmQ3yviqsPbP7tcyDiUmDCgPylK-XTQukwKN2z0EzcdsdLIl-xhgzIbNelGnF_M3fT8aIN955Y8UL_FXdGtic9EHwTobSzv_zzrKb-jHQgEPbctyMBcttGpofU916g3GtoYt3C_c7K_M3l6nSNf0flBJ3RrLxb6nyB6_C9CfcTmbZin2I_1pLTLefmMGISWMVIgmoqrWSLIx1HEotJFoB7IamjI_bKVQoIHgZyNm0P_grVLHxMqHXhMLMFWG-SlFNpeVB2xbQdzcbA3Vjbod5XosHB0EvAGK6KQ7HcD1Gvjh6rnYewl3nAEXO0eTHJ5Cyv50R3aFHusP4YPKV5rH4rzqslXtCuOlr_Vg-CEprU_HoEitI4rUDydnWWjMiR3NyGS7egOxmDDrtx3HAQDbCTZI6rOX631onyJarTf3PnqXHg1CBLAGJOUFzp_sw_jNE1J0zIz1Aavtco72BE14nGM3dTvA3t_3cLzYm_QZmsP3AJR2t9HbYE4Zn1negb4gOKWimgdQQOiz92GwNwTyjlW5Yv5s-e6VR9MwZEAzhD6hofYvBe1o"
        let header = "eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9"
        let payload = "eyJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6IkpvaG4gRG9lIiwiYWRtaW4iOnRydWUsImlhdCI6MTUxNjIzOTAyMn0"
        
        let algorithm = SignatureAlgorithm.RS256
        let signatureVerificator = SignatureVerificator(with: algorithm, publicKey: publicKey)
        
        let decodedSignature = expectedSignature.base64FromBase64URL()
        if let error = signatureVerificator.verify(header: header, and: payload, with: decodedSignature) {
            XCTFail("Error verifying signature: \(error)")
        }
    }
    
    func testAnotherSignatureUsingRSA256() {
        let expectedSignature = "hpDyiQcA49GIkEzdixDEIdpq5HFy9A4__DgBGosi7w0pz12s6N1HftFY9kfu5aR337viWzsWW6gCMGrlvwv03_DNMpNNnnFf-b1TUcf_NnMRlVN3rKEl1V_6FOaP5C90p2iaOEK3BrPVrerEzPOa9Tux6sZnHobzvu3vYoc7li9WgI-YjwKEAP4LNj5fcpVPnvg1X4OfqkCXVVsdQs-7TqlurIgJ7h4omKYX0TQ0Dq-JrN1a0cKyYUYoyFGyzHKsCUYkqPDDDGAlM-vXkZalEJcFibJKIxXI2Xz6z9WVnbk5pEPjogo-J5kYp_C9ChL-f3M_7QDQ68GCK53lxgDThrexHP8ybFfclCT_WMUDrx3tmZ151o3yA1TJtxj_pdZSPb3lcOo8P4SEJDMlJhN9Be7J6Om1lNaUFQtCEppaBAoJqiqvUo9zQ3XM3pp1UeviFmCrgfvRCyzSxGW8uKvj4i2_rmlKth5UEh8qS-cR8mdaB949q67ux3z9uIH8QW1AhSHPdNOYBbi7sqKHQsiWphh9ykkMFtYlhtK3VHBMAZc_sbBXH1gDlh7mTu6F0Zc9KyYOEJN7ZfNsx98yS2p2TIrnswB6IFYNwuOpUiBXhuSf5LRMMLEN2K-jA2andwzaxk7s-AeuUeLSCUHSg6ib5iJiCYt5JGSLE9WNvZkO1sE"
        let header = "eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9"
        let payload = "eyJleHAiOjE2OTYyMzkwMjIsIm5iZiI6MTUwNjIzOTAyMiwiaWF0IjoxNTA2MjM5MDIyLCJpc3MiOiJhdXRoMSJ9"
        
        let algorithm = SignatureAlgorithm.RS256
        let signatureVerificator = SignatureVerificator(with: algorithm, publicKey: publicKey)
        
        let decodedSignature = expectedSignature.base64FromBase64URL()
        if let error = signatureVerificator.verify(header: header, and: payload, with: decodedSignature) {
            XCTFail("Error verifying signature: \(error)")
        }
    }
    
    static var allTests = [
        ("testWrongTokenFormat", testWrongTokenFormat),
        ("testWrongAlgorithm", testWrongAlgorithm)
    ]
    
    var publicKey = """
-----BEGIN PUBLIC KEY-----
MIICIjANBgkqhkiG9w0BAQEFAAOCAg8AMIICCgKCAgEAryq4CgGDuLsCL5uut/A/
OwoejtS4ILYkFFZUv8sOFXqDUvwboneUFbEtJ17pSufb4nwxBpGtVkH2jJGP54k1
tVHruhKyhx60IpYj5/xQI3/Y2SwTCqymC81cQ4RSejMEdjPUVCZYoRIU6cZ+928q
bKC3gLN+Jlkg6L89XuvQ3woM75Uaf5IG5uNpR70jWrEXvtAm874oTrM2dohZVs0s
k8Rw+ArLRX60WyGU9tAPcZISyMgwyl8dOaDwmjBegWYpke66HYtvgIQ3h6c+yOKf
pK9HKJH8yaUgqxGtia/p4XDvqUjlafCmCMZTHfs/sOQ3fz5dGDuZ2TYbbrMzSPtL
+pvyGlJfb6+ZIpmHhHSMShQ/MA7Ok+grwU8UYxBZ4+KBk+1bqKorAc2p1fGkKJzD
1vitLM4JTpwRYJxCxFgOFvsyOe0c/UqRbV8Hqnerluvjrn35zP6GNIwgNtPRMGIA
E7N8O2jVU8Styq69YUKFIZWhUqkiHMV4SOdAxIGFQqkD/R8OqYocKHtNh5BPaNEY
tzz+HEGiFHae2DmBs8xy+qVJZRPiGO0oZLRx/6u+YhYmzMIcNy1A9G3fb7nZDpoD
WnUFAPytfPNqvEc6CL64Ax8GKGuzjBnP4mh2W8NDhHQTY5OLYywPIuc5VBOb0WTQ
pYFF4KUSItEt+GoAfHhI7ccCAwEAAQ==
-----END PUBLIC KEY-----
"""
    
    var wrongAlgorithmJWT = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6IkpvaG4gRG9lIiwiaWF0IjoxNTE2MjM5MDIyfQ.SflKxwRJSMeKKF2QT4fwpMeJf36POk6yJV_adQssw5c"
    
    var wrongTokenTypeJWT = "eyJhbGciOiJSUzI1NiIsInR5cCI6Ildyb25nSldUIn0.eyJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6IkpvaG4gRG9lIiwiaWF0IjoxNTE2MjM5MDIyfQ.CSEheCRicRpYTYhqi4cNhJJPhpANwUnyN581T-4MKRE_4ctzlrl0k7kqY1sYofpxrF22KfjNZymQuLGegY77prj65jlEgOLJo5nSy3tQBv8VfZJMN2723wRM0_YZWOSJcZdN9yD_b8_1PpxKy9a8mw8pDbDOXlHzO8aoOVj4F0tl7oUN4YYlfZgntVp9AxgQQITAnXN41tKfMluIAIdlI95mIjYsJoE48XoCXLcdfaXAyifjGS-SxY1YNuQ8tKnyXioUaxG3KujtZBBPw-vP6D6cqzLNTLQ9o0u4cgz5NMp0XWnKdrhp5f_Khgsx7wIswtnoDJGa3RnIBi52MxV9zw"
    
    var missingIssuerJWT = "eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9.eyJleHAiOjE2OTYyMzkwMjIsImlhdCI6MTUxNjIzOTAyMn0.fG7qofL7or-0uZlz6eL2nOYDovSiK3tg826RBaVDnVJp2kpCPdVi_xRHIyTjhyFhLHxmNnVLbCUYM0tsZOvGjb1Sx3McGe85oCxj9AB_--1GUBsPxNcLU-L-lsm4ncY2qUqncdxTvSj0b1fUPKdfbsVHKeA59lItmC8cPcjWPEyIHJBUCV2b6rJqtSBYNiFGwv-M0jOmhC9Oj08a8pXuIsvT9VwkUCgqDyDOK8VNED9DaJiluWfi-gcc2U6Gxr3sfrs9GTeCWmsgUq4F9QFGHz7SDoDTfqDeW8yrD5HlXT48IdC8Jp1TdEBWchG4yDbHJRoLxw3AjFAc2pUvVmlNVA"
    
    var incorrectIssuerJWT = "eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9.eyJleHAiOjE2OTYyMzkwMjIsImlhdCI6MTUxNjIzOTAyMiwiaXNzIjoiYXV0aDAifQ.aRONbG0uTTJGsy2qNZdcorJsGcEidgsBwurIvCi2_KZcetH4hugjD0roG3yMsI3ShMA73d9hPstAFDJmv02T6JJ6lm_Qw2gG8ZhnI9xRfDYfW4FmGk_1eiG-Mj47FN2qhT4OFsSK7K1zUYhBwUv1d5-PPFPE2pRH2w83u7SVQta47ZL80x8t2m_EBP3CFG-jlXlpZ8XhPfA5rfGEAsD1imjqlRM0WJE892J7bjJUl5SGrBmFhYKJhdFCENJi_cD21tBAsbqzkadiknWIla7jhPssTMlSAHoUQQet5c8NBi3Mrd8kslQEv8-YwigXWVdfDEhmvmm2TWFKvq-z8DWM4A"
    
    var expiredJWT = "eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9.eyJleHAiOjE1MTYyMzkwMjIsImlhdCI6MTUxNjIzOTAyMiwiaXNzIjoiYXV0aDAifQ.OAwRtg8H1P9z5KpWWAOTAi7FGdvmoh6hnhcP7wn2hXcynprJtY4O6AI4fP4-Oli-Sgp-2LdEoL7UwEpOGv7I3pmiMuMVK0jQet19ueM7A0srQL3KM4CVBZX7f3wE6ZJdB_9N0ZpFO1HZofFQIJMfpcpNpRFh8cESdr-Emy61hWaN4DrBKf1oAZ7VMLwspuLl8XnnFWTmbHa7uEiBaJLBbRT_u1-nMR78P7IWbvUoBWeJPLmKsG7BUAhkD5gET8TfNNvwLNSIHKvCuKmDdO1LTd7_sAszwrkGAaj_Zw42GPrDyWak3SQM3Spvhv-Yl0LquDLUNDQd0RSuZ2bkF3i4WQ"
    
    var incorrectIssueAtJWT = "eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9.eyJleHAiOjE2OTYyMzkwMjIsImlhdCI6MTYwNjIzOTAyMiwiaXNzIjoiYXV0aDAifQ.gDeZtJfQrrK48wP6nuqNznDoXS9eObmWf4ygQ2R6j3HmvrImioEfI7iF01xyHHHdAivwZowQ3ZYIE7hWDhqIAqNMKXmxEsC2vGvuegrdfNW44McjQVj4xROghebkiQTmvQ7Y0ZuXKtUqSyikzylTis4YjAcTaBiX8wPkxiGxoZ2_duZydgboF4hGjCMJyd6i03TxA8V5psmm8b9yfWy35D8_QTikiZPSW4yAR-0A57YA0cRE2V3HW3iJmANJrkZ8McNj--HyGgOh_v6Aw_5Y1nuJft-ZOY_jNYb2-FO-UpKAaCIBmDCSFwXBQNrdG9WcDtRJfmscks0ehh3cO2KERw"
    
    var incorrectNotBeforeJWT = "eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9.eyJleHAiOjE2OTYyMzkwMjIsIm5iZiI6MTYwNjIzOTAyMiwiaWF0IjoxNTA2MjM5MDIyLCJpc3MiOiJhdXRoMCJ9.heNbqPo-I0z_zaDSh3hMGiIVl6GgNi_kM5OjcSesEXS9gMEk3X7Cg-OPVJqknSVAt8U9ZLyNtxsyQBpEBoJr4xe0weMPNxHBBMH-e7YipvGQ3_9Bz6khLh5qiLvLbPZxq5OTI_A_f86XKNHN_8Vqh_S7mKYnx_CNMdIxbHVspZhmfiCfGo_ZgP5OpKvjtSyXfTnhdq1g_oCGgYmuPjpLAKPqsACRpuXzoIxHf-osq-6QRGCzXIFLYW57aR-g3Iwz1It2FNYPXkHru7nIdYkRT5hqkqcw8H3kPRNoj0ejbYGS-slnWqYyp1fPh34qmV5otEUNJdDSEfoPc9uqAbE1sg"
    
    var validStandardJWT = "eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9.eyJleHAiOjE2OTYyMzkwMjIsIm5iZiI6MTUwNjIzOTAyMiwiaWF0IjoxNTA2MjM5MDIyLCJpc3MiOiJhdXRoMSJ9.hpDyiQcA49GIkEzdixDEIdpq5HFy9A4__DgBGosi7w0pz12s6N1HftFY9kfu5aR337viWzsWW6gCMGrlvwv03_DNMpNNnnFf-b1TUcf_NnMRlVN3rKEl1V_6FOaP5C90p2iaOEK3BrPVrerEzPOa9Tux6sZnHobzvu3vYoc7li9WgI-YjwKEAP4LNj5fcpVPnvg1X4OfqkCXVVsdQs-7TqlurIgJ7h4omKYX0TQ0Dq-JrN1a0cKyYUYoyFGyzHKsCUYkqPDDDGAlM-vXkZalEJcFibJKIxXI2Xz6z9WVnbk5pEPjogo-J5kYp_C9ChL-f3M_7QDQ68GCK53lxgDThrexHP8ybFfclCT_WMUDrx3tmZ151o3yA1TJtxj_pdZSPb3lcOo8P4SEJDMlJhN9Be7J6Om1lNaUFQtCEppaBAoJqiqvUo9zQ3XM3pp1UeviFmCrgfvRCyzSxGW8uKvj4i2_rmlKth5UEh8qS-cR8mdaB949q67ux3z9uIH8QW1AhSHPdNOYBbi7sqKHQsiWphh9ykkMFtYlhtK3VHBMAZc_sbBXH1gDlh7mTu6F0Zc9KyYOEJN7ZfNsx98yS2p2TIrnswB6IFYNwuOpUiBXhuSf5LRMMLEN2K-jA2andwzaxk7s-AeuUeLSCUHSg6ib5iJiCYt5JGSLE9WNvZkO1sE"
}
