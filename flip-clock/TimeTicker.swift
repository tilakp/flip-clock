import Foundation
import AppKit

/// A timer that fires on true wall-clock boundaries and re-arms itself after every fire.
///
/// A plain repeating `Timer` is wrong for a clock: its fire dates are relative to when it was
/// started, it is suspended while the run loop is in event-tracking mode (live window resize,
/// window drag, menu tracking), and it does not survive sleep/wake or a system clock change.
/// This ticker schedules a *one-shot* timer to the next boundary and re-arms from inside the fire
/// block, so a late or missed fire can never accumulate drift.
final class TimeTicker {

    /// Seconds between ticks. Boundaries are multiples of this from the reference date, so 1 lands
    /// on each second and 60 lands on each wall-clock minute. Changing it re-arms immediately.
    var interval: TimeInterval {
        didSet {
            guard interval != oldValue, isRunning else { return }
            arm()
        }
    }

    init(interval: TimeInterval, onTick: @escaping (Date) -> Void) {
        self.interval = interval
        self.onTick = onTick
    }

    deinit {
        stop()
    }

    /// Ticks once immediately, then on every boundary until `stop()`.
    func start() {
        guard !isRunning else { return }
        isRunning = true
        observeSystemTimeChanges()
        resync()
    }

    func stop() {
        isRunning = false
        timer?.invalidate()
        timer = nil
        observers.forEach { NotificationCenter.default.removeObserver($0) }
        workspaceObservers.forEach { NSWorkspace.shared.notificationCenter.removeObserver($0) }
        observers.removeAll()
        workspaceObservers.removeAll()
    }

    /// The first boundary strictly after `date`.
    static func nextBoundary(after date: Date, interval: TimeInterval) -> Date {
        precondition(interval > 0, "interval must be positive")
        let elapsed = date.timeIntervalSinceReferenceDate
        return Date(timeIntervalSinceReferenceDate: (floor(elapsed / interval) + 1) * interval)
    }

    // MARK: - Private

    /// Fire a hair after the boundary so `Date()` inside the block never reads the previous second.
    private static let fireDelay: TimeInterval = 0.02

    private let onTick: (Date) -> Void
    private var timer: Timer?
    private var isRunning = false
    private var observers: [NSObjectProtocol] = []
    private var workspaceObservers: [NSObjectProtocol] = []

    private func resync() {
        onTick(Date())
        arm()
    }

    private func arm() {
        timer?.invalidate()
        let fireDate = Self.nextBoundary(after: Date(), interval: interval)
            .addingTimeInterval(Self.fireDelay)
        let timer = Timer(fire: fireDate, interval: 0, repeats: false) { [weak self] _ in
            guard let self, self.isRunning else { return }
            self.onTick(Date())
            self.arm()
        }
        timer.tolerance = 0
        // .common, not .default: otherwise every tick stops while the user resizes or drags the
        // window, or holds a menu open.
        RunLoop.main.add(timer, forMode: .common)
        self.timer = timer
    }

    private func observeSystemTimeChanges() {
        let resync: (Notification) -> Void = { [weak self] _ in
            guard let self, self.isRunning else { return }
            self.resync()
        }
        for name: NSNotification.Name in [.NSSystemClockDidChange, .NSSystemTimeZoneDidChange] {
            observers.append(NotificationCenter.default.addObserver(
                forName: name, object: nil, queue: .main, using: resync))
        }
        workspaceObservers.append(NSWorkspace.shared.notificationCenter.addObserver(
            forName: NSWorkspace.didWakeNotification, object: nil, queue: .main, using: resync))
    }

}
