import Foundation
import AVFoundation
import UIKit

class VideoGenerationService {

    enum GenerationError: Error, LocalizedError {
        case compositionFailed
        case exportFailed
        case invalidClips

        var errorDescription: String? {
            switch self {
            case .compositionFailed:
                return "Failed to create video composition"
            case .exportFailed:
                return "Failed to export video"
            case .invalidClips:
                return "Invalid video clips provided"
            }
        }
    }

    func generateVideo(
        project: VideoProject,
        outputURL: URL,
        progressHandler: @escaping (Double) -> Void
    ) async throws {
        guard !project.clips.isEmpty else {
            throw GenerationError.invalidClips
        }

        // Create composition
        let composition = AVMutableComposition()

        guard let videoTrack = composition.addMutableTrack(
            withMediaType: .video,
            preferredTrackID: kCMPersistentTrackID_Invalid
        ) else {
            throw GenerationError.compositionFailed
        }

        guard let audioTrack = composition.addMutableTrack(
            withMediaType: .audio,
            preferredTrackID: kCMPersistentTrackID_Invalid
        ) else {
            throw GenerationError.compositionFailed
        }

        // Add audio from song
        let audioAsset = AVAsset(url: project.song.url)
        guard let audioAssetTrack = try await audioAsset.loadTracks(withMediaType: .audio).first else {
            throw GenerationError.compositionFailed
        }

        let audioDuration = try await audioAsset.load(.duration)
        let audioTimeRange = CMTimeRange(start: .zero, duration: audioDuration)

        try audioTrack.insertTimeRange(
            audioTimeRange,
            of: audioAssetTrack,
            at: .zero
        )

        // Add video clips
        var currentTime = CMTime.zero

        for clip in project.clips {
            let clipAsset = AVAsset(url: clip.sourceURL)

            guard let clipVideoTrack = try? await clipAsset.loadTracks(withMediaType: .video).first else {
                continue // Skip invalid clips
            }

            let clipDuration = CMTime(seconds: clip.duration, preferredTimescale: 600)
            let clipTimeRange = CMTimeRange(start: .zero, duration: clipDuration)

            try videoTrack.insertTimeRange(
                clipTimeRange,
                of: clipVideoTrack,
                at: currentTime
            )

            currentTime = CMTimeAdd(currentTime, clipDuration)
        }

        // Create video composition with instructions
        let videoComposition = AVMutableVideoComposition()
        videoComposition.renderSize = CGSize(width: 1920, height: 1080)
        videoComposition.frameDuration = CMTime(value: 1, timescale: 30)

        // Apply color grading and effects
        let instructions = createCompositionInstructions(
            for: project.clips,
            videoTrack: videoTrack,
            composition: composition
        )
        videoComposition.instructions = instructions

        // Export
        try await exportVideo(
            composition: composition,
            videoComposition: videoComposition,
            outputURL: outputURL,
            progressHandler: progressHandler
        )
    }

    private func createCompositionInstructions(
        for clips: [VideoClip],
        videoTrack: AVMutableCompositionTrack,
        composition: AVMutableComposition
    ) -> [AVMutableVideoCompositionInstruction] {
        var instructions: [AVMutableVideoCompositionInstruction] = []
        var currentTime = CMTime.zero

        for clip in clips {
            let instruction = AVMutableVideoCompositionInstruction()
            let clipDuration = CMTime(seconds: clip.duration, preferredTimescale: 600)

            instruction.timeRange = CMTimeRange(start: currentTime, duration: clipDuration)

            let layerInstruction = AVMutableVideoCompositionLayerInstruction(assetTrack: videoTrack)

            // Apply transforms
            layerInstruction.setTransform(CGAffineTransform.identity, at: currentTime)

            // Apply opacity for transitions
            if clip.transition != .none {
                layerInstruction.setOpacity(0.0, at: currentTime)
                layerInstruction.setOpacityRamp(
                    fromStartOpacity: 0.0,
                    toEndOpacity: 1.0,
                    timeRange: CMTimeRange(start: currentTime, duration: CMTime(seconds: 0.5, preferredTimescale: 600))
                )
            }

            instruction.layerInstructions = [layerInstruction]
            instructions.append(instruction)

            currentTime = CMTimeAdd(currentTime, clipDuration)
        }

        return instructions
    }

    private func exportVideo(
        composition: AVComposition,
        videoComposition: AVVideoComposition,
        outputURL: URL,
        progressHandler: @escaping (Double) -> Void
    ) async throws {
        // Remove existing file
        try? FileManager.default.removeItem(at: outputURL)

        guard let exportSession = AVAssetExportSession(
            asset: composition,
            presetName: AVAssetExportPresetHighestQuality
        ) else {
            throw GenerationError.exportFailed
        }

        exportSession.outputURL = outputURL
        exportSession.outputFileType = .mp4
        exportSession.videoComposition = videoComposition

        // Monitor progress
        let timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            progressHandler(Double(exportSession.progress))
        }

        await exportSession.export()

        timer.invalidate()

        guard exportSession.status == .completed else {
            throw GenerationError.exportFailed
        }
    }
}
