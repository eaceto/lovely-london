# Lovely London

Loveluy London is a library that let the user verify an ID Token. The verification not only includes the token format, header and payload validation, but also the signature and the presence of custom Claims

## Table of Contents
1. [Features](#features)
2. [Installation](#installation)
3. [Usage](#usage)
4. [Tests](#tests)
5. [Errors](#errors)
6. [References](#references)

## Features
- [&check;] Verify ID Token format
- [&check;] Verify ID Token header
- [&check;] Verify ID Token payload
- [&check;] Verify ID Token signature
- [&check;] Clock skew
- [&check;] Supports no signature verification
- [&check;] Supports RSA (RSA256, RSA384, RSA512)
- [&check;] Require custom claims to be present
- [&nbsp;&nbsp;&nbsp;] Linux compatible (Using OpenSSL)
- [&nbsp;&nbsp;&nbsp;] Async verification in background thread
- [&nbsp;&nbsp;&nbsp;] Supports HS (HS256, HS384, HS512)
- [&nbsp;&nbsp;&nbsp;] Installable using Carthage
- [&nbsp;&nbsp;&nbsp;] Installable using Cocoapods

## Installation

### Using Swift Package Manager

1. Open your project with Xcode
2. Click on **File** -> **Swift Packages** -> **Add Package Dependency** 
3. Select your project and click on **Next**
4. Search for the package or add the repository manually using the following URL: **https://github.com/eaceto/lovely-london**
5. Clickl on **Next**

## Usage

1. Import the library where you need to perform the verification

```swift
import lovely_london
```

2. Create a IDTokenVerifier object passing the requiered claims and configuration

```swift
let verifier = IDTokenVerifier()
    .require(claim: Claim.issuer(issuer))
    .require(claim: Claim.custom(claim: "kid", value: "KeyID"))
    .allowClockDifference(in: 5.0) // in seconds
```

3. If you want to perform signature verification create a SignatureAlgorithm object and set it to the verifier

```swift
let algorithm = SignatureAlgorithm.RSA256
```

You can also create a SignatureAlgorithm from a String, useful when retrieving the signature algorithm from a service

```swift
let algorithm = SignatureAlgorithm.from(string: "RSA256")
```

and then set the required signature algorithm and public key to the verifier

```swift
verifier.set(signatureAlgorithm: algorithm, and: publicKey)
```

4. Calling the *verify* method passing and ID Token and two callback functions performs all the verifications

A complete example of ID Token verification, which includes checking a mandatory issuer and custom claim can be seen in the following example:

```swift
let algorithm = SignatureAlgorithm.RS256
let verifier = IDTokenVerifier()
    .set(signatureAlgorithm: algorithm, and: publicKey)
    .require(claim: .issuer("auth1"))
    .allowClockDifference(in: 5.0) // 5 seconds of clock difference for exp, iat and nbf

verifier.verify(idToken: validStandardJWT,
                onSuccess: { idToken in
                    debugPrint("ID Token verified")
                },
                onError: { error in
                    debugPrint("ID Token verification failed with \(error)")
                })
```

where **publicKey** and **validStandardJWT** are

```swift
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

var validStandardJWT = "eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9.eyJleHAiOjE2OTYyMzkwMjIsIm5iZiI6MTUwNjIzOTAyMiwiaWF0IjoxNTA2MjM5MDIyLCJpc3MiOiJhdXRoMSJ9.hpDyiQcA49GIkEzdixDEIdpq5HFy9A4__DgBGosi7w0pz12s6N1HftFY9kfu5aR337viWzsWW6gCMGrlvwv03_DNMpNNnnFf-b1TUcf_NnMRlVN3rKEl1V_6FOaP5C90p2iaOEK3BrPVrerEzPOa9Tux6sZnHobzvu3vYoc7li9WgI-YjwKEAP4LNj5fcpVPnvg1X4OfqkCXVVsdQs-7TqlurIgJ7h4omKYX0TQ0Dq-JrN1a0cKyYUYoyFGyzHKsCUYkqPDDDGAlM-vXkZalEJcFibJKIxXI2Xz6z9WVnbk5pEPjogo-J5kYp_C9ChL-f3M_7QDQ68GCK53lxgDThrexHP8ybFfclCT_WMUDrx3tmZ151o3yA1TJtxj_pdZSPb3lcOo8P4SEJDMlJhN9Be7J6Om1lNaUFQtCEppaBAoJqiqvUo9zQ3XM3pp1UeviFmCrgfvRCyzSxGW8uKvj4i2_rmlKth5UEh8qS-cR8mdaB949q67ux3z9uIH8QW1AhSHPdNOYBbi7sqKHQsiWphh9ykkMFtYlhtK3VHBMAZc_sbBXH1gDlh7mTu6F0Zc9KyYOEJN7ZfNsx98yS2p2TIrnswB6IFYNwuOpUiBXhuSf5LRMMLEN2K-jA2andwzaxk7s-AeuUeLSCUHSg6ib5iJiCYt5JGSLE9WNvZkO1sE"
```

## Errors

When the verification fails one of the following errors is sent in the **onError** callback

```swift
enum IDTokenVerificationError: Error {
    case invalidIDTokenFormat(message: String)
    case missingRequiredParam(param: String, message: String)
    case incorrectAlgorithm(expected: String, got: String)
    case missingRequiredClaim(claim: String, payload: String)
    case missingConfiguration(claim: String, message: String)
    case incorrentRequiredClaim(claim: String, expected: String, got: String)
    case tokenExpired(expiration: Date)
    case issueAtInTheFuture(issueAt: Date)
    case tokenCannotBeUsedBefore(notBefore: Date)
    case unknownError(idToken: String, signatureVerificator: SignatureVerificator)
}
```

Additional information is present in the error dictionary. For example, is the verifcation fails because of a required claim is not present in the token, the following error will be returned:

```swift
onError: { error in
    if case IDTokenVerificationError.incorrentRequiredClaim(claim: let claim,
                                                            expected: let expectedValue,
                                                            got: let tokenValue) = error {
        
        debugPrint("An error ocurred while verifying the token claim:\(claim). Expected value \(expectedValue), got: \(tokenValue)")        
        return
    }
```


## Tests
Some tests demostrating how the verification works can be found at [Test Suite](https://github.com/eaceto/lovely-london/blob/master/Tests/lovely-londonTests/lovely_londonTests.swift)


## References
- [OpenID Connect Core v1.0 - Full Specification](https://openid.net/specs/openid-connect-core-1_0.html)
- [OpenID Connect Core v1.0 - ID Token Validation](https://openid.net/specs/openid-connect-core-1_0.html#IDTokenValidation)
- [JSON Web Token (JWT) - RFC 7519](https://tools.ietf.org/html/rfc7519)

