import Foundation
import Observation
import RevenueCat

/// RevenueCat-backed entitlement state. Headless: no UI, the views can adopt it later.
@MainActor
@Observable
final class SubscriptionService {
    enum Status: Equatable { case notConfigured, loading, ready, failed(String) }

    /// Entitlement identifier configured in the RevenueCat dashboard.
    static let entitlementID = "plus"

    private(set) var status: Status = .notConfigured
    private(set) var isPro = false
    private(set) var offering: Offering?
    @ObservationIgnored private var updatesTask: Task<Void, Never>?

    /// Reads the public SDK key from the REVENUECAT_API_KEY scheme env var,
    /// falling back to RevenueCat.plist (gitignored) in the app bundle.
    static var apiKey: String? {
        if let env = ProcessInfo.processInfo.environment["REVENUECAT_API_KEY"], !env.isEmpty { return env }
        guard let url = Bundle.main.url(forResource: "RevenueCat", withExtension: "plist"),
              let dict = NSDictionary(contentsOf: url),
              let key = dict["APIKey"] as? String, !key.isEmpty else { return nil }
        return key
    }

    func configure() {
        guard !Purchases.isConfigured else { return }
        guard let key = Self.apiKey else {
            status = .notConfigured
            print("[RevenueCat] No API key. Set REVENUECAT_API_KEY or add Peek/RevenueCat.plist.")
            return
        }
        #if DEBUG
        Purchases.logLevel = .debug
        #endif
        Purchases.configure(withAPIKey: key)
        status = .loading
        updatesTask = Task { [weak self] in
            for await info in Purchases.shared.customerInfoStream {
                self?.apply(info)
            }
        }
        Task { await refresh() }
    }

    func refresh() async {
        guard Purchases.isConfigured else { return }
        do {
            async let info = Purchases.shared.customerInfo()
            async let offerings = Purchases.shared.offerings()
            apply(try await info)
            offering = try await offerings.current
            status = .ready
            print("[RevenueCat] ready · offering=\(offering?.identifier ?? "none") packages=\(offering?.availablePackages.map(\.identifier) ?? []) isPlus=\(isPro)")
        } catch {
            status = .failed(error.localizedDescription)
            print("[RevenueCat] refresh failed: \(error.localizedDescription)")
        }
    }

    /// Returns true when the purchase unlocked the entitlement; false if the user cancelled.
    @discardableResult
    func purchase(_ package: Package) async throws -> Bool {
        let result = try await Purchases.shared.purchase(package: package)
        apply(result.customerInfo)
        return !result.userCancelled && isPro
    }

    func restore() async throws {
        apply(try await Purchases.shared.restorePurchases())
    }

    private func apply(_ info: CustomerInfo) {
        isPro = info.entitlements[Self.entitlementID]?.isActive == true
    }
}
