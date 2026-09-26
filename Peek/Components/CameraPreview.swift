import AVFoundation
import SwiftUI

struct CameraPreview: UIViewRepresentable {
    let session: AVCaptureSession
    func makeUIView(context: Context) -> PreviewView {
        let view = PreviewView()
        view.previewLayer.videoGravity = .resizeAspectFill
        view.previewLayer.session = session
        return view
    }
    func updateUIView(_ uiView: PreviewView, context: Context) {}

    final class PreviewView: UIView {
        override class var layerClass: AnyClass { AVCaptureVideoPreviewLayer.self }
        var previewLayer: AVCaptureVideoPreviewLayer { layer as! AVCaptureVideoPreviewLayer }
    }
}

struct DemoCameraPreview: View {
    @State private var drift = false
    var body: some View {
        ZStack {
            LinearGradient(colors: [.indigo.opacity(0.8), .pink.opacity(0.55), .black], startPoint: drift ? .topLeading : .bottomTrailing, endPoint: drift ? .bottomTrailing : .topLeading)
            Image(systemName: "person.crop.circle.fill")
                .font(.system(size: 110, weight: .ultraLight)).foregroundStyle(.white.opacity(0.48))
            Text("SIMULATED REACTION").font(.caption2.weight(.semibold)).tracking(1.4)
                .foregroundStyle(.white.opacity(0.5)).frame(maxHeight: .infinity, alignment: .bottom).padding(18)
        }
        .onAppear { withAnimation(.easeInOut(duration: 3).repeatForever(autoreverses: true)) { drift = true } }
    }
}
