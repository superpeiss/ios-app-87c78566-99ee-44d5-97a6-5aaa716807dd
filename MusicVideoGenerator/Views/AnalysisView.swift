import SwiftUI

struct AnalysisView: View {
    let progress: Double

    var body: some View {
        VStack(spacing: 30) {
            Spacer()

            // Animated analyzing icon
            ZStack {
                Circle()
                    .stroke(Color.blue.opacity(0.2), lineWidth: 4)
                    .frame(width: 120, height: 120)

                Circle()
                    .trim(from: 0, to: progress)
                    .stroke(Color.blue, style: StrokeStyle(lineWidth: 4, lineCap: .round))
                    .frame(width: 120, height: 120)
                    .rotationEffect(.degrees(-90))
                    .animation(.easeInOut, value: progress)

                Image(systemName: "waveform.circle.fill")
                    .font(.system(size: 50))
                    .foregroundColor(.blue)
            }

            VStack(spacing: 12) {
                Text("Analyzing Your Song")
                    .font(.title2)
                    .fontWeight(.bold)

                Text(statusMessage)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)

                Text("\(Int(progress * 100))%")
                    .font(.headline)
                    .foregroundColor(.blue)
            }

            Spacer()
        }
        .padding()
    }

    private var statusMessage: String {
        switch progress {
        case 0..<0.3:
            return "Extracting audio features..."
        case 0.3..<0.6:
            return "Analyzing tempo and energy..."
        case 0.6..<0.8:
            return "Transcribing lyrics..."
        case 0.8..<0.95:
            return "Generating video clips..."
        default:
            return "Finalizing your project..."
        }
    }
}

#Preview {
    AnalysisView(progress: 0.65)
}
