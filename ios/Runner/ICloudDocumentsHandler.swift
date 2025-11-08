import Foundation
import UIKit
import CloudKit

@objc(ICloudDocumentsHandler)
class ICloudDocumentsHandler: NSObject {
    
    private let containerIdentifier = "iCloud.com.verby.net"
    private let backupFileName = "records_backup.zip"
    
    @objc
    static func requiresMainQueueSetup() -> Bool {
        return false
    }
    
    @objc
    func saveToICloud(_ data: Data, completion: @escaping (Bool, String?) -> Void) {
        print("🔵 [iCloud] Starting saveToICloud with data size: \(data.count) bytes")
        let tokenPresent = FileManager.default.ubiquityIdentityToken != nil
        print("🪪 [iCloud] ubiquityIdentityToken present: \(tokenPresent)")
        
        guard let containerURL = FileManager.default.url(forUbiquityContainerIdentifier: containerIdentifier) else {
            print("❌ [iCloud] Container not available for identifier: \(containerIdentifier)")
            completion(false, "iCloud container not available")
            return
        }
        
        print("✅ [iCloud] Container URL: \(containerURL.path)")
        
        // Use Documents folder directly instead of creating a subfolder
        let documentsURL = containerURL.appendingPathComponent("Documents")
        let fileURL = documentsURL.appendingPathComponent(backupFileName)
        
        print("📁 [iCloud] Documents URL: \(documentsURL.path)")
        print("📄 [iCloud] File URL: \(fileURL.path)")
        
        do {
            // Create Documents folder if it doesn't exist
            print("📂 [iCloud] Creating Documents directory if needed...")
            try FileManager.default.createDirectory(at: documentsURL, withIntermediateDirectories: true, attributes: nil)
            print("✅ [iCloud] Documents directory created/verified")
            
            // Check if file already exists
            let fileExists = FileManager.default.fileExists(atPath: fileURL.path)
            print("🔍 [iCloud] File already exists: \(fileExists)")
            
            // Remove existing file if it exists
            if fileExists {
                print("🗑️ [iCloud] Removing existing file...")
                try FileManager.default.removeItem(at: fileURL)
                print("✅ [iCloud] Existing file removed")
            }
            
            // Write to temporary local file first
            let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent("temp_\(backupFileName)")
            print("💾 [iCloud] Writing data to temp file: \(tempURL.path)")
            try data.write(to: tempURL)
            print("✅ [iCloud] Data written to temp file successfully")
            
            // Promote temp file to ubiquitous item
            print("☁️ [iCloud] Promoting file to ubiquitous item...")
            try FileManager.default.setUbiquitous(true, itemAt: tempURL, destinationURL: fileURL)
            print("✅ [iCloud] File promoted to ubiquitous item successfully")
            
            // Verify file was created
            let finalFileExists = FileManager.default.fileExists(atPath: fileURL.path)
            print("🔍 [iCloud] Final file existence check: \(finalFileExists)")
            
            if finalFileExists {
                let attributes = try FileManager.default.attributesOfItem(atPath: fileURL.path)
                let finalFileSize = attributes[.size] as? Int64 ?? 0
                print("📊 [iCloud] Final file size: \(finalFileSize) bytes")
                
                var values = try fileURL.resourceValues(forKeys: [
                    .isUbiquitousItemKey,
                    .ubiquitousItemIsUploadedKey,
                    .ubiquitousItemIsUploadingKey,
                    .ubiquitousItemUploadingErrorKey,
                    .ubiquitousItemIsDownloadingKey,
                    .ubiquitousItemDownloadingErrorKey,
                    .ubiquitousItemDownloadingStatusKey
                ])
                let isUbiquitous = values.isUbiquitousItem ?? false
                print("☁️ [iCloud] Is ubiquitous item: \(isUbiquitous)")
                print("⬆️ [iCloud] Uploaded: \(values.ubiquitousItemIsUploaded ?? false)")
                print("⏫ [iCloud] Uploading: \(values.ubiquitousItemIsUploading ?? false)")
                if let upErr = values.ubiquitousItemUploadingError { print("❌ [iCloud] Upload error: \(upErr.localizedDescription)") }
                print("⏬ [iCloud] Downloading: \(values.ubiquitousItemIsDownloading ?? false)")
                if let dnErr = values.ubiquitousItemDownloadingError { print("❌ [iCloud] Download error: \(dnErr.localizedDescription)") }
                if let dnStatus = values.ubiquitousItemDownloadingStatus { print("ℹ️ [iCloud] Download status: \(dnStatus.rawValue)") }
            }
            
            print("🎉 [iCloud] SUCCESS: File saved as ubiquitous item to iCloud Documents")
            print("📍 [iCloud] Full path: \(fileURL.path)")
            print("📍 [iCloud] Container: \(containerURL.path)")
            print("📍 [iCloud] Documents: \(documentsURL.path)")
            print("📱 [iCloud] File should now be visible in Files app under iCloud Drive")
            
            completion(true, nil)
        } catch {
            print("❌ [iCloud] ERROR: \(error.localizedDescription)")
            print("❌ [iCloud] Error details: \(error)")
            completion(false, "Failed to save to iCloud: \(error.localizedDescription)")
        }
    }
    
