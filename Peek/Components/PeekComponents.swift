import SwiftUI

extension Color {
    static let peekPink = Color(red: 1, green: 0.38, blue: 0.58)
    init(hex: String) {
        let value = UInt64(hex, radix: 16) ?? 0
        self.init(red: Double((value >> 16) & 255) / 255, green: Double((value >> 8) & 255) / 255, blue: Double(value & 255) / 255)
    }
}

struct AvatarView: View {
    let friend: Friend
    var size: CGFloat = 52
    var body: some View {
        Text(friend.initials).font(.system(size: size * 0.3, weight: .bold, design: .rounded)).foregroundStyle(.white)
            .frame(width: size, height: size)
            .background(LinearGradient(colors: [Color(hex: friend.tint), Color(hex: friend.tint).opacity(0.45)], startPoint: .topLeading, endPoint: .bottomTrailing), in: Circle())
            .overlay(Circle().stroke(.white.opacity(0.16)))
    }
}

struct DemoPhoto: View {
    let name: String
    var body: some View {
        ZStack {
            if name == "travel" {
                LinearGradient(colors: [.orange.opacity(0.9), .purple.opacity(0.75), .indigo], startPoint: .top, endPoint: .bottom)
                Image(systemName: "mountain.2.fill").font(.system(size: 150)).foregroundStyle(.black.opacity(0.34)).offset(y: 85)
                Image(systemName: "sun.max.fill").font(.system(size: 54)).foregroundStyle(.yellow.opacity(0.75)).offset(x: 82, y: -105)
            } else if name == "coffee" {
                LinearGradient(colors: [Color(hex: "E6B980"), Color(hex: "8B5E3C")], startPoint: .topLeading, endPoint: .bottomTrailing)
                Image(systemName: "cup.and.saucer.fill").font(.system(size: 150)).foregroundStyle(.white.opacity(0.86)).shadow(color: .black.opacity(0.3), radius: 20, y: 14)
            } else if name == "cat" {
                LinearGradient(colors: [Color(hex: "725CAD"), Color(hex: "24193D")], startPoint: .top, endPoint: .bottom)
                Image(systemName: "cat.fill").font(.system(size: 180)).foregroundStyle(Color(hex: "F4B860")).shadow(color: .black.opacity(0.35), radius: 20, y: 14)
            } else if name == "music" {
                LinearGradient(colors: [Color(hex: "FF7597"), Color(hex: "526BFF")], startPoint: .topLeading, endPoint: .bottomTrailing)
                Image(systemName: "headphones").font(.system(size: 170, weight: .bold)).foregroundStyle(.white.opacity(0.88)).shadow(color: .black.opacity(0.3), radius: 20, y: 14)
            } else {
                LinearGradient(colors: [Color(red: 0.18, green: 0.16, blue: 0.12), Color(red: 0.65, green: 0.48, blue: 0.28)], startPoint: .top, endPoint: .bottom)
                Image(systemName: "dog.fill").font(.system(size: 190)).foregroundStyle(Color(red: 0.95, green: 0.78, blue: 0.52)).shadow(color: .black.opacity(0.35), radius: 24, y: 16)
                VStack { Spacer(); Text("I HAVE A QUESTION").font(.system(.headline, design: .rounded, weight: .black)).tracking(1.5).padding(.horizontal, 18).padding(.vertical, 11).background(.black.opacity(0.66), in: Capsule()).padding(.bottom, 36) }
            }
        }
    }
}

struct PrimaryButton: View {
    let title: String
    let icon: String?
    let action: () -> Void
    var body: some View {
        Button(action: action) {
            HStack(spacing: 9) { Text(title); if let icon { Image(systemName: icon) } }
                .font(.headline).frame(maxWidth: .infinity).padding(.vertical, 17)
        }
        .buttonStyle(.glassProminent)
        .tint(.peekPink)
        .foregroundStyle(.white)
    }
}

extension View {
    /// The shared treatment for compact controls floating above photos and dark surfaces.
    func peekGlassButton() -> some View {
        buttonStyle(.glass)
            .foregroundStyle(.white)
    }

    /// A tappable glass surface with the soft, continuous geometry used across iOS.
    func peekGlassSurface(cornerRadius: CGFloat = 24) -> some View {
        glassEffect(.regular.interactive(), in: .rect(cornerRadius: cornerRadius))
    }
}
