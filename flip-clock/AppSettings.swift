import SwiftUI

/// User preferences that outlive a launch. Persisted to `UserDefaults`, like `AlarmManager`.
final class AppSettings: ObservableObject {

    @Published var showSeconds: Bool {
        didSet { defaults.set(showSeconds, forKey: Key.showSeconds) }
    }

    @Published var alwaysOnTop: Bool {
        didSet { defaults.set(alwaysOnTop, forKey: Key.alwaysOnTop) }
    }

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        defaults.register(defaults: [Key.showSeconds: true, Key.alwaysOnTop: false])
        showSeconds = defaults.bool(forKey: Key.showSeconds)
        alwaysOnTop = defaults.bool(forKey: Key.alwaysOnTop)
    }

    // MARK: - Private

    private enum Key {
        static let showSeconds = "showSeconds"
        static let alwaysOnTop = "alwaysOnTop"
    }

    private let defaults: UserDefaults

}