    @objc
    func loadFromICloud(completion: @escaping (Data?, String?) -> Void) {
        guard let containerURL = FileManager.default.url(forUbiquityContainerIdentifier: containerIdentifier) else {
            completion(nil, "iCloud container not available")
            return
        }
        
        let documentsURL = containerURL.appendingPathComponent("Documents")
        let fileURL = documentsURL.appendingPathComponent(backupFileName)
        
        do {
            let data = try Data(contentsOf: fileURL)
            completion(data, nil)
        } catch {
            completion(nil, "Failed to load from iCloud: \(error.localizedDescription)")
        }
    }
    
    @objc
    func isICloudAvailable() -> Bool {
        print("🔍 [iCloud] Checking iCloud availability...")
        print("🔍 [iCloud] Container identifier: \(containerIdentifier)")
        
        guard let containerURL = FileManager.default.url(forUbiquityContainerIdentifier: containerIdentifier) else {
            print("❌ [iCloud] iCloud container not available")
            return false
        }
        
        print("✅ [iCloud] iCloud container available at: \(containerURL.path)")
        
        // Check if container is accessible
        let isAccessible = FileManager.default.fileExists(atPath: containerURL.path)
        print("🔍 [iCloud] Container accessible: \(isAccessible)")
        
        // Check Documents folder
        let documentsURL = containerURL.appendingPathComponent("Documents")
        let documentsExists = FileManager.default.fileExists(atPath: documentsURL.path)
        print("🔍 [iCloud] Documents folder exists: \(documentsExists)")
        print("📁 [iCloud] Documents path: \(documentsURL.path)")
        
        return true
    }
    
    @objc
    func getICloudFileURL() -> String? {
        guard let containerURL = FileManager.default.url(forUbiquityContainerIdentifier: containerIdentifier) else {
            print("iCloud container not available")
            return nil
        }
        
        let documentsURL = containerURL.appendingPathComponent("Documents")
        let fileURL = documentsURL.appendingPathComponent(backupFileName)
        
        // Check if file actually exists
        let fileExists = FileManager.default.fileExists(atPath: fileURL.path)
        print("iCloud file exists: \(fileExists)")
        print("iCloud file path: \(fileURL.path)")
        
        return fileURL.path
    }
    
    @objc
    func checkICloudFileExists() -> Bool {
        print("🔍 [iCloud] Checking if file exists in iCloud...")
        
        guard let containerURL = FileManager.default.url(forUbiquityContainerIdentifier: containerIdentifier) else {
            print("❌ [iCloud] Container not available for file check")
            return false
        }
        
        let documentsURL = containerURL.appendingPathComponent("Documents")
        let fileURL = documentsURL.appendingPathComponent(backupFileName)
        
        print("📁 [iCloud] Checking file at: \(fileURL.path)")
        
        let fileExists = FileManager.default.fileExists(atPath: fileURL.path)
        print("🔍 [iCloud] File exists: \(fileExists)")
        
        if fileExists {
            do {
                let fileSize = try FileManager.default.attributesOfItem(atPath: fileURL.path)[.size] as? Int64 ?? 0
                print("📊 [iCloud] File size: \(fileSize) bytes")
                
                let fileModificationDate = try FileManager.default.attributesOfItem(atPath: fileURL.path)[.modificationDate] as? Date
                print("📅 [iCloud] File modification date: \(fileModificationDate?.description ?? "Unknown")")
            } catch {
                print("❌ [iCloud] Error getting file attributes: \(error)")
            }
        }
        
        return fileExists
    }
    
