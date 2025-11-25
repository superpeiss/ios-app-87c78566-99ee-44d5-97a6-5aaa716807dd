import Foundation
import SwiftUI

@MainActor
class ExportViewModel: ObservableObject {
    @Published var isExporting = false
    @Published var exportProgress: Double = 0.0
    @Published var exportCompleted = false
    @Published var exportError: String?
    @Published var showError = false
    @Published var exportedVideoURL: URL?

    private let videoService = VideoGenerationService()
    private let exportService = ExportService()

    func exportVideo(project: VideoProject) async {
        isExporting = true
        exportProgress = 0.0
        exportCompleted = false
        exportError = nil

        do {
            let outputURL = exportService.getExportURL(for: project.id)

            try await videoService.generateVideo(
                project: project,
                outputURL: outputURL
            ) { progress in
                Task { @MainActor in
                    self.exportProgress = progress
                }
            }

            exportedVideoURL = outputURL
            exportCompleted = true
            exportProgress = 1.0

        } catch {
            exportError = error.localizedDescription
            showError = true
        }

        isExporting = false
    }

    func saveToPhotoLibrary() async {
        guard let videoURL = exportedVideoURL else { return }

        do {
            try await exportService.saveToPhotoLibrary(videoURL: videoURL)
        } catch {
            exportError = error.localizedDescription
            showError = true
        }
    }

    func reset() {
        isExporting = false
        exportProgress = 0.0
        exportCompleted = false
        exportError = nil
        showError = false
        exportedVideoURL = nil
    }
}
