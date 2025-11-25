import Foundation

struct VideoProject: Identifiable, Codable {
    let id: UUID
    var song: Song
    var clips: [VideoClip]
    var createdAt: Date
    var modifiedAt: Date

    init(id: UUID = UUID(), song: Song, clips: [VideoClip] = []) {
        self.id = id
        self.song = song
        self.clips = clips
        self.createdAt = Date()
        self.modifiedAt = Date()
    }

    mutating func updateClip(at index: Int, with clip: VideoClip) {
        guard index < clips.count else { return }
        clips[index] = clip
        modifiedAt = Date()
    }

    mutating func removeClip(at index: Int) {
        guard index < clips.count else { return }
        clips.remove(at: index)
        modifiedAt = Date()
    }

    mutating func addClip(_ clip: VideoClip) {
        clips.append(clip)
        modifiedAt = Date()
    }
}
