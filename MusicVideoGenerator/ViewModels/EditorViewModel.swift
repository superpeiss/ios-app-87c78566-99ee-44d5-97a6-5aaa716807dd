import Foundation
import SwiftUI

@MainActor
class EditorViewModel: ObservableObject {
    @Published var project: VideoProject
    @Published var selectedClipIndex: Int?
    @Published var isModified = false

    init(project: VideoProject) {
        self.project = project
    }

    func updateClip(at index: Int, with clip: VideoClip) {
        project.updateClip(at: index, with: clip)
        isModified = true
    }

    func removeClip(at index: Int) {
        project.removeClip(at: index)
        isModified = true
        if selectedClipIndex == index {
            selectedClipIndex = nil
        }
    }

    func addClip(_ clip: VideoClip) {
        project.addClip(clip)
        isModified = true
    }

    func moveClip(from source: IndexSet, to destination: Int) {
        project.clips.move(fromOffsets: source, toOffset: destination)
        isModified = true
    }

    func updateTransition(for index: Int, transition: VideoClip.Transition) {
        guard index < project.clips.count else { return }
        var clip = project.clips[index]
        clip.transition = transition
        updateClip(at: index, with: clip)
    }

    func updateColorGrade(for index: Int, colorGrade: VideoClip.ColorGrade) {
        guard index < project.clips.count else { return }
        var clip = project.clips[index]
        clip.colorGrade = colorGrade
        updateClip(at: index, with: clip)
    }

    func selectClip(at index: Int?) {
        selectedClipIndex = index
    }
}
