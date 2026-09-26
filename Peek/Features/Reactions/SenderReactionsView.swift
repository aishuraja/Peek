import SwiftUI

struct SenderReactionsView: View {
    let peek: Peek
    @State private var selected: Friend?
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    DemoPhoto(name: peek.imageName).frame(height: 420).clipShape(RoundedRectangle(cornerRadius: 32, style: .continuous))
                        .overlay(alignment: .bottomLeading) { Text(peek.caption ?? "").font(.headline).padding(20) }
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Reactions").font(.title2.bold())
                        Text("Tap a friend to watch the moment they unfolded your Peek.").font(.subheadline).foregroundStyle(.secondary)
                        HStack(spacing: 15) {
                            ForEach(peek.reactions) { reaction in
                                Button { selected = reaction.friend } label: {
                                    VStack(spacing: 8) {
                                        AvatarView(friend: reaction.friend, size: 58).overlay(alignment: .bottomTrailing) { Image(systemName: "play.fill").font(.caption2).padding(5).background(Color.peekPink, in: Circle()) }
                                        Text(reaction.friend.name).font(.caption.weight(.medium))
                                    }
                                }.buttonStyle(.plain)
                                    .padding(10)
                                    .glassEffect(.regular.interactive(), in: .rect(cornerRadius: 20))
                            }
                        }
                    }
                }.padding(18)
            }
        }.navigationTitle("Your Peek").navigationBarTitleDisplayMode(.inline)
            .sheet(item: $selected) { friend in ReactionPlayerSheet(friend: friend).presentationDetents([.medium]).presentationDragIndicator(.visible) }
    }
}

private struct ReactionPlayerSheet: View {
    let friend: Friend
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            VStack(spacing: 15) {
                ZStack { DemoCameraPreview(); Image(systemName: "play.fill").font(.title).frame(width: 64, height: 64).glassEffect(.regular.interactive(), in: .circle) }
                    .frame(height: 250).clipShape(RoundedRectangle(cornerRadius: 30))
                Text("\(friend.name)’s reaction").font(.title3.bold()); Text("Captured at the reveal").font(.subheadline).foregroundStyle(.secondary)
            }.padding(18)
        }.preferredColorScheme(.dark)
    }
}
