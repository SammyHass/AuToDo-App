import UIKit
import Flutter
import NaturalLanguage
@available(iOS 12.0, *)

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        let controller : FlutterViewController = window?.rootViewController as! FlutterViewController
        let channel = FlutterMethodChannel(name: "todo.sammyhass.io/ML",
                                                  binaryMessenger: controller)
        channel.setMethodCallHandler({
            [weak self] (call: FlutterMethodCall, result: FlutterResult) -> Void in
            guard call.method == "getTaskPrediction" else {
                result(FlutterMethodNotImplemented)
                return
            }
            guard let args = call.arguments else {
                return
            }
            if let myArgs = args as? [String: Any],
                let title  = myArgs["title"] as? String {
                self?.getTaskPrediction(result: result, title: title) } else {
                result("iOS could not extract flutter arguments in method: (sendParams)")
            }
        });
        
        GeneratedPluginRegistrant.register(with: self)
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
    
    private func getTaskPrediction(result: FlutterResult, title: String) {
        let model = try! NLModel(mlModel:   taskClassifier().model)
        result(model.predictedLabel(for: title));
    }
}
