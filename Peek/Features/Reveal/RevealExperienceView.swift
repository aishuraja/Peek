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
    @State private var ambientGlow = false
    private var progress: Double { posture.revealProgress }

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            if phase == .result { resultView } else { revealStage }
        }
        .task { await prepareAndStart() }
        .onAppear {
            withAnimation(.easeInOut(duration: 2.4).repeatForever(autoreverses: true)) {
                ambientGlow = true
            }
        }
        .onChange(of: posture.posture) { old, new in
            guard phase == .revealing else { return }
            if new == .partiallyOpen && old == .closed { UIImpactFeedbackGenerator(style: .soft).impactOccurred() }
            if new == .fullyOpen { finishReveal() }
        }
        .duoHingeObserver(posture: posture)
        .preferredColorScheme(.dark)
    }

    private var revealStage: some View {
        GeometryReader { proxy in
            ZStack {
                revealBackdrop

                invitation
                    .opacity(max(0, 1 - progress * 2.4))
                    .scaleEffect(1 - progress * 0.08)

                reactionPreview
                    .frame(width: 94, height: 126)
                    .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
                    .overlay(RoundedRectangle(cornerRadius: 28).stroke(.white.opacity(0.16)))
                    .offset(x: proxy.size.width * 0.34, y: -proxy.size.height * 0.28)
                    .opacity(progress > 0.1 ? 1 : 0)
                    .scaleEffect(progress > 0.1 ? 1 : 0.8)
                    .zIndex(2)
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
                        Button { dismiss() } label: { Image(systemName: "xmark").frame(width: 42, height: 42) }.peekGlassButton()
                        Spacer()
                        Label(capture.isRecording ? "REC" : "READY", systemImage: "circle.fill").font(.caption.bold())
                            .foregroundStyle(capture.isRecording ? Color.peekPink : .secondary).padding(.horizontal, 13).padding(.vertical, 9).background(.ultraThinMaterial, in: Capsule())
                            .opacity(progress > 0.1 ? 1 : 0)
                    }
                    Spacer()
                    if progress > 0.08 { instruction }
                }.padding(20)
            }
        }.animation(.spring(response: 0.5, dampingFraction: 0.84), value: progress)
    }

    private var revealBackdrop: some View {
        ZStack {
            LinearGradient(
                colors: [Color(hex: "05050A"), Color(hex: "10091A"), Color(hex: "050817")],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            RadialGradient(
                colors: [Color.peekPink.opacity(ambientGlow ? 0.38 : 0.2), .clear],
                center: UnitPoint(x: 0.83, y: 0.36),
                startRadius: 8,
                endRadius: ambientGlow ? 330 : 255
            )

            RadialGradient(
                colors: [Color(hex: "526BFF").opacity(ambientGlow ? 0.35 : 0.18), .clear],
                center: UnitPoint(x: 0.72, y: 0.88),
                startRadius: 12,
                endRadius: 290
            )

            NeonHorizon()
                .fill(
                    LinearGradient(
                        colors: [Color.peekPink.opacity(0.75), Color(hex: "9B55FF").opacity(0.55), Color(hex: "22316D").opacity(0.25)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(alignment: .top) {
                    NeonHorizon()
                        .stroke(
                            LinearGradient(colors: [.white, Color.peekPink, Color(hex: "728BFF")], startPoint: .leading, endPoint: .trailing),
                            lineWidth: 2.5
                        )
                        .shadow(color: Color.peekPink, radius: ambientGlow ? 22 : 12)
                }
                .offset(y: 42)
        }
        .ignoresSafeArea()
    }

    private var invitation: some View {
        VStack(spacing: 0) {
            Spacer(minLength: 108)

            RevealOrb(glowing: ambientGlow)
                .frame(width: 190, height: 190)

            Spacer(minLength: 55)

            VStack(spacing: 10) {
                Text("Unfold to reveal")
                    .font(.system(size: 38, weight: .bold, design: .rounded))
                    .foregroundStyle(
                        LinearGradient(colors: [.white, Color(hex: "FF83C4"), Color(hex: "839CFF")], startPoint: .leading, endPoint: .trailing)
                    )
                Text("The reveal follows your iPhone Duo.")
                    .font(.system(size: 17, weight: .medium, design: .rounded))
                    .foregroundStyle(.white.opacity(0.58))
            }
            .multilineTextAlignment(.center)

            Spacer(minLength: 28)

            Text(posture.hasRealHinge ? "READY FOR YOUR REACTION" : "SIMULATED REACTION")
                .font(.caption2.weight(.semibold))
                .tracking(3.2)
                .foregroundStyle(.white.opacity(0.38))

            Button { simulateUnfold() } label: {
                HStack {
                    Spacer()
                    Text("Unfold to reveal")
                        .font(.headline)
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.title3.bold())
                        .frame(width: 48, height: 48)
                        .background(.white.opacity(0.14), in: Circle())
                }
                .padding(7)
                .padding(.leading, 48)
                .foregroundStyle(.white)
                .background(
                    LinearGradient(colors: [Color.peekPink.opacity(0.26), Color(hex: "526FFF").opacity(0.42)], startPoint: .leading, endPoint: .trailing),
                    in: Capsule()
                )
                .overlay(Capsule().stroke(LinearGradient(colors: [Color.peekPink.opacity(0.75), .white.opacity(0.24), Color(hex: "7790FF")], startPoint: .leading, endPoint: .trailing)))
                .shadow(color: Color(hex: "526FFF").opacity(ambientGlow ? 0.65 : 0.35), radius: ambientGlow ? 28 : 17, y: 8)
            }
            .buttonStyle(.plain)
            .disabled(posture.hasRealHinge)
            .accessibilityHint(posture.hasRealHinge ? "Unfold your device to continue" : "Simulates unfolding the device")
            .padding(.horizontal, 34)
            .padding(.top, 34)
            .padding(.bottom, 34)
        }
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

    private func simulateUnfold() {
        guard !posture.hasRealHinge else { return }
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        Task {
            for step in 1...20 {
                try? await Task.sleep(for: .milliseconds(24))
                posture.setDemoProgress(Double(step) / 20)
            }
        }
    }

    private var resultView: some View {
        VStack(spacing: 20) {
            HStack {
                Button { dismiss() } label: { Image(systemName: "xmark").frame(width: 42, height: 42) }.peekGlassButton()
                Spacer(); Text("Peek revealed").font(.subheadline.weight(.semibold)).foregroundStyle(.secondary); Spacer(); Color.clear.frame(width: 42, height: 42)
            }.padding(.horizontal, 20)
            ZStack(alignment: .bottomTrailing) {
                DemoPhoto(name: peek.imageName).clipShape(RoundedRectangle(cornerRadius: 32, style: .continuous))
                reactionPreview.frame(width: 112, height: 150).clipShape(RoundedRectangle(cornerRadius: 25, style: .continuous))
                    .overlay(RoundedRectangle(cornerRadius: 25).stroke(.white, lineWidth: 3)).shadow(color: .black.opacity(0.5), radius: 15).padding(15).scaleEffect(showReplay ? 1.04 : 1)
            }.padding(.horizontal, 16)
            VStack(spacing: 6) { Text("Reaction sent 💗").font(.title2.bold()); Text("Aish gets the real moment, not an emoji.").font(.subheadline).foregroundStyle(.secondary) }
            HStack(spacing: 12) {
                Button { withAnimation(.bouncy) { showReplay.toggle() } } label: { Label("Replay reaction", systemImage: "play.fill").frame(maxWidth: .infinity).padding(.vertical, 14) }
                    .buttonStyle(.glass)
                Button { dismiss() } label: { Text("Done").frame(maxWidth: .infinity).padding(.vertical, 14) }
                    .buttonStyle(.glassProminent).tint(.peekPink)
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
            appModel.capturedReactionURL = await capture.stopRecording(); appModel.markOpened(peek)
            withAnimation(.spring(response: 0.55, dampingFraction: 0.86)) { phase = .result }
        }
    }
}

private struct NeonHorizon: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: -rect.width * 0.12, y: rect.height * 0.58))
        path.addCurve(
            to: CGPoint(x: rect.width * 1.08, y: rect.height * 0.2),
            control1: CGPoint(x: rect.width * 0.36, y: rect.height * 0.43),
            control2: CGPoint(x: rect.width * 0.78, y: rect.height * 0.56)
        )
        path.addLine(to: CGPoint(x: rect.width * 1.08, y: rect.height * 1.1))
        path.addLine(to: CGPoint(x: -rect.width * 0.12, y: rect.height * 1.1))
        path.closeSubpath()
        return path
    }
}

