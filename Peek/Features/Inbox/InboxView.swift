import SwiftUI
import UIKit

struct InboxView: View {
    @Bindable var model: AppModel
    @State private var path: [Peek] = []
    @State private var isFloating = false
    @State private var glow = false

    var body: some View {
        NavigationStack(path: $path) {
            ZStack {
                background

                VStack(spacing: 0) {
                    header
                    Spacer(minLength: 24)
                    hero
                    Spacer(minLength: 30)
                    recentPeeks
                }
                .padding(.horizontal, 22)
                .padding(.bottom, 18)
            }
            .toolbar(.hidden, for: .navigationBar)
            .navigationDestination(for: Peek.self) { peek in
                if model.selectedTab == .received {
                    RevealExperienceView(peek: peek, appModel: model)
                } else {
                    SenderReactionsView(peek: DemoData.sent)
                }
            }
            .onAppear {
                withAnimation(.easeInOut(duration: 2.2).repeatForever(autoreverses: true)) {
                    isFloating = true
                }
                withAnimation(.easeInOut(duration: 1.6).repeatForever(autoreverses: true)) {
                    glow = true
                }
            }
        }
        .preferredColorScheme(.dark)
    }

    private var background: some View {
        ZStack {
            LinearGradient(
                colors: [Color(hex: "050506"), Color(hex: "111116"), .black],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            RadialGradient(
                colors: [Color.peekPink.opacity(glow ? 0.15 : 0.08), .clear],
                center: .center,
                startRadius: 10,
                endRadius: 260
            )
            .scaleEffect(glow ? 1.08 : 0.92)
            .offset(y: 5)

            RadialGradient(
                colors: [Color.white.opacity(0.07), .clear],
                center: .topTrailing,
                startRadius: 0,
                endRadius: 280
            )
        }
        .ignoresSafeArea()
    }

    private var header: some View {
        HStack {
            Text("Peek")
                .font(.system(size: 32, weight: .bold, design: .rounded))
            Spacer()
            Button {
                model.selectedTab = .sent
                path.append(DemoData.sent)
            } label: {
                Image(systemName: "paperplane.fill")
                    .frame(width: 44, height: 44)
            }
            .peekGlassButton()
            .accessibilityLabel("Sent Peeks")
        }
        .padding(.top, 12)
    }

    private var hero: some View {
        VStack(spacing: 26) {
            PeekMark()
                .frame(width: 126, height: 126)
                .offset(y: isFloating ? -8 : 5)
                .rotationEffect(.degrees(isFloating ? 2 : -2))
                .shadow(color: Color.peekPink.opacity(glow ? 0.42 : 0.2), radius: glow ? 34 : 20, y: 12)

            VStack(spacing: 9) {
                Text("Aish sent you a Peek")
                    .font(.system(size: 25, weight: .bold, design: .rounded))
                    .multilineTextAlignment(.center)
                Text("A little moment is waiting for you")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Button { openReceived() } label: {
                HStack(spacing: 10) {
                    Text("Tap to reveal")
                    Image(systemName: "sparkles")
                        .font(.subheadline)
                }
                .font(.headline)
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 17)
            }
            .buttonStyle(.plain)
            .background(
                LinearGradient(
                    colors: [Color.white.opacity(0.16), Color.white.opacity(0.07)],
                    startPoint: .top,
                    endPoint: .bottom
                ),
                in: Capsule()
            )
            .overlay(Capsule().stroke(Color.white.opacity(0.2), lineWidth: 1))
            .shadow(color: .black.opacity(0.5), radius: 18, y: 12)
            .padding(.horizontal, 26)
        }
        .padding(.vertical, 34)
        .padding(.horizontal, 12)
        .background(Color.white.opacity(0.025), in: RoundedRectangle(cornerRadius: 38, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 38, style: .continuous)
                .stroke(
                    LinearGradient(colors: [.white.opacity(0.17), .white.opacity(0.035)], startPoint: .topLeading, endPoint: .bottomTrailing),
                    lineWidth: 1
                )
        )
    }

    private var recentPeeks: some View {
        HStack(spacing: 12) {
            Button { openReceived() } label: {
                Label("Received", systemImage: "tray.and.arrow.down.fill")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.glass)

            Button {
                model.selectedTab = .sent
                path.append(DemoData.sent)
            } label: {
                Label("Sent", systemImage: "paperplane.fill")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.glass)
        }
        .font(.subheadline.weight(.semibold))
        .frame(height: 50)
    }

    private func openReceived() {
        model.selectedTab = .received
        path.append(model.incoming)
    }
}

/// Uses the product artwork when it exists in Assets.xcassets, and keeps previews
/// useful with a small SwiftUI rendition while the asset is unavailable.
private struct PeekMark: View {
    private var assetName: String? {
        ["peek", "Peek", "peek-icon", "PeekIcon"].first { UIImage(named: $0) != nil }
    }

    var body: some View {
        if let assetName {
            Image(assetName)
                .resizable()
                .scaledToFit()
        } else {
            GeometryReader { proxy in
                let size = min(proxy.size.width, proxy.size.height)
                ZStack {
                    RoundedRectangle(cornerRadius: size * 0.35, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [Color(red: 1, green: 0.72, blue: 0.84), Color.peekPink],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: size * 0.82, height: size * 0.62)
                        .offset(y: size * 0.11)

                    RoundedRectangle(cornerRadius: size * 0.27, style: .continuous)
                        .fill(Color(hex: "120E14"))
                        .frame(width: size * 0.61, height: size * 0.42)
                        .offset(y: size * 0.11)

                    HStack(spacing: size * 0.16) {
                        Circle().fill(Color(red: 1, green: 0.67, blue: 0.8))
                        Circle().fill(Color(red: 1, green: 0.67, blue: 0.8))
                    }
                    .frame(width: size * 0.31, height: size * 0.07)
                    .offset(y: size * 0.07)

                    Path { path in
                        path.move(to: CGPoint(x: size * 0.45, y: size * 0.64))
                        path.addQuadCurve(
                            to: CGPoint(x: size * 0.56, y: size * 0.64),
                            control: CGPoint(x: size * 0.505, y: size * 0.71)
                        )
                    }
                    .stroke(Color(red: 1, green: 0.67, blue: 0.8), style: StrokeStyle(lineWidth: size * 0.025, lineCap: .round))

                    Capsule()
                        .fill(Color(red: 1, green: 0.67, blue: 0.8))
                        .frame(width: size * 0.07, height: size * 0.25)
                        .rotationEffect(.degrees(24))
                        .offset(x: size * 0.29, y: -size * 0.32)

                    Capsule()
                        .fill(Color(red: 1, green: 0.67, blue: 0.8))
                        .frame(width: size * 0.07, height: size * 0.21)
                        .rotationEffect(.degrees(47))
                        .offset(x: size * 0.45, y: -size * 0.2)
                }
                .frame(width: proxy.size.width, height: proxy.size.height)
            }
            .aspectRatio(1, contentMode: .fit)
        }
    }
}
