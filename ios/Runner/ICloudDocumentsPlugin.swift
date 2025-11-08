import Flutter
import UIKit

@objc(ICloudDocumentsPlugin)
class ICloudDocumentsPlugin: NSObject, FlutterPlugin {
    
    private let iCloudHandler = ICloudDocumentsHandler()
    
    static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "icloud_documents", binaryMessenger: registrar.messenger())
        let instance = ICloudDocumentsPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }
    
    func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "saveToICloud":
            guard let args = call.arguments as? [String: Any],
                  let data = args["data"] as? FlutterStandardTypedData else {
                result(FlutterError(code: "INVALID_ARGUMENTS", message: "Data argument is required", details: nil))
                return
            }
            
            iCloudHandler.saveToICloud(data.data) { success, error in
                if success {
                    result(["success": true])
                } else {
                    result(FlutterError(code: "SAVE_FAILED", message: error, details: nil))
                }
            }
            
        case "loadFromICloud":
            iCloudHandler.loadFromICloud { data, error in
                if let data = data {
                    result(["success": true, "data": FlutterStandardTypedData(bytes: data)])
                } else {
                    result(FlutterError(code: "LOAD_FAILED", message: error, details: nil))
                }
            }
            
        case "isICloudAvailable":
            let isAvailable = iCloudHandler.isICloudAvailable()
            result(["available": isAvailable])
            
        case "deleteICloudFile":
            iCloudHandler.deleteICloudFile { success, error in
                if success {
                    result(["success": true])
                } else {
                    result(FlutterError(code: "DELETE_FAILED", message: error, details: nil))
                }
            }
            

        case "getICloudFileURL":
            if let url = iCloudHandler.getICloudFileURL() {
                result(["url": url])
            } else {
                result(FlutterError(code: "URL_NOT_AVAILABLE", message: "iCloud file URL not available", details: nil))
            }
            
                case "checkICloudFileExists":
                    let exists = iCloudHandler.checkICloudFileExists()
                    result(["exists": exists])
                    
                case "checkICloudSyncStatus":
                    let status = iCloudHandler.checkICloudSyncStatus()
                    result(status)
                case "getICloudAccountInfo":
                    iCloudHandler.getICloudAccountInfo { info in
                        result(info)
                    }
                    
                default:
                    result(FlutterMethodNotImplemented)
        }
    }
}
