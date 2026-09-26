import Observation
import Foundation

@MainActor
@Observable
final class AppModel {
    enum Tab { case received, sent }
    var selectedTab: Tab = .received
    var incoming = DemoData.incoming
    var capturedReactionURL: URL?
    let subscriptions = SubscriptionService()

    init() {
        subscriptions.configure()
    }
}
