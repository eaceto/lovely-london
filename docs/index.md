A lightweight ID Token validation library in Swift that implements the OpenID Connection Core 1.0 specification on the subject.

# Architecture decisions of the API

When we build a library, the first thing we should think about is how we would use. Of course there is always a compromise between time, the cost of developing a functionality, and the cost of maintaining it. But it is with the use of our software that we find opportunities for improvement.

In this context, several assumptions were made when designing the most used method of the API, the one that let's the user verify an ID Token.

1. Verifying a token is a very frequent operation (may be a user verifies the token before every HTTP request in order to know if the token is expired) so the parameters that are involved in this verifcation must be set only once.

2. Verifying a token involve cryptographic operations (verifying a signature) and operations with long strings and byte arrays. So they may block the main thread if they are executed there.

## An example of the **verify** function usage

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

The IDTokenVerifier class implements a kind of Builder pattern (but without the Builder class) in order to create an instance of its. In this way, the user may have a singleton object, and can modify at any time the required claims without recreating the object. Also it tries to clarify the code reading.

The **verify** function receives an **idToken** an two blocks (callbacks), one for success and the other for failure on the verification. This prepares the API for being completely asynchronous, as the result is not return by value (blocking the current thread) but in one of the two blocks.

## Setting up the Signature Algoritm

Setting the signature algorithm and the public key to which the ID Token will be verifies can be done in several ways. Using a PEM, or a SecKey or even a file in DER Format present on the main bundle.

The minimun requirement object for performing the verification is a SecKey (an class that Apple Security Framework has), but using this object as the only way to validate a signature leads to the impossiblity to use this library on Linux, where the Security Framework does not have an implementation, and OpenSSL should be used insted.

This kind of decisions can let the library be used not only on iOS / macOS but also in Linux, where the Swift language is becoming popular in server side applications.

Although the current state of the library is not 100% cross platform. These considerations taken in this instance of the development will allow that when it is, they do not imply a break in the API of the same.

## Example project

There is an example project, which integrates with Auth0 Swift SDK for Single Sign On at the following URL: https://github.com/eaceto/lovely-london-example
