import Observation
import Foundation

@MainActor
@Observable
final class AppModel {
    enum Tab { case received, sent }
    var selectedTab: Tab = .received
    var incomingPeeks = DemoData.incomingPeeks
    var friends = [DemoData.aish, DemoData.navya, DemoData.tarang, DemoData.wali]
    var capturedReactionURL: URL?
    let subscriptions = SubscriptionService()

    init() {
        subscriptions.configure()
    }

    var nextIncomingPeek: Peek? {
        incomingPeeks.first { !$0.isOpened }
    }

    func hasPeek(after peek: Peek) -> Bool {
        guard let index = incomingPeeks.firstIndex(where: { $0.id == peek.id }) else { return false }
        return incomingPeeks.dropFirst(index + 1).contains { !$0.isOpened }
    }

    func markOpened(_ peek: Peek) {
        guard let index = incomingPeeks.firstIndex(where: { $0.id == peek.id }) else { return }
        incomingPeeks[index].isOpened = true
    }

    func addFriend(named name: String) {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty,
              !friends.contains(where: { $0.name.localizedCaseInsensitiveCompare(trimmed) == .orderedSame }) else { return }
        let initials = trimmed.split(separator: " ").prefix(2).compactMap(\.first).map(String.init).joined().uppercased()
        let colors = ["FF7597", "8C7CFF", "48C9B0", "F4B860", "70A1FF"]
        friends.append(Friend(name: trimmed, initials: initials, tint: colors[friends.count % colors.count]))
    }
}
