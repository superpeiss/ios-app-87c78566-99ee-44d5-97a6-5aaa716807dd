import Foundation

struct Song: Identifiable, Codable {
    let id: UUID
    let url: URL
    let title: String
    let duration: TimeInterval
    var analysis: AudioAnalysis?
    var lyrics: String?

    init(id: UUID = UUID(), url: URL, title: String, duration: TimeInterval) {
        self.id = id
        self.url = url
        self.title = title
        self.duration = duration
    }
}
