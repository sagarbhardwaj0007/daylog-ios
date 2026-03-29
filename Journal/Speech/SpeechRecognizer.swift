import Foundation
import Speech
import AVFoundation

@Observable
final class SpeechRecognizer: @unchecked Sendable {

    // MARK: - Observable state (MainActor)
    var transcript: String = ""
    var isRecording: Bool = false
    var permissionDenied: Bool = false

    // MARK: - Audio engine internals
    private var sfRecognizer: SFSpeechRecognizer?
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()

    // MARK: - Permissions

    func requestPermissions() async -> Bool {
        let speechStatus: SFSpeechRecognizerAuthorizationStatus = await withCheckedContinuation { cont in
            SFSpeechRecognizer.requestAuthorization { cont.resume(returning: $0) }
        }
        guard speechStatus == .authorized else {
            permissionDenied = true
            return false
        }
        let micGranted = await AVAudioApplication.requestRecordPermission()
        if !micGranted { permissionDenied = true }
        return micGranted
    }

    // MARK: - Recording lifecycle

    func startRecording() {
        guard !isRecording else { return }

        transcript = ""
        permissionDenied = false

        let recognizer = SFSpeechRecognizer(locale: .current)
        sfRecognizer = recognizer

        guard recognizer?.isAvailable == true else { return }

        let session = AVAudioSession.sharedInstance()
        do {
            try session.setCategory(.record, mode: .measurement, options: .duckOthers)
            try session.setActive(true, options: .notifyOthersOnDeactivation)
        } catch { return }

        let req = SFSpeechAudioBufferRecognitionRequest()
        req.shouldReportPartialResults = true
        req.addsPunctuation = true
        recognitionRequest = req

        let inputNode = audioEngine.inputNode
        let format = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: format) { [weak self] buffer, _ in
            self?.recognitionRequest?.append(buffer)
        }

        do {
            audioEngine.prepare()
            try audioEngine.start()
        } catch {
            stopRecording()
            return
        }

        recognitionTask = recognizer?.recognitionTask(with: req) { [weak self] result, error in
            Task { @MainActor [weak self] in
                guard let self else { return }
                if let result {
                    self.transcript = result.bestTranscription.formattedString
                }
                if let error {
                    let code = (error as NSError).code
                    // 301 = cancelled/aborted, 203 = no speech detected — both are expected
                    if code != 301 && code != 203 {
                        self.stopRecording()
                    }
                }
                if result?.isFinal == true {
                    self.isRecording = false
                }
            }
        }

        isRecording = true
    }

    func stopRecording() {
        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: 0)
        recognitionRequest?.endAudio()
        recognitionTask?.finish()
        recognitionRequest = nil
        recognitionTask = nil
        isRecording = false
        try? AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
    }
}
