import Foundation
import Photos
import UIKit

class ExportService {

    enum ExportError: Error, LocalizedError {
        case saveFailed
        case authorizationDenied
        case invalidURL

        var errorDescription: String? {
            switch self {
            case .saveFailed:
                return "Failed to save video to photo library"
            case .authorizationDenied:
                return "Photo library access denied"
            case .invalidURL:
                return "Invalid video URL"
            }
        }
    }

    func saveToPhotoLibrary(videoURL: URL) async throws {
        // Request authorization
        let status = PHPhotoLibrary.authorizationStatus(for: .addOnly)

        if status == .notDetermined {
            let authorized = await PHPhotoLibrary.requestAuthorization(for: .addOnly)
            guard authorized == .authorized || authorized == .limited else {
                throw ExportError.authorizationDenied
            }
        } else if status != .authorized && status != .limited {
            throw ExportError.authorizationDenied
        }

        // Save video
        try await PHPhotoLibrary.shared().performChanges {
            PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: videoURL)
        }
    }

    func shareVideo(videoURL: URL, from viewController: UIViewController) {
        let activityViewController = UIActivityViewController(
            activityItems: [videoURL],
            applicationActivities: nil
        )

        viewController.present(activityViewController, animated: true)
    }

    func getExportURL(for projectID: UUID) -> URL {
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let exportURL = documentsPath
            .appendingPathComponent("Exports")
            .appendingPathComponent("\(projectID.uuidString).mp4")

        // Create exports directory if needed
        let exportDirectory = exportURL.deletingLastPathComponent()
        try? FileManager.default.createDirectory(at: exportDirectory, withIntermediateDirectories: true)

        return exportURL
    }
}
