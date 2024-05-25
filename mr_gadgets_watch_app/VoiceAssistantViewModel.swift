import Foundation
import AVFoundation
import SwiftUI

class VoiceAssistantViewModel: ObservableObject {
    @Published var transcription: String = "Say 'Hey Assistant' to start"
    @Published var errorMessage: String?

    private var audioEngine: AVAudioEngine?
    private var recognizer: SFSpeechRecognizer?
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private var webSocketTask: URLSessionWebSocketTask?

    init() {
        setupAudioEngine()
    }

    private func setupAudioEngine() {
        audioEngine = AVAudioEngine()
    }

    func startListening() {
        do {
            try startRecording()
        } catch {
            errorMessage = "Failed to start recording: \(error.localizedDescription)"
        }
    }

    func stopListening() {
        audioEngine?.stop()
        recognitionRequest?.endAudio()
    }

    private func startRecording() throws {
        guard let audioEngine = audioEngine else {
            throw RecordingError.audioEngineUnavailable
        }

        recognizer = SFSpeechRecognizer()
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()

        guard let recognizer = recognizer, recognizer.isAvailable else {
            throw RecordingError.speechRecognizerUnavailable
        }
        guard let recognitionRequest = recognitionRequest else {
            throw RecordingError.recognitionRequestUnavailable
        }

        let inputNode = audioEngine.inputNode
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, _ in
            recognitionRequest.append(buffer)
        }

        audioEngine.prepare()
        try audioEngine.start()

        recognitionTask = recognizer.recognitionTask(with: recognitionRequest) { result, error in
            if let result = result {
                self.transcription = result.bestTranscription.formattedString
                if self.transcription.lowercased().contains("hey assistant") {
                    self.sendTranscriptionToServer(self.transcription)
                }
            }

            if error != nil || result?.isFinal == true {
                self.audioEngine?.stop()
                inputNode.removeTap(onBus: 0)
                self.recognitionRequest = nil
                self.recognitionTask = nil
            }
        }
    }

    private func sendTranscriptionToServer(_ transcription: String) {
        guard let url = URL(string: "wss://psh1ubvffs.loclx.io/ws") else {
            errorMessage = "Invalid server URL"
            return
        }

        webSocketTask = URLSession.shared.webSocketTask(with: url)
        webSocketTask?.resume()

        let message = URLSessionWebSocketTask.Message.string(transcription)
        webSocketTask?.send(message) { error in
            if let error = error {
                self.errorMessage = "WebSocket sending error: \(error.localizedDescription)"
            } else {
                self.receiveResponseFromServer()
            }
        }
    }

    private func receiveResponseFromServer() {
        webSocketTask?.receive { result in
            switch result {
            case .failure(let error):
                self.errorMessage = "WebSocket receiving error: \(error.localizedDescription)"
            case .success(let message):
                switch message {
                case .string(let text):
                    self.speak(text)
                case .data(let data):
                    print("Received data: \(data)")
                @unknown default:
                    fatalError()
                }
            }
        }
    }

    private func speak(_ text: String) {
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        let synthesizer = AVSpeechSynthesizer()
        synthesizer.speak(utterance)
    }
}

enum RecordingError: Error {
    case audioEngineUnavailable
    case speechRecognizerUnavailable
    case recognitionRequestUnavailable
}

