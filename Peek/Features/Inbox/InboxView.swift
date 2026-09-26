import SwiftUI

struct InboxView: View {
    @Bindable var model: AppModel
    @State private var path: [Peek] = []
    var body: some View {
        NavigationStack(path: $path) {
            ZStack {
                Color.black.ignoresSafeArea()
                VStack(spacing: 0) { header; picker; model.selectedTab == .received ? AnyView(receivedList) : AnyView(sentList); Spacer() }
            }
            .toolbar(.hidden, for: .navigationBar)
            .navigationDestination(for: Peek.self) { peek in
                if model.selectedTab == .received { IncomingPeekView(peek: peek, appModel: model) }
                else { SenderReactionsView(peek: DemoData.sent) }
            }
        }.preferredColorScheme(.dark)
    }

    private var header: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text("Peek").font(.system(size: 38, weight: .bold, design: .rounded))
                Text("Something’s waiting for you").font(.subheadline).foregroundStyle(.secondary)
            }
            Spacer()
            Button { model.selectedTab = .sent } label: { Image(systemName: "paperplane.fill").frame(width: 44, height: 44) }
                .peekGlassButton()
        }.padding(.horizontal, 22).padding(.top, 22).padding(.bottom, 24)
    }

    private var picker: some View {
        HStack(spacing: 4) { tabButton("Received", tab: .received); tabButton("Sent", tab: .sent) }
            .padding(4).glassEffect(.regular, in: .capsule).padding(.horizontal, 22).padding(.bottom, 24)
    }

    private func tabButton(_ title: String, tab: AppModel.Tab) -> some View {
        Button { withAnimation(.snappy) { model.selectedTab = tab } } label: {
            Text(title).font(.subheadline.weight(.semibold)).frame(maxWidth: .infinity).padding(.vertical, 10)
                .glassEffect(model.selectedTab == tab ? .regular.interactive() : .identity, in: .capsule)
        }.foregroundStyle(model.selectedTab == tab ? .white : .secondary).buttonStyle(.plain)
    }

    private var receivedList: some View {
        Button { path.append(model.incoming) } label: {
            HStack(spacing: 15) {
                ZStack(alignment: .topTrailing) { AvatarView(friend: model.incoming.sender, size: 58); Circle().fill(Color.peekPink).frame(width: 13, height: 13).overlay(Circle().stroke(.black, lineWidth: 2)) }
                VStack(alignment: .leading, spacing: 6) { Text("Aish sent you a Peek 👀").font(.headline); Text("2m ago").font(.subheadline).foregroundStyle(.secondary) }
                Spacer(); Image(systemName: "chevron.right").font(.subheadline.weight(.bold)).foregroundStyle(.tertiary)
            }.padding(17).peekGlassSurface()
        }.buttonStyle(.plain).padding(.horizontal, 22)
    }

    private var sentList: some View {
        Button { path.append(DemoData.sent) } label: {
            HStack(spacing: 15) {
                DemoPhoto(name: "travel").frame(width: 58, height: 58).clipShape(RoundedRectangle(cornerRadius: 16))
                VStack(alignment: .leading, spacing: 5) { Text("Your sunrise Peek").font(.headline); Text("4 reactions · 1h ago").font(.subheadline).foregroundStyle(.secondary) }
                Spacer(); Image(systemName: "chevron.right").foregroundStyle(.tertiary)
            }.padding(17).peekGlassSurface()
        }.buttonStyle(.plain).padding(.horizontal, 22)
    }
}
