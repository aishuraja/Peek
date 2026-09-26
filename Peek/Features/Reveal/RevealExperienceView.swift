import SwiftUI
import UIKit

struct RevealExperienceView: View {
    enum Phase { case preparing, revealing, finishing, result }
    let peek: Peek
    @Bindable var appModel: AppModel
    @Environment(\.dismiss) private var dismiss
    @State private var posture = DuoPostureService()
    @State private var capture = ReactionCaptureService()
    @State private var phase: Phase = .preparing
    @State private var didFinish = false
    @State private var showReplay = false
    private var progress: Double { posture.revealProgress }

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            if phase == .result { resultView } else { revealStage }
        }
        .task { await prepareAndStart() }
        .onChange(of: posture.posture) { old, new in
            guard phase == .revealing else { return }
            if new == .partiallyOpen && old == .closed { UIImpactFeedbackGenerator(style: .soft).impactOccurred() }
            if new == .fullyOpen { finishReveal() }
        }
        .modifier(HingeObserver(posture: posture))
        .preferredColorScheme(.dark)
    }

    private var revealStage: some View {
        GeometryReader { proxy in
            ZStack {
                reactionPreview
                    .frame(width: progress > 0.22 ? 94 : proxy.size.width, height: progress > 0.22 ? 126 : proxy.size.height)
                    .clipShape(RoundedRectangle(cornerRadius: progress > 0.22 ? 28 : 0, style: .continuous))
                    .overlay(RoundedRectangle(cornerRadius: 28).stroke(.white.opacity(progress > 0.22 ? 0.16 : 0)))
                    .offset(x: progress > 0.22 ? proxy.size.width * 0.34 : 0, y: progress > 0.22 ? -proxy.size.height * 0.28 : 0).zIndex(2)
                DemoPhoto(name: peek.imageName)
                    .frame(width: proxy.size.width - 28, height: min(proxy.size.height * 0.67, 590))
                    .clipShape(RoundedRectangle(cornerRadius: 32, style: .continuous))
                    .blur(radius: 34 * (1 - progress)).brightness(-0.55 * (1 - progress)).scaleEffect(0.82 + progress * 0.18)
                    .mask(alignment: .leading) { Rectangle().frame(width: max(1, (proxy.size.width - 28) * progress)) }
                    .opacity(progress < 0.06 ? 0 : 1)
                    .overlay(alignment: .bottomLeading) { if progress > 0.65 { Text(peek.caption ?? "").font(.headline).padding(18) } }
                    .animation(.interactiveSpring(response: 0.42, dampingFraction: 0.86), value: progress)
                VStack {
                    HStack {
                        Button { dismiss() } label: { Image(systemName: "xmark").frame(width: 42, height: 42).background(.ultraThinMaterial, in: Circle()) }
                        Spacer()
                        Label(capture.isRecording ? "REC" : "READY", systemImage: "circle.fill").font(.caption.bold())
                            .foregroundStyle(capture.isRecording ? Color.peekPink : .secondary).padding(.horizontal, 13).padding(.vertical, 9).background(.ultraThinMaterial, in: Capsule())
                    }
                    Spacer(); instruction
                    #if targetEnvironment(simulator)
                    if !posture.hasRealHinge && phase == .revealing { demoControl }
                    #endif
                }.padding(20)
            }
        }.animation(.spring(response: 0.5, dampingFraction: 0.84), value: progress)
    }

    @ViewBuilder private var reactionPreview: some View {
        if capture.usesDemoCamera { DemoCameraPreview() } else { CameraPreview(session: capture.session) }
    }

    private var instruction: some View {
        VStack(spacing: 7) {
            Text(phase == .preparing ? "Ready? 👀" : instructionTitle).font(.title2.bold())
            Text(phase == .preparing ? "Preparing your reaction camera" : instructionSubtitle).font(.subheadline).foregroundStyle(.secondary)
        }.padding(.horizontal, 22).padding(.vertical, 15).background(.ultraThinMaterial, in: Capsule())
    }

    private var instructionTitle: String {
        if phase == .finishing { return "Got it 💗" }
        if progress < 0.12 { return "Unfold to reveal" }
        if progress < 0.72 { return "Keep going…" }
        if progress < 0.98 { return "Almost there 👀" }
        return "Surprise!"
    }
    private var instructionSubtitle: String { posture.hasRealHinge ? "The reveal follows your iPhone Duo" : "Duo hinge unavailable · use demo control" }

    #if targetEnvironment(simulator)
    private var demoControl: some View {
        VStack(spacing: 7) {
            Slider(value: Binding(get: { progress }, set: { posture.setDemoProgress($0) }), in: 0...1).tint(.peekPink)
            Text("DEMO HINGE").font(.caption2.bold()).tracking(1.2).foregroundStyle(.secondary)
        }.padding(14).background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 18))
    }
    #endif

    private var resultView: some View {
        VStack(spacing: 20) {
            HStack {
                Button { dismiss() } label: { Image(systemName: "xmark").frame(width: 42, height: 42).background(.white.opacity(0.1), in: Circle()) }
                Spacer(); Text("Peek revealed").font(.subheadline.weight(.semibold)).foregroundStyle(.secondary); Spacer(); Color.clear.frame(width: 42, height: 42)
            }.padding(.horizontal, 20)
            ZStack(alignment: .bottomTrailing) {
                DemoPhoto(name: peek.imageName).clipShape(RoundedRectangle(cornerRadius: 32, style: .continuous))
                reactionPreview.frame(width: 112, height: 150).clipShape(RoundedRectangle(cornerRadius: 25, style: .continuous))
                    .overlay(RoundedRectangle(cornerRadius: 25).stroke(.white, lineWidth: 3)).shadow(color: .black.opacity(0.5), radius: 15).padding(15).scaleEffect(showReplay ? 1.04 : 1)
            }.padding(.horizontal, 16)
            VStack(spacing: 6) { Text("Reaction sent 💗").font(.title2.bold()); Text("Aish gets the real moment, not an emoji.").font(.subheadline).foregroundStyle(.secondary) }
            HStack(spacing: 12) {
                Button { withAnimation(.bouncy) { showReplay.toggle() } } label: { Label("Replay reaction", systemImage: "play.fill").frame(maxWidth: .infinity).padding(.vertical, 14).background(.white.opacity(0.1), in: Capsule()) }
                Button { dismiss() } label: { Text("Done").frame(maxWidth: .infinity).padding(.vertical, 14).background(Color.peekPink, in: Capsule()) }
            }.font(.subheadline.bold()).foregroundStyle(.white).padding(.horizontal, 20)
            Spacer(minLength: 10)
        }.padding(.top, 8).transition(.opacity.combined(with: .scale(scale: 0.97)))
    }

    private func prepareAndStart() async {
        await capture.prepare(); try? capture.startRecording()
        withAnimation(.easeInOut(duration: 0.35)) { phase = .revealing }
    }
    private func finishReveal() {
        guard !didFinish else { return }
        didFinish = true; phase = .finishing
        UINotificationFeedbackGenerator().notificationOccurred(.success)
        Task {
            try? await Task.sleep(for: .seconds(1.6))
            appModel.capturedReactionURL = await capture.stopRecording(); appModel.incoming.isOpened = true
            withAnimation(.spring(response: 0.55, dampingFraction: 0.86)) { phase = .result }
        }
    }
}

private struct HingeObserver: ViewModifier {
    let posture: DuoPostureService
    func body(content: Content) -> some View {
        content.onHingeChange { _, context in posture.consume(context) }
    }
}
