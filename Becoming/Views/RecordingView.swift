import SwiftUI
import AVFoundation

struct RecordingView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var videoManager: VideoManager
    @EnvironmentObject var streakManager: StreakManager
    @EnvironmentObject var appState: AppState
    
    @StateObject private var cameraManager = CameraManager()
    @State private var showingRetakeAlert = false
    @State private var hasAttemptedRecording = false
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            VStack {
                // Header
                HStack {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(.white)
                    
                    Spacer()
                    
                    if appState.oneTakeMode && hasAttemptedRecording {
                        Text("One Take Mode")
                            .font(.caption)
                            .foregroundColor(.orange)
                    }
                }
                .padding()
                
                // Camera Preview
                CameraPreviewView(cameraManager: cameraManager)
                    .aspectRatio(9/16, contentMode: .fit)
                    .cornerRadius(16)
                    .padding(.horizontal)
                
                Spacer()
                
                // Recording Controls
                VStack(spacing: 20) {
                    // Timer
                    if videoManager.isRecording {
                        Text(formatTime(videoManager.recordingDuration))
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                    }
                    
                    // Record Button
                    Button(action: toggleRecording) {
                        ZStack {
                            Circle()
                                .fill(videoManager.isRecording ? Color.red : Color.white)
                                .frame(width: 80, height: 80)
                            
                            if videoManager.isRecording {
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(Color.white)
                                    .frame(width: 24, height: 24)
                            }
                        }
                    }
                    .disabled(appState.oneTakeMode && hasAttemptedRecording && !videoManager.isRecording)
                    .opacity((appState.oneTakeMode && hasAttemptedRecording && !videoManager.isRecording) ? 0.5 : 1.0)
                    
                    // Instructions
                    Text(getInstructionText())
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                .padding(.bottom, 40)
            }
        }
        .onAppear {
            cameraManager.setupCamera()
        }
        .alert("One Take Mode", isPresented: $showingRetakeAlert) {
            Button("Keep Recording", role: .cancel) { }
            Button("Save & Exit") {
                saveAndExit()
            }
        } message: {
            Text("You can only record once in One Take Mode. Save this recording or keep going?")
        }
    }
    
    private func toggleRecording() {
        if videoManager.isRecording {
            videoManager.stopRecording()
            cameraManager.stopRecording { url in
                if let url = url {
                    videoManager.saveVideo(url: url)
                    streakManager.recordVideo()
                    
                    if appState.oneTakeMode {
                        showingRetakeAlert = true
                    }
                }
            }
        } else {
            if appState.oneTakeMode && hasAttemptedRecording {
                return // Can't record again in one take mode
            }
            
            hasAttemptedRecording = true
            videoManager.startRecording()
            cameraManager.startRecording()
        }
    }
    
    private func saveAndExit() {
        dismiss()
    }
    
    private func getInstructionText() -> String {
        if appState.oneTakeMode && hasAttemptedRecording && !videoManager.isRecording {
            return "One take complete. Tap 'Save & Exit' to finish."
        } else if videoManager.isRecording {
            return "Recording... Tap to stop (max 10 minutes)"
        } else {
            return "Tap to start recording your daily log"
        }
    }
    
    private func formatTime(_ seconds: TimeInterval) -> String {
        let minutes = Int(seconds) / 60
        let seconds = Int(seconds) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

struct CameraPreviewView: UIViewRepresentable {
    let cameraManager: CameraManager
    
    func makeUIView(context: Context) -> UIView {
        return cameraManager.previewView
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {}
}

class CameraManager: NSObject, ObservableObject {
    let previewView = UIView()
    private var captureSession: AVCaptureSession?
    private var videoOutput: AVCaptureMovieFileOutput?
    private var previewLayer: AVCaptureVideoPreviewLayer?
    private var completionHandler: ((URL?) -> Void)?
    
    func setupCamera() {
        captureSession = AVCaptureSession()
        
        guard let captureSession = captureSession else { return }
        
        captureSession.beginConfiguration()
        
        // Add video input
        guard let videoDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front),
              let videoInput = try? AVCaptureDeviceInput(device: videoDevice) else { return }
        
        if captureSession.canAddInput(videoInput) {
            captureSession.addInput(videoInput)
        }
        
        // Add audio input
        guard let audioDevice = AVCaptureDevice.default(for: .audio),
              let audioInput = try? AVCaptureDeviceInput(device: audioDevice) else { return }
        
        if captureSession.canAddInput(audioInput) {
            captureSession.addInput(audioInput)
        }
        
        // Add video output
        videoOutput = AVCaptureMovieFileOutput()
        if let videoOutput = videoOutput, captureSession.canAddOutput(videoOutput) {
            captureSession.addOutput(videoOutput)
        }
        
        captureSession.commitConfiguration()
        
        // Setup preview layer
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer?.videoGravity = .resizeAspectFill
        previewLayer?.frame = previewView.bounds
        
        if let previewLayer = previewLayer {
            previewView.layer.addSublayer(previewLayer)
        }
        
        DispatchQueue.global(qos: .userInitiated).async {
            captureSession.startRunning()
        }
    }
    
    func startRecording() {
        guard let videoOutput = videoOutput else { return }
        
        let tempURL = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString)
            .appendingPathExtension("mov")
        
        videoOutput.startRecording(to: tempURL, recordingDelegate: self)
    }
    
    func stopRecording(completion: @escaping (URL?) -> Void) {
        completionHandler = completion
        videoOutput?.stopRecording()
    }
}

extension CameraManager: AVCaptureFileOutputRecordingDelegate {
    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
        completionHandler?(error == nil ? outputFileURL : nil)
        completionHandler = nil
    }
}

#Preview {
    RecordingView()
        .environmentObject(VideoManager())
        .environmentObject(StreakManager())
        .environmentObject(AppState())
}
