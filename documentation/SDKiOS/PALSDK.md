# (Optional) Interoperability with the PAL SDK

The AdswizzSDK can work with Google's PAL SDK to access video demand from DV360. The AdswizzSDK is not directly linked to the PAL SDK but exposes a public API to facilitate communication.

## What you need to do
First, you need to make sure that PAL SDK's **_PALNonceManager_** class conforms to AdswizzSDK's **_PALManagerProtocol_** protocol:

```swift
import AdswizzSDK
import ProgrammaticAccessLibrary

//Make sure to conform to Adswizz's PALManagerProtocol
extension NonceManager: PALManagerProtocol {    
}
```
**_PALManagerProtocol_** resembles the **_PALNonceManager_** public class from PAL SDK version 2.3.1.

Next, you need get a hold of the **_PALNonceManager_** object from the PAL SDK. While filling the data for a **_PALNonceRequest_**, you may need (not mandatory) to add OMID specific data:

```swift
....
        let request = NonceRequest()
        request.omidPartnerName = AdswizzSDK.shared.omidPartner
        request.omidPartnerVersion = AdswizzSDK.shared.omidPartnerVersion
        request.omidVersion = AdswizzSDK.shared.omidVersion
        
        nonceLoader?.delegate = self
        nonceLoader?.loadNonceManager(with: request)
....
```
This can be retrieved from the AdswizzSDK, as seen above.

Once you get a **_PALNonceManager_**, the final step is to link the AdswizzSDK with the **_PALNonceManager_** object. It is very important to keep a strong reference to the **_PALNonceManager_** object, as the AdswizzSDK uses a weak reference.

```swift
extension PALNonceManagerResolver: NonceLoaderDelegate {
  func nonceLoader(_ nonceLoader: NonceLoader, with request: NonceRequest, didLoad nonceManager: NonceManager) {
      self.nonceManager = nonceManager //keep the nonce manager in your app
      AdswizzSDK.shared.palManager = nonceManager //link with AdswizzSDK
  }

  func nonceLoader(_ nonceLoader: NonceLoader, with request: NonceRequest, didFailWith error: Error) {
  }
}
```
