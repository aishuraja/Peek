import AVFoundation
import Observation

@MainActor
protocol ReactionCapturing: AnyObject {
    var session: AVCaptureSession { get }
    var isPrepared: Bool { get }
    var isRecording: Bool { get }
    var usesDemoCamera: Bool { get }
    func prepare() async
    func startRecording() throws
    func stopRecording() async -> URL?
}

@MainActor
@Observable
final class ReactionCaptureService: NSObject, ReactionCapturing {
    let session = AVCaptureSession()
    private(set) var isPrepared = false
    private(set) var isRecording = false
    private(set) var usesDemoCamera = false
    @ObservationIgnored private let movieOutput = AVCaptureMovieFileOutput()
    @ObservationIgnored private var continuation: CheckedContinuation<URL?, Never>?

    func prepare() async {
        #if targetEnvironment(simulator)
        guard AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front) != nil else {
            usesDemoCamera = true; isPrepared = true; return
        }
        #endif
        let allowed: Bool
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized: allowed = true
        case .notDetermined: allowed = await AVCaptureDevice.requestAccess(for: .video)
        default: allowed = false
        }
        guard allowed else { usesDemoCamera = true; isPrepared = true; return }
        do {
            session.beginConfiguration()
            session.sessionPreset = .high
            guard let camera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front) else {
                session.commitConfiguration(); usesDemoCamera = true; isPrepared = true; return
            }
            let input = try AVCaptureDeviceInput(device: camera)
            if session.canAddInput(input) { session.addInput(input) }
            if session.canAddOutput(movieOutput) { session.addOutput(movieOutput) }
            session.commitConfiguration()
            session.startRunning()
            isPrepared = true
        } catch {
            session.commitConfiguration(); usesDemoCamera = true; isPrepared = true
        }
    }

    func startRecording() throws {
        guard !isRecording else { return }
        isRecording = true
        guard !usesDemoCamera else { return }
        let url = FileManager.default.temporaryDirectory.appendingPathComponent("peek-reaction-\(UUID().uuidString).mov")
        movieOutput.startRecording(to: url, recordingDelegate: self)
    }

    func stopRecording() async -> URL? {
        guard isRecording else { return nil }
        isRecording = false
        guard !usesDemoCamera, movieOutput.isRecording else { return nil }
        return await withCheckedContinuation { continuation in
            self.continuation = continuation
            movieOutput.stopRecording()
        }
    }
}

extension ReactionCaptureService: AVCaptureFileOutputRecordingDelegate {
    nonisolated func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
        Task { @MainActor in
            continuation?.resume(returning: error == nil ? outputFileURL : nil)
            continuation = nil
        }
    }
}
