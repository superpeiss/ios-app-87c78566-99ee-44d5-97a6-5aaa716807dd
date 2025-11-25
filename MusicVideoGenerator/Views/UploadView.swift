import SwiftUI
import UniformTypeIdentifiers

struct UploadView: View {
    let onAudioSelected: (URL) -> Void

    @State private var showingFilePicker = false
    @State private var showingError = false
    @State private var errorMessage = ""

    var body: some View {
        VStack(spacing: 30) {
            Spacer()

            Image(systemName: "music.note.list")
                .font(.system(size: 80))
                .foregroundColor(.blue)

            VStack(spacing: 10) {
                Text("Create Your Music Video")
                    .font(.title)
                    .fontWeight(.bold)

                Text("Upload an audio file to get started")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }

            VStack(spacing: 16) {
                Button(action: {
                    showingFilePicker = true
                }) {
                    HStack {
                        Image(systemName: "arrow.up.circle.fill")
                        Text("Upload Audio File")
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                }

                Text("Supported formats: MP3, M4A, WAV")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()

            VStack(alignment: .leading, spacing: 12) {
                FeatureRow(icon: "waveform", text: "Automatic audio analysis")
                FeatureRow(icon: "text.bubble", text: "Lyrics transcription")
                FeatureRow(icon: "film", text: "AI-powered video generation")
                FeatureRow(icon: "slider.horizontal.3", text: "Professional editing tools")
            }
            .padding()
            .background(Color.gray.opacity(0.05))
            .cornerRadius(10)

            Spacer()
        }
        .padding()
        .sheet(isPresented: $showingFilePicker) {
            DocumentPicker(
                contentTypes: [.audio],
                onDocumentPicked: { url in
                    handleSelectedFile(url)
                }
            )
        }
        .alert("Error", isPresented: $showingError) {
            Button("OK") {}
        } message: {
            Text(errorMessage)
        }
    }

    private func handleSelectedFile(_ url: URL) {
        // Validate file
        guard url.pathExtension.lowercased() == "mp3" ||
              url.pathExtension.lowercased() == "m4a" ||
              url.pathExtension.lowercased() == "wav" else {
            errorMessage = "Unsupported file format. Please select an MP3, M4A, or WAV file."
            showingError = true
            return
        }

        onAudioSelected(url)
    }
}

struct FeatureRow: View {
    let icon: String
    let text: String

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(.blue)
                .frame(width: 24)

            Text(text)
                .font(.subheadline)
        }
    }
}

struct DocumentPicker: UIViewControllerRepresentable {
    let contentTypes: [UTType]
    let onDocumentPicked: (URL) -> Void

    func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
        let picker = UIDocumentPickerViewController(forOpeningContentTypes: contentTypes)
        picker.delegate = context.coordinator
        picker.allowsMultipleSelection = false
        return picker
    }

    func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(onDocumentPicked: onDocumentPicked)
    }

    class Coordinator: NSObject, UIDocumentPickerDelegate {
        let onDocumentPicked: (URL) -> Void

        init(onDocumentPicked: @escaping (URL) -> Void) {
            self.onDocumentPicked = onDocumentPicked
        }

        func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
            guard let url = urls.first else { return }

            // Copy to app's documents directory
            let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let destinationURL = documentsPath.appendingPathComponent(url.lastPathComponent)

            do {
                // Remove existing file if present
                try? FileManager.default.removeItem(at: destinationURL)

                // Copy file
                try FileManager.default.copyItem(at: url, to: destinationURL)

                onDocumentPicked(destinationURL)
            } catch {
                print("Error copying file: \(error)")
            }
        }
    }
}

#Preview {
    UploadView { _ in }
}
