import Foundation
import SwiftUI
import AVFoundation

@MainActor
class MainViewModel: ObservableObject {
    @Published var currentProject: VideoProject?
    @Published var isAnalyzing = false
    @Published var analysisProgress: Double = 0.0
    @Published var errorMessage: String?
    @Published var showError = false

    private let audioAnalysisService = AudioAnalysisService()
    private let lyricsService = LyricsTranscriptionService()
    private let mediaService = MediaFetchService()

    func createProject(from audioURL: URL) async {
        isAnalyzing = true
        analysisProgress = 0.0
        errorMessage = nil

        do {
            // Get audio info
            let asset = AVAsset(url: audioURL)
            let duration = try await asset.load(.duration)
            let durationSeconds = CMTimeGetSeconds(duration)

            // Create song
            let fileName = audioURL.deletingPathExtension().lastPathComponent
            var song = Song(
                url: audioURL,
                title: fileName,
                duration: durationSeconds
            )

            analysisProgress = 0.2

            // Analyze audio
            let analysis = try await audioAnalysisService.analyze(audioURL: audioURL)
            song.analysis = analysis

            analysisProgress = 0.5

            // Transcribe lyrics (optional, may fail)
            do {
                let lyrics = try await lyricsService.transcribe(audioURL: audioURL)
                song.lyrics = lyrics

                // Extract additional themes from lyrics
                let lyricThemes = lyricsService.extractThemes(from: lyrics)
                var updatedAnalysis = analysis
                var allThemes = Set(analysis.themes)
                allThemes.formUnion(lyricThemes)
                song.analysis = AudioAnalysis(
                    tempo: analysis.tempo,
                    energy: analysis.energy,
                    mood: analysis.mood,
                    keyMoments: analysis.keyMoments,
                    themes: Array(allThemes)
                )
            } catch {
                // Lyrics transcription is optional, continue without it
                print("Lyrics transcription failed: \(error.localizedDescription)")
            }

            analysisProgress = 0.7

            // Generate video clips based on analysis
            let clips = mediaService.generateSampleClips(
                for: song.analysis!,
                duration: durationSeconds
            )

            analysisProgress = 0.9

            // Create project
            let project = VideoProject(song: song, clips: clips)
            currentProject = project

            analysisProgress = 1.0

        } catch {
            errorMessage = error.localizedDescription
            showError = true
        }

        isAnalyzing = false
    }

    func resetProject() {
        currentProject = nil
        analysisProgress = 0.0
        errorMessage = nil
        showError = false
    }
}
