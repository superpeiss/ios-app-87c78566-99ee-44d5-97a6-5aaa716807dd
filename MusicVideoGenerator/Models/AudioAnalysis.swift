import Foundation

struct AudioAnalysis: Codable {
    let tempo: Double // BPM
    let energy: Double // 0.0 to 1.0
    let mood: Mood
    let keyMoments: [KeyMoment]
    let themes: [String]

    enum Mood: String, Codable, CaseIterable {
        case happy = "Happy"
        case sad = "Sad"
        case energetic = "Energetic"
        case calm = "Calm"
        case dramatic = "Dramatic"
        case romantic = "Romantic"
        case mysterious = "Mysterious"
        case aggressive = "Aggressive"
    }

    struct KeyMoment: Codable, Identifiable {
        let id: UUID
        let timestamp: TimeInterval
        let intensity: Double // 0.0 to 1.0
        let description: String

        init(id: UUID = UUID(), timestamp: TimeInterval, intensity: Double, description: String) {
            self.id = id
            self.timestamp = timestamp
            self.intensity = intensity
            self.description = description
        }
    }
}
