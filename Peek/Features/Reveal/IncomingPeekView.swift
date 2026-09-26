import SwiftUI

struct IncomingPeekView: View {
    let peek: Peek
    @Bindable var appModel: AppModel
    @State private var showReveal = false
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            VStack(spacing: 18) {
                Spacer(); AvatarView(friend: peek.sender, size: 92).shadow(color: Color.peekPink.opacity(0.2), radius: 28)
                Text("Aish sent you a Peek 👀").font(.title2.bold())
                Text("There’s only one way to see it.").foregroundStyle(.secondary)
                Spacer(); PrimaryButton(title: "Reveal", icon: "eye.fill") { showReveal = true }.padding(.horizontal, 24).padding(.bottom, 20)
            }
        }.navigationBarTitleDisplayMode(.inline).fullScreenCover(isPresented: $showReveal) { RevealExperienceView(peek: peek, appModel: appModel) }
    }
}
