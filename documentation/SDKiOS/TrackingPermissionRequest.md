# (Optional) Tracking permission request

Since iOS 14, Apple is using the new privacy framework **_AppTrackingTransparency_** which requires developers to request user permission for the app to retrieve and use the identifier for advertisers (IDFA). The AdswizzSDK can be used to achieve higher opt-in rates for accessing IDFA, thus ensuring higher addressability for iOS SDK-enabled inventories. 

## TrackingPermissionController

To leverage Apple's **_AppTrackingTransparency_** framework and trigger a friendly consent alert, the AdswizzSDK exposes a ready-made **_UIViewController_** subclass named **_TrackingPermissionController_**. With this controller, you can easily request the IDFA permission, which can be presented as-is or customized before presentation using a configuration object called **_TrackingPermissionConfiguration_**.

The **_TrackingPermissionController_** manages the entire request permission flow and notifies its delegate of status changes, as well as any errors that may occur.

The presenting view controller has control over the flow and can dismiss the **_TrackingPermissionController_** programmatically at any given moment, except when the actual IDFA permission is requested and the OS has presented the system alert.

The **_TrackingPermissionController_** is meant to be **_presented_** modally instead of pushed onto a **_UINavigationController_**. You can use your own custom animation when it is presented, and the **_TrackingPermissionController_** will dismiss itself by internally calling **_dismiss(animated:completion:)_**, depending on the user's choices (e.g when the user decides to "skip").

Here is how you create and present a **_TrackingPermissionController_** instance:

```swift
class YourViewController: UIViewController {
    var trackingController: TrackingPermissionController?
......
func showTrackingController() {


    // First you should always check whether is appropriate to show the tracking controller.
    // Might be that either:
    // - user already granted permission to be tracked or
    // - user was exposed to the tracking controller before but hasn't decided yet (the IDFA permission status is not determined) or
    // - user declined permission
    // 
    // You can use `TrackingPermissionController`s `canPresentController()` static method which indicates if you should present the controller or not.
    // `canPresentController()` returns false only if either: 
    // - user already granted permission to be tracked.
    // - user can't be asked because IDFA permission is restricted. Read more about AdswizzSDKPrivacyData.framework and how a permission ends up restricted.

    // It will return true when either:
    //
    // - user was exposed to the tracking controller before but hasn't decided yet (the IDFA permission status is not determined) or
    // - user declined permission (here the `TrackingPermissionController` checks if user changed its mind and guides it to Settings -> Privacy -> Tracking)

    if !TrackingPermissionController.canPresentController() {
        // The controller should not be presented. 
        return
    }

    // Customize the title
    let title = "Here goes a custom title"

    // Customize the message. Optional. It defaults to a generic usage description.
    let message = "Here you explain your users why you need to track them"

    // Customize the content image. Optional. It defaults to a generic image.
    let contentImage = UIImage(named: "yourAssetName")

    // Customize the logo image. Optional. If left nil it won't be shown.
    let headerImage = UIImage(named: "yourAssetName")

    // A convenient initializer which returns a `TrackingPermissionController` instance
    // and let's you configure all its customisable elements visible to your users.
    let controller = TrackingPermissionController.trackingController(title: title,
                                                                     message: message,
                                                                     contentImage: contentImage,
                                                                     headerImage: headerImage)
    trackingController = controller // Keeping a reference is optional. It only becomes useful if you want to interrupt the flow and dismiss it programatically
    trackingController.delegate = self // Optional. See below the delegate methods

    present(controller, animated: true, completion: {
        // do something after controller was presented
        .....
    })
 }
......

extension YourViewController: TrackingPermissionControllerDelegate {

    // This method gets called when the tracking permission dismissed itself. It marks the end of the tracking permission flow.
    func tracking(_ controller: TrackingPermissionController, didFinishWith status: TrackingStatus) {
        // You can check the returned `status`. See `TrackingStatus` enum for possible values.
        // The controller was already dismissed at this point.
    }
    
    // This method gets called when the tracking permission controllere encountered an error.
    func tracking(_ controller: TrackingPermissionController, didFailed error: Error) {
        // Handle error. The controller was already dismissed at this point.
    }
}
```

