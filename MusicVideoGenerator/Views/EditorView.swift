import SwiftUI

struct EditorView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel: EditorViewModel
    @StateObject private var exportViewModel = ExportViewModel()
    @State private var showingExport = false

    init(project: VideoProject) {
        _viewModel = StateObject(wrappedValue: EditorViewModel(project: project))
    }

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Preview area
                PreviewArea(project: viewModel.project)
                    .frame(height: 250)
                    .background(Color.black)

                Divider()

                // Timeline
                TimelineView(
                    clips: viewModel.project.clips,
                    selectedIndex: viewModel.selectedClipIndex,
                    onClipSelected: { index in
                        viewModel.selectClip(at: index)
                    },
                    onClipDeleted: { index in
                        viewModel.removeClip(at: index)
                    },
                    onClipMoved: { source, destination in
                        viewModel.moveClip(from: source, to: destination)
                    }
                )
                .frame(height: 150)
                .background(Color.gray.opacity(0.1))

                Divider()

                // Controls
                if let selectedIndex = viewModel.selectedClipIndex {
                    ClipControlsView(
                        clip: viewModel.project.clips[selectedIndex],
                        onTransitionChanged: { transition in
                            viewModel.updateTransition(for: selectedIndex, transition: transition)
                        },
                        onColorGradeChanged: { colorGrade in
                            viewModel.updateColorGrade(for: selectedIndex, colorGrade: colorGrade)
                        }
                    )
                    .padding()
                } else {
                    Text("Select a clip to edit")
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
            .navigationTitle("Editor")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Export") {
                        showingExport = true
                    }
                    .fontWeight(.semibold)
                }
            }
            .sheet(isPresented: $showingExport) {
                ExportView(project: viewModel.project, viewModel: exportViewModel)
            }
        }
    }
}

struct PreviewArea: View {
    let project: VideoProject

    var body: some View {
        ZStack {
            Color.black

            VStack {
                Image(systemName: "play.rectangle.fill")
                    .font(.system(size: 60))
                    .foregroundColor(.white.opacity(0.7))

                Text("Preview")
                    .foregroundColor(.white.opacity(0.7))
                    .font(.caption)
            }
        }
    }
}

struct TimelineView: View {
    let clips: [VideoClip]
    let selectedIndex: Int?
    let onClipSelected: (Int) -> Void
    let onClipDeleted: (Int) -> Void
    let onClipMoved: (IndexSet, Int) -> Void

    var body: some View {
        ScrollView(.horizontal, showsIndicators: true) {
            HStack(spacing: 8) {
                ForEach(Array(clips.enumerated()), id: \.element.id) { index, clip in
                    ClipThumbnail(
                        clip: clip,
                        isSelected: selectedIndex == index,
                        onTap: {
                            onClipSelected(index)
                        },
                        onDelete: {
                            onClipDeleted(index)
                        }
                    )
                }
            }
            .padding()
        }
    }
}

struct ClipThumbnail: View {
    let clip: VideoClip
    let isSelected: Bool
    let onTap: () -> Void
    let onDelete: () -> Void

    var body: some View {
        VStack(spacing: 4) {
            ZStack(alignment: .topTrailing) {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 100, height: 80)
                    .overlay(
                        Image(systemName: "film")
                            .foregroundColor(.white)
                    )

                Button(action: onDelete) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.red)
                        .background(Color.white.clipShape(Circle()))
                }
                .padding(4)
            }
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(isSelected ? Color.blue : Color.clear, lineWidth: 3)
            )

            Text(String(format: "%.1fs", clip.duration))
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .onTapGesture(perform: onTap)
    }
}

struct ClipControlsView: View {
    let clip: VideoClip
    let onTransitionChanged: (VideoClip.Transition) -> Void
    let onColorGradeChanged: (VideoClip.ColorGrade) -> Void

    @State private var selectedTab = 0
    @State private var brightness: Double = 0.0
    @State private var contrast: Double = 0.0
    @State private var saturation: Double = 0.0
    @State private var temperature: Double = 0.0

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Picker("Controls", selection: $selectedTab) {
                Text("Transition").tag(0)
                Text("Color Grade").tag(1)
            }
            .pickerStyle(SegmentedPickerStyle())

            if selectedTab == 0 {
                TransitionControls(
                    selectedTransition: clip.transition,
                    onTransitionChanged: onTransitionChanged
                )
            } else {
                ColorGradeControls(
                    brightness: $brightness,
                    contrast: $contrast,
                    saturation: $saturation,
                    temperature: $temperature,
                    onChange: {
                        let colorGrade = VideoClip.ColorGrade(
                            brightness: brightness,
                            contrast: contrast,
                            saturation: saturation,
                            temperature: temperature
                        )
                        onColorGradeChanged(colorGrade)
                    }
                )
            }
        }
    }
}

struct TransitionControls: View {
    let selectedTransition: VideoClip.Transition
    let onTransitionChanged: (VideoClip.Transition) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Transition Effect")
                .font(.headline)

            ForEach(VideoClip.Transition.allCases, id: \.self) { transition in
                Button(action: {
                    onTransitionChanged(transition)
                }) {
                    HStack {
                        Image(systemName: selectedTransition == transition ? "checkmark.circle.fill" : "circle")
                            .foregroundColor(selectedTransition == transition ? .blue : .gray)

                        Text(transition.rawValue)
                            .foregroundColor(.primary)

                        Spacer()
                    }
                    .padding(.vertical, 8)
                }
            }
        }
    }
}

struct ColorGradeControls: View {
    @Binding var brightness: Double
    @Binding var contrast: Double
    @Binding var saturation: Double
    @Binding var temperature: Double
    let onChange: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Color Grading")
                .font(.headline)

            SliderControl(
                label: "Brightness",
                value: $brightness,
                range: -1.0...1.0,
                onChange: onChange
            )

            SliderControl(
                label: "Contrast",
                value: $contrast,
                range: -1.0...1.0,
                onChange: onChange
            )

            SliderControl(
                label: "Saturation",
                value: $saturation,
                range: -1.0...1.0,
                onChange: onChange
            )

            SliderControl(
                label: "Temperature",
                value: $temperature,
                range: -1.0...1.0,
                onChange: onChange
            )
        }
    }
}

struct SliderControl: View {
    let label: String
    @Binding var value: Double
    let range: ClosedRange<Double>
    let onChange: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(label)
                    .font(.subheadline)
                Spacer()
                Text(String(format: "%.2f", value))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Slider(value: $value, in: range, onEditingChanged: { editing in
                if !editing {
                    onChange()
                }
            })
        }
    }
}

#Preview {
    EditorView(project: VideoProject(
        song: Song(url: URL(string: "file:///test.mp3")!, title: "Test", duration: 180),
        clips: []
    ))
}
