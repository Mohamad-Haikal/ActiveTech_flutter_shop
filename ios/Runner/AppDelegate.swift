import UIKit
import Flutter
import FirebaseCrashlytics
import Firebase

@main
class AppDelegate: FlutterAppDelegate, CrashlyticsDelegate {
    
    override func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        FirebaseApp.configure()
        
        Crashlytics.crashlytics().delegate = self
        Crashlytics.crashlytics().setCrashlyticsCollectionEnabled(true)
        Crashlytics.crashlytics().checkForUnsentReports { (_) in }
        
        let controller: FlutterViewController = window?.rootViewController as! FlutterViewController
        let channel = FlutterMethodChannel(name: "samples.flutter.dev/battery", binaryMessenger: controller.binaryMessenger)
        channel.setMethodCallHandler({
            [weak self] (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
            guard call.method == "getBatteryLevel" else {
                result(FlutterMethodNotImplemented)
                return
            }
            self?.getBatteryLevel(result: result)
        })
        GeneratedPluginRegistrant.register(with: self)

        // Enable debugging mode
        #if DEBUG
        FlutterDebugPlugin.sharedInstance()?.startObservingApplication()
        #endif
        print("Application launched")
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
    
    private func getBatteryLevel(result: FlutterResult) {
        let device = UIDevice.current
        device.isBatteryMonitoringEnabled = true
        if device.batteryState == UIDevice.BatteryState.unknown {
            result(FlutterError(code: "UNAVAILABLE",
                                message: "Battery info unavailable",
                                details: nil))
        } else {
            result(Int(device.batteryLevel * 100))
        }
    }
    
    func crashlyticsDidDetectReport(forLastExecution report: CrashlyticsReport) {
        print("Crash detected: \(report)")
    }
}
