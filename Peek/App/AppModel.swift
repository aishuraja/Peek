import Observation
import Foundation

@MainActor
@Observable
final class AppModel {
    enum Tab { case received, sent }
    var selectedTab: Tab = .received
    var incomingPeeks = [DemoData.incoming]
    var capturedReactionURL: URL?

    var nextIncomingPeek: Peek? {
        incomingPeeks.first { !$0.isOpened }
    }

    func markOpened(_ peek: Peek) {
        guard let index = incomingPeeks.firstIndex(where: { $0.id == peek.id }) else { return }
        incomingPeeks[index].isOpened = true
    }
}
