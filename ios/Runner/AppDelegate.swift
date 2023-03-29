import UIKit
import Flutter

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    if (!isInDebugMode) {
      // In production mode, log to an external service.
      // For example, Firebase Crashlytics.
      GeneratedPluginRegistrant.register(with: self)
    } else {
      // In development mode, log to the console.
      GeneratedPluginRegistrant.register(with: self)
      FlutterDebugPlugin.sharedInstance().startObservingFlutterLifecycleEvents()
    }
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
