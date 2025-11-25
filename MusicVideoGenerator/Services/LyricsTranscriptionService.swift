import Foundation
import Speech
import AVFoundation

class LyricsTranscriptionService {

    enum TranscriptionError: Error, LocalizedError {
        case authorizationDenied
        case transcriptionFailed
        case unavailable

        var errorDescription: String? {
            switch self {
            case .authorizationDenied:
                return "Speech recognition authorization denied"
            case .transcriptionFailed:
                return "Failed to transcribe lyrics"
            case .unavailable:
                return "Speech recognition unavailable"
            }
        }
    }

    func transcribe(audioURL: URL) async throws -> String {
        // Check authorization
        let authStatus = SFSpeechRecognizer.authorizationStatus()

        guard authStatus == .authorized || authStatus == .notDetermined else {
            throw TranscriptionError.authorizationDenied
        }

        // Request authorization if needed
        if authStatus == .notDetermined {
            let authorized = await requestAuthorization()
            guard authorized else {
                throw TranscriptionError.authorizationDenied
            }
        }

        // Create recognizer
        guard let recognizer = SFSpeechRecognizer() else {
            throw TranscriptionError.unavailable
        }

        guard recognizer.isAvailable else {
            throw TranscriptionError.unavailable
        }

        // Create recognition request
        let request = SFSpeechURLRecognitionRequest(url: audioURL)
        request.shouldReportPartialResults = false

        return try await withCheckedThrowingContinuation { continuation in
            recognizer.recognitionTask(with: request) { result, error in
                if let error = error {
                    continuation.resume(throwing: TranscriptionError.transcriptionFailed)
                    return
                }

                if let result = result, result.isFinal {
                    continuation.resume(returning: result.bestTranscription.formattedString)
                }
            }
        }
    }

    private func requestAuthorization() async -> Bool {
        await withCheckedContinuation { continuation in
            SFSpeechRecognizer.requestAuthorization { status in
                continuation.resume(returning: status == .authorized)
            }
        }
    }

    func extractThemes(from lyrics: String) -> [String] {
        // Simple keyword extraction
        let keywords = [
            "love", "heart", "night", "day", "sky", "star", "moon",
            "dream", "hope", "pain", "joy", "dance", "sing", "light",
            "dark", "fire", "water", "wind", "rain", "sun", "time"
        ]

        let lowercasedLyrics = lyrics.lowercased()
        var foundThemes: [String] = []

        for keyword in keywords {
            if lowercasedLyrics.contains(keyword) && !foundThemes.contains(keyword) {
                foundThemes.append(keyword)
            }
        }

        return foundThemes
    }
}
