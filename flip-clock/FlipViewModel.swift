import Combine
import SwiftUI

class FlipViewModel: ObservableObject, Identifiable {

    var text: String? {
        didSet { updateTexts(old: oldValue, new: text) }
    }

    @Published var newValue: String?
    @Published var oldValue: String?

    /// 0 = leaf still standing, 1 = leaf come to rest. `FlipLeaf` derives both the rotation and the
    /// shading from these, so a leaf is always as dark as its angle says it should be.
    @Published var topProgress: Double = 1
    @Published var bottomProgress: Double = 1

    func updateTexts(old: String?, new: String?) {
        guard old != new else { return }
        oldValue = old
        newValue = new
        topProgress = 0
        bottomProgress = 0

        // A leaf falls under gravity, so it accelerates through the top half...
        withAnimation(.easeIn(duration: Self.fallDuration)) {
            topProgress = 1
        }
        // ...carries that speed into the bottom half and overshoots a little as it hits the stop,
        // the way a real leaf rattles against the drum before settling.
        withAnimation(.timingCurve(0.22, 0.86, 0.36, 1.06, duration: Self.settleDuration)
            .delay(Self.fallDuration)) {
            bottomProgress = 1
        }
    }

    // MARK: - Private

    private static let fallDuration: TimeInterval = 0.13
    private static let settleDuration: TimeInterval = 0.17

}