private struct RevealOrb: View {
    let glowing: Bool

    var body: some View {
        ZStack {
            Circle()
                .fill(.ultraThinMaterial)
                .overlay(Circle().fill(LinearGradient(colors: [Color(hex: "8B77FF").opacity(0.5), Color.peekPink.opacity(0.28), .white.opacity(0.12)], startPoint: .topLeading, endPoint: .bottomTrailing)))
                .overlay(Circle().stroke(LinearGradient(colors: [.white.opacity(0.9), Color.peekPink, Color(hex: "778CFF")], startPoint: .topLeading, endPoint: .bottomTrailing), lineWidth: 2))
                .shadow(color: Color.peekPink.opacity(glowing ? 0.72 : 0.4), radius: glowing ? 34 : 20)

            Image(systemName: "person.crop.circle.fill")
                .font(.system(size: 116, weight: .ultraLight))
                .symbolRenderingMode(.palette)
                .foregroundStyle(.white.opacity(0.74), Color(hex: "6D5ACA").opacity(0.6))

            Image(systemName: "sparkle")
                .font(.title)
                .foregroundStyle(Color(hex: "FF8DCF"))
                .offset(x: -96, y: -50)
            Image(systemName: "sparkle")
                .font(.title2)
                .foregroundStyle(Color(hex: "8EA2FF"))
                .offset(x: 100, y: 42)
            Image(systemName: "wave.3.up")
                .font(.title2.bold())
                .foregroundStyle(Color(hex: "FF82C4"))
                .rotationEffect(.degrees(-34))
                .offset(x: 91, y: -89)
        }
        .scaleEffect(glowing ? 1.025 : 0.98)
    }
}

@available(iOS 27.1, *)
private struct HingeObserver: ViewModifier {
    let posture: DuoPostureService

    func body(content: Content) -> some View {
        content.onHingeChange { _, context in
            posture.consume(context)
        }
    }
}

private extension View {
    @ViewBuilder
    func duoHingeObserver(posture: DuoPostureService) -> some View {
        if #available(iOS 27.1, *) {
            self.modifier(HingeObserver(posture: posture))
        } else {
            self
        }
    }
}
