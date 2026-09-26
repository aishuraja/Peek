import SwiftUI
import Observation


@MainActor
@Observable
final class DuoPostureService {
    enum Posture: Equatable { case unavailable, closed, partiallyOpen, fullyOpen }

    private(set) var posture: Posture = .unavailable
    private(set) var revealProgress: Double = 0
    private(set) var angleDegrees: Double?
    private(set) var hasRealHinge = false

    @available(iOS 27.1, *)
    func consume(_ context: DeviceHingeContext) {
        guard let hinge = context.hinge else {
            hasRealHinge = false
            posture = .unavailable
            return
        }
        hasRealHinge = true
        angleDegrees = hinge.angle.degrees
        if hinge.status == .closed {
            posture = .closed
            revealProgress = 0
        } else if hinge.status == .fullyOpen {
            posture = .fullyOpen
            revealProgress = 1
        } else {
            posture = .partiallyOpen
            // Angle animates the reveal; the discrete status is completion authority.
            revealProgress = min(max(hinge.angle.radians / .pi, 0.08), 0.96)
        }
    }

    #if targetEnvironment(simulator)
    func setDemoProgress(_ progress: Double) {
        guard !hasRealHinge else { return }
        revealProgress = min(max(progress, 0), 1)
        posture = progress >= 0.98 ? .fullyOpen : (progress <= 0.02 ? .closed : .partiallyOpen)
    }
    #endif
}
