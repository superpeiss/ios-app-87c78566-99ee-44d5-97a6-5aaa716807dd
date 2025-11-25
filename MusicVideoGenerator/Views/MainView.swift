import SwiftUI

struct MainView: View {
    @StateObject private var viewModel = MainViewModel()
    @State private var showingEditor = false

    var body: some View {
        NavigationView {
            ZStack {
                if let project = viewModel.currentProject {
                    ProjectReadyView(
                        project: project,
                        showEditor: $showingEditor,
                        onReset: {
                            viewModel.resetProject()
                        }
                    )
                } else if viewModel.isAnalyzing {
                    AnalysisView(progress: viewModel.analysisProgress)
                } else {
                    UploadView { audioURL in
                        Task {
                            await viewModel.createProject(from: audioURL)
                        }
                    }
                }
            }
            .navigationTitle("Music Video Generator")
            .alert("Error", isPresented: $viewModel.showError) {
                Button("OK") {
                    viewModel.showError = false
                }
            } message: {
                Text(viewModel.errorMessage ?? "An unknown error occurred")
            }
            .sheet(isPresented: $showingEditor) {
                if let project = viewModel.currentProject {
                    EditorView(project: project)
                }
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

struct ProjectReadyView: View {
    let project: VideoProject
    @Binding var showEditor: Bool
    let onReset: () -> Void

    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 60))
                .foregroundColor(.green)

            Text("Video Ready!")
                .font(.title)
                .fontWeight(.bold)

            if let analysis = project.song.analysis {
                VStack(alignment: .leading, spacing: 12) {
                    InfoRow(label: "Tempo", value: "\(Int(analysis.tempo)) BPM")
                    InfoRow(label: "Energy", value: String(format: "%.0f%%", analysis.energy * 100))
                    InfoRow(label: "Mood", value: analysis.mood.rawValue)
                    InfoRow(label: "Clips", value: "\(project.clips.count)")
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(10)
            }

            Button(action: {
                showEditor = true
            }) {
                HStack {
                    Image(systemName: "pencil")
                    Text("Edit Video")
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)
            }

            Button(action: onReset) {
                Text("Start New Project")
                    .foregroundColor(.blue)
            }
        }
        .padding()
    }
}

struct InfoRow: View {
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

#Preview {
    MainView()
}