    @objc
    func checkICloudSyncStatus() -> [String: Any] {
        print("🔍 [iCloud] Checking iCloud sync status...")
        
        var status: [String: Any] = [:]
        
        guard let containerURL = FileManager.default.url(forUbiquityContainerIdentifier: containerIdentifier) else {
            print("❌ [iCloud] Container not available")
            status["containerAvailable"] = false
            return status
        }
        
        status["containerAvailable"] = true
        status["containerPath"] = containerURL.path
        
        let documentsURL = containerURL.appendingPathComponent("Documents")
        let fileURL = documentsURL.appendingPathComponent(backupFileName)
        
        status["documentsPath"] = documentsURL.path
        status["filePath"] = fileURL.path
        
        let fileExists = FileManager.default.fileExists(atPath: fileURL.path)
        status["fileExists"] = fileExists
        
        print("📁 [iCloud] Container: \(containerURL.path)")
        print("📁 [iCloud] Documents: \(documentsURL.path)")
        print("📄 [iCloud] File: \(fileURL.path)")
        print("🔍 [iCloud] File exists: \(fileExists)")
        
        if fileExists {
            do {
                let fileSize = try FileManager.default.attributesOfItem(atPath: fileURL.path)[.size] as? Int64 ?? 0
                status["fileSize"] = fileSize
                print("📊 [iCloud] File size: \(fileSize) bytes")

                var values = try fileURL.resourceValues(forKeys: [
                    .isUbiquitousItemKey,
                    .ubiquitousItemIsUploadedKey,
                    .ubiquitousItemIsUploadingKey,
                    .ubiquitousItemUploadingErrorKey,
                    .ubiquitousItemIsDownloadingKey,
                    .ubiquitousItemDownloadingErrorKey,
                    .ubiquitousItemDownloadingStatusKey
                ])
                let isUbiquitous = values.isUbiquitousItem ?? false
                status["isUbiquitousItem"] = isUbiquitous
                status["uploaded"] = values.ubiquitousItemIsUploaded ?? false
                status["uploading"] = values.ubiquitousItemIsUploading ?? false
                status["uploadError"] = values.ubiquitousItemUploadingError?.localizedDescription
                status["downloading"] = values.ubiquitousItemIsDownloading ?? false
                status["downloadError"] = values.ubiquitousItemDownloadingError?.localizedDescription
                status["downloadStatus"] = values.ubiquitousItemDownloadingStatus?.rawValue
                print("☁️ [iCloud] Is ubiquitous item: \(isUbiquitous)")
                print("⬆️ [iCloud] Uploaded: \(values.ubiquitousItemIsUploaded ?? false)")
                print("⏫ [iCloud] Uploading: \(values.ubiquitousItemIsUploading ?? false)")
                if let upErr = values.ubiquitousItemUploadingError { print("❌ [iCloud] Upload error: \(upErr.localizedDescription)") }
                print("⏬ [iCloud] Downloading: \(values.ubiquitousItemIsDownloading ?? false)")
                if let dnErr = values.ubiquitousItemDownloadingError { print("❌ [iCloud] Download error: \(dnErr.localizedDescription)") }
                if let dnStatus = values.ubiquitousItemDownloadingStatus { print("ℹ️ [iCloud] Download status: \(dnStatus.rawValue)") }

            } catch {
                print("❌ [iCloud] Error getting file attributes: \(error)")
                status["error"] = error.localizedDescription
            }
        }
        
        return status
    }

    @objc
    func getICloudAccountInfo(completion: @escaping ([String: Any]) -> Void) {
        var info: [String: Any] = [:]
        let tokenPresent = FileManager.default.ubiquityIdentityToken != nil
        info["ubiquityIdentityTokenPresent"] = tokenPresent

        let defaultContainer = FileManager.default.url(forUbiquityContainerIdentifier: nil)
        info["defaultContainerAvailable"] = (defaultContainer != nil)
        info["defaultContainerPath"] = defaultContainer?.path

        let specificContainer = FileManager.default.url(forUbiquityContainerIdentifier: containerIdentifier)
        info["specifiedContainerAvailable"] = (specificContainer != nil)
        info["specifiedContainerPath"] = specificContainer?.path

        CKContainer.default().accountStatus { status, error in
            var ck: [String: Any] = [:]
            ck["status"] = status.rawValue
            if let error = error { ck["error"] = error.localizedDescription }
            info["cloudKitAccountStatus"] = ck
            completion(info)
        }
    }

        @objc
        func deleteICloudFile(completion: @escaping (Bool, String?) -> Void) {
            print("🗑️ [iCloud] Starting deleteICloudFile...")

            guard let containerURL = FileManager.default.url(forUbiquityContainerIdentifier: containerIdentifier) else {
                print("❌ [iCloud] Container not available for deletion")
                completion(false, "iCloud container not available")
                return
            }

            let documentsURL = containerURL.appendingPathComponent("Documents")
            let fileURL = documentsURL.appendingPathComponent(backupFileName)

            print("📁 [iCloud] Attempting to delete file at: \(fileURL.path)")

            do {
                // Check if file exists
                let fileExists = FileManager.default.fileExists(atPath: fileURL.path)
                if !fileExists {
                    print("⚠️ [iCloud] File does not exist, nothing to delete")
                    completion(true, nil) // Success - nothing to delete
                    return
                }

                // Delete the file
                try FileManager.default.removeItem(at: fileURL)
                print("✅ [iCloud] File deleted successfully")

                // Verify deletion
                let stillExists = FileManager.default.fileExists(atPath: fileURL.path)
                if stillExists {
                    print("❌ [iCloud] File still exists after deletion attempt")
                    completion(false, "Failed to delete file")
                } else {
                    print("🎉 [iCloud] SUCCESS: File deleted from iCloud Documents")
                    completion(true, nil)
                }

            } catch {
                print("❌ [iCloud] ERROR deleting file: \(error.localizedDescription)")
                completion(false, "Failed to delete file: \(error.localizedDescription)")
            }
        }
    
}
