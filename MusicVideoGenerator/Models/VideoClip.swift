import Foundation
import AVFoundation

struct VideoClip: Identifiable, Codable {
    let id: UUID
    let sourceURL: URL
    let startTime: TimeInterval
    let duration: TimeInterval
    var transition: Transition
    var colorGrade: ColorGrade?

    enum Transition: String, Codable, CaseIterable {
        case none = "None"
        case crossDissolve = "Cross Dissolve"
        case fade = "Fade"
        case wipe = "Wipe"
        case push = "Push"
    }

    struct ColorGrade: Codable {
        var brightness: Double // -1.0 to 1.0
        var contrast: Double // -1.0 to 1.0
        var saturation: Double // -1.0 to 1.0
        var temperature: Double // -1.0 to 1.0

        static let `default` = ColorGrade(
            brightness: 0.0,
            contrast: 0.0,
            saturation: 0.0,
            temperature: 0.0
        )
    }

    init(id: UUID = UUID(), sourceURL: URL, startTime: TimeInterval, duration: TimeInterval, transition: Transition = .crossDissolve) {
        self.id = id
        self.sourceURL = sourceURL
        self.startTime = startTime
        self.duration = duration
        self.transition = transition
    }
}
