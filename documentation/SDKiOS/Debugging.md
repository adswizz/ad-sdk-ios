# Debugging the AdswizzSDK

The AdswizzSDK uses an internal logger called **_AdLogger_**. By default, the logging level is set to none, meaning that nothing gets logged. Should you need the AdswizzSDK to log events, you can enable a different logging level; verbose is the one with the highest density, hence we do not recommend its use in production. 
You can also provide a new destination for the logger (e.g.: pipe it to your app logger). By default, the AdswizzSDK dumps log events in the console.


```swift
extension AppDelegate: AdswizzSDKDelegate {
    func configureAdswizzSDK() {
      ......
      AdLogger.shared.level = .info
      AdLogger.shared.destination = self
      ......
    }
}
......
extension AppDelegate: AdLoggerDestination {
  func log(_ level: AdLogger.Level, functionName: String, fileName: String, lineNumber: Int, line: String) {
      //Pipe it to your logger
  }
}
```

