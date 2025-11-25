# Music Video Generator

An iOS application that automatically generates unique music videos based on audio file analysis.

## Features

- **Audio Analysis**: Automatically analyzes tempo, energy, and emotional characteristics of uploaded songs
- **Lyrics Transcription**: Transcribes lyrics and identifies key themes using language processing
- **Smart Video Generation**: Generates videos by sourcing stock footage and AI-generated visuals
- **Professional Editor**: Fine-tune results with clip swapping, transition adjustments, and color grading
- **High-Quality Export**: Export final videos in Full HD (1920x1080)

## Requirements

- iOS 15.0+
- Xcode 13.0+
- XcodeGen (for project generation)

## Setup

1. Install XcodeGen:
   ```bash
   brew install xcodegen
   ```

2. Generate Xcode project:
   ```bash
   cd MusicVideoGenerator
   xcodegen generate
   ```

3. Open the project:
   ```bash
   open MusicVideoGenerator.xcodeproj
   ```

4. Build and run on your device or simulator

## Architecture

The app follows MVVM architecture with the following structure:

- **Models**: Data models for Song, AudioAnalysis, VideoClip, and VideoProject
- **Services**: Business logic for audio analysis, lyrics transcription, media fetching, and video generation
- **ViewModels**: Presentation logic connecting views with services
- **Views**: SwiftUI views for upload, analysis, editing, and export

## Permissions

The app requires the following permissions:
- Microphone access (for audio analysis)
- Photo Library access (for saving exported videos)

## License

MIT License
