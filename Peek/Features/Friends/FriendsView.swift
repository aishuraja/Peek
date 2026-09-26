import SwiftUI

struct FriendsView: View {
    @Bindable var model: AppModel
    @State private var showingAddFriend = false

    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(colors: [Color(hex: "08080B"), .black], startPoint: .top, endPoint: .bottom)
                    .ignoresSafeArea()

                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(model.friends) { friend in
                            HStack(spacing: 14) {
                                AvatarView(friend: friend, size: 54)
                                VStack(alignment: .leading, spacing: 3) {
                                    Text(friend.name).font(.headline)
                                    Text("Friend on Peek").font(.subheadline).foregroundStyle(.secondary)
                                }
                                Spacer()
                                Image(systemName: "checkmark.circle.fill").foregroundStyle(Color.peekPink)
                            }
                            .padding(14)
                            .background(Color.white.opacity(0.055), in: RoundedRectangle(cornerRadius: 22, style: .continuous))
                            .overlay(RoundedRectangle(cornerRadius: 22).stroke(.white.opacity(0.08)))
                        }
                    }
                    .padding(18)
                }
            }
            .navigationTitle("Friends")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button { showingAddFriend = true } label: { Image(systemName: "person.badge.plus") }
                        .accessibilityLabel("Add friend")
                }
            }
            .sheet(isPresented: $showingAddFriend) {
                AddFriendView(model: model)
                    .presentationDetents([.medium])
                    .presentationDragIndicator(.visible)
            }
        }
    }
}

private struct AddFriendView: View {
    @Bindable var model: AppModel
    @Environment(\.dismiss) private var dismiss
    @State private var name = ""

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 18) {
                Text("Who do you want to Peek with?").font(.title2.bold())
                TextField("Friend’s name", text: $name)
                    .textInputAutocapitalization(.words)
                    .padding(16)
                    .background(Color.white.opacity(0.08), in: RoundedRectangle(cornerRadius: 16))
                PrimaryButton(title: "Add friend", icon: "person.badge.plus") {
                    model.addFriend(named: name)
                    dismiss()
                }
                .disabled(name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                Spacer()
            }
            .padding(20)
            .navigationTitle("Add Friend")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar { ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() } } }
        }
        .preferredColorScheme(.dark)
    }
}
