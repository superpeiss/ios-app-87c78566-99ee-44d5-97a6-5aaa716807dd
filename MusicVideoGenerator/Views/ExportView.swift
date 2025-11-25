import SwiftUI

struct ExportView: View {
    @Environment(\.dismiss) private var dismiss
    let project: VideoProject
    @ObservedObject var viewModel: ExportViewModel

    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                if viewModel.isExporting {
                    ExportingView(progress: viewModel.exportProgress)
                } else if viewModel.exportCompleted {
                    ExportCompletedView(
                        onSaveToLibrary: {
                            Task {
                                await viewModel.saveToPhotoLibrary()
                            }
                        },
                        onDone: {
                            dismiss()
                        }
                    )
                } else {
                    ExportSetupView(
                        project: project,
                        onExport: {
                            Task {
                                await viewModel.exportVideo(project: project)
                            }
                        }
                    )
                }
            }
            .padding()
            .navigationTitle("Export Video")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    if !viewModel.isExporting {
                        Button("Cancel") {
                            dismiss()
                        }
                    }
                }
            }
            .alert("Error", isPresented: $viewModel.showError) {
                Button("OK") {
                    viewModel.showError = false
                }
            } message: {
                Text(viewModel.exportError ?? "An unknown error occurred")
            }
        }
    }
}

struct ExportSetupView: View {
    let project: VideoProject
    let onExport: () -> Void

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            Image(systemName: "square.and.arrow.up.fill")
                .font(.system(size: 60))
                .foregroundColor(.blue)

            VStack(spacing: 12) {
                Text("Ready to Export")
                    .font(.title2)
                    .fontWeight(.bold)

                Text("Your music video will be rendered and saved")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }

            VStack(alignment: .leading, spacing: 12) {
                ExportInfoRow(label: "Song", value: project.song.title)
                ExportInfoRow(label: "Duration", value: formatDuration(project.song.duration))
                ExportInfoRow(label: "Clips", value: "\(project.clips.count)")
                ExportInfoRow(label: "Resolution", value: "1920x1080 (Full HD)")
            }
            .padding()
            .background(Color.gray.opacity(0.1))
            .cornerRadius(10)

            Button(action: onExport) {
                HStack {
                    Image(systemName: "arrow.down.circle.fill")
                    Text("Export Video")
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)
            }

            Spacer()
        }
    }

    private func formatDuration(_ duration: TimeInterval) -> String {
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}

struct ExportInfoRow: View {
    let label: String
    let value: String

    var body: some View {
        HStack {
            Text(label)
                .fontWeight(.medium)
            Spacer()
            Text(value)
                .foregroundColor(.secondary)
        }
    }
}

struct ExportingView: View {
    let progress: Double

    var body: some View {
        VStack(spacing: 30) {
            Spacer()

            ZStack {
                Circle()
                    .stroke(Color.blue.opacity(0.2), lineWidth: 8)
                    .frame(width: 140, height: 140)

                Circle()
                    .trim(from: 0, to: progress)
                    .stroke(Color.blue, style: StrokeStyle(lineWidth: 8, lineCap: .round))
                    .frame(width: 140, height: 140)
                    .rotationEffect(.degrees(-90))
                    .animation(.easeInOut, value: progress)

                VStack {
                    Text("\(Int(progress * 100))%")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.blue)
                }
            }

            VStack(spacing: 12) {
                Text("Exporting Video")
                    .font(.title2)
                    .fontWeight(.bold)

                Text("This may take a few moments...")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }

            Spacer()
        }
    }
}

struct ExportCompletedView: View {
    let onSaveToLibrary: () -> Void
    let onDone: () -> Void

    var body: some View {
        VStack(spacing: 30) {
            Spacer()

            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 80))
                .foregroundColor(.green)

            VStack(spacing: 12) {
                Text("Export Complete!")
                    .font(.title)
                    .fontWeight(.bold)

                Text("Your music video has been successfully created")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }

            VStack(spacing: 12) {
                Button(action: onSaveToLibrary) {
                    HStack {
                        Image(systemName: "square.and.arrow.down")
                        Text("Save to Photo Library")
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                }

                Button(action: onDone) {
                    Text("Done")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.gray.opacity(0.2))
                        .foregroundColor(.blue)
                        .cornerRadius(10)
                }
            }

            Spacer()
        }
    }
}

#Preview {
    ExportView(
        project: VideoProject(
            song: Song(url: URL(string: "file:///test.mp3")!, title: "Test Song", duration: 180),
            clips: []
        ),
        viewModel: ExportViewModel()
    )
}