## TrackingPermissionConfiguration

To further customize the appearance and style of the **_TrackingPermissionController_**, you can create a configuration object and pass it onto the controller's initializer.

The **_TrackingPermissionConfiguration_** allows you to style **_TrackingPermissionUIElement_** objects. A **_TrackingPermissionUIElement_** configures a single customizable element component (Skip button, content tittle, etc.) with basic attributes like:
  * content (String)
  * color
  * font

Here is how you can create a configuration of your own:

```swift
class YourViewController: UIViewController {
......
func showTrackingController() {
    if !TrackingPermissionController.canPresentController() {
        // The controller should not be presented. 
        return
    }

    // Customize title
    let title = TrackingPermissionUIElement.Builder().with(content: "Your custom title").with(color: .black).with(font: .boldSystemFont(ofSize: 15)).build()

    // Customize message
    let message = TrackingPermissionUIElement.Builder().with(content: "Your message").with(color: .darkGray).with(font: .systemFont(ofSize: 12)).build()

    // Customize `skip` button appearance and style
    let skip = TrackingPermissionUIElement.Builder().with(content: "Not now").with(color: .blue).with(font: .boldSystemFont(ofSize: 12)).build()

    // Customize main `action` button appearance and style
    let action = TrackingPermissionUIElement.Builder().with(content: "Grant permission").with(color: .blue).with(font: .boldSystemFont(ofSize: 12)).build()

    // Build the config
    let headerImage = ..... // Optional. Pass nil if you want to hide it
    let contentImage = ..... // Optional. Defaults to a generic image provided by AdswizzSDK
    let backgroundColor = .systemBackground // Optional. Defaults to .white or .black (in Dark Mode)
    let config = TrackingPermissionConfiguration.Builder()
          .with(title: title)
          .with(description: message)
          .with(headerImage: headerImage)
          .with(contentImage: contentImage)
          .with(skip: skip)
          .with(action: action)
          .with(backgroundColor: backgroundColor)
          .build()

    // Initialize a `TrackingPermissionController` instance with `config`.
    let controller = TrackingPermissionController(configuration: config)

    ......

    present(controller, animated: true, completion: {
        // do something after controller was presented
        .....
    })
 }
......

```

## Behavior

The tracking request permission controller is able to cover two flows, depending on the IDFA permission status:
  * `.notAsked`: It shows the main initial screen with a bottom right **_action_** button to proceed. This is the normal flow, where user can be presented with the OS alert for granting permission.
  * `.denied`: It shows the main initial screen with a bottom stretched **_action_** button. This is a flow where your app wants another chance for the user to reconsider and grant permission via Settings → Privacy → App tracking

If the IDFA permission is either `.granted` or `.cantAsk`, the **_TrackingPermissionController_** will signal that it should not present the controller (via `canPresentController()` static method).

## Other considerations

The **_TrackingPermissionController_** has been implemented with best practices in mind. Please note that:
  * all internal labels (including button titles) adhere to Apple’s **_dynamic type_**, meaning that they should respond to changes in **_Settings → Accessibility → Display & Text Size → Larger Text_**.
  * the **_TrackingPermissionController_** supports dark mode in its default configuration. If any colour/styling customization is added, it is your app's responsibility to handle appearance changes by updating the configuration on the controller or by using adaptive colors and images (for header logo/content image).
  * the **_TrackingPermissionController_** has support for autorotation by using the presenting controller’s **_shouldAutorotate()_** and **_supportedInterfaceOrientations()_** autorotation setup. If the parent controller allows autorotation, the **_TrackingPermissionController_** will rotate accordingly.

