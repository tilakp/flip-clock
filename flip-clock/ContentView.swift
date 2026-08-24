import SwiftUI

struct ContentView: View {

    @EnvironmentObject private var alarmManager: AlarmManager
    @EnvironmentObject private var settings: AppSettings

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            Color.black
                .ignoresSafeArea()

            ClockView(showSeconds: settings.showSeconds)
                .contextMenu { clockCommands }

            alarmButton
                .padding(12)
                .opacity(chromeIsVisible ? 1 : 0)
                .animation(.easeInOut(duration: 0.15), value: chromeIsVisible)

            if let ringing = alarmManager.ringingAlarm {
                ringingBanner(for: ringing)
            }

            AppWindowAccessor(callback: configure)
                .frame(width: 0, height: 0)
        }
        .ignoresSafeArea()
        .onHover { isHovering = $0 }
        .onExitCommand { alarmManager.silence() }
        .onReceive(NotificationCenter.default.publisher(for: .newAlarmRequested)) { _ in
            newAlarmTime = Date()
            showingAlarms = true
        }
        .onReceive(NotificationCenter.default.publisher(for: .fitWindowRequested)) { _ in
            fitWindowToClock()
        }
    }

    // MARK: - Private

    /// A reference type so stashing the window doesn't invalidate the view.
    private final class WindowHolder { weak var window: NSWindow? }

    @State private var windowHolder = WindowHolder()
    @State private var isHovering = false
    @State private var showingAlarms = false
    @State private var newAlarmTime = Date()

    /// Window buttons and the alarm button share one visibility state: the clock face stays clean
    /// until the pointer is over it.
    private var chromeIsVisible: Bool { isHovering || showingAlarms }

    @ViewBuilder private var clockCommands: some View {
        Button("New Alarm") {
            newAlarmTime = Date()
            showingAlarms = true
        }
        Divider()
        Toggle("Show Seconds", isOn: $settings.showSeconds)
        Toggle("Always on Top", isOn: $settings.alwaysOnTop)
    }

    private var alarmButton: some View {
        Button {
            showingAlarms.toggle()
        } label: {
            // The corner this sits in is usually a digit card, which is near-white, so the chip
            // carries its own dark ground rather than tinting whatever is behind it.
            Image(systemName: hasEnabledAlarm ? "bell.fill" : "bell")
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(.white)
                .padding(9)
                .background(Circle().fill(Color.black.opacity(0.72)))
                .overlay(Circle().strokeBorder(Color.white.opacity(0.28), lineWidth: 1))
                .shadow(color: .black.opacity(0.45), radius: 4, y: 1)
        }
        .buttonStyle(.plain)
        .help("Alarms")
        .popover(isPresented: $showingAlarms, arrowEdge: .bottom) { alarmPopover }
    }

    private var hasEnabledAlarm: Bool { alarmManager.alarms.contains { $0.enabled } }

    private var alarmPopover: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Alarms")
                .font(.headline)

            if alarmManager.alarms.isEmpty {
                Text("No alarms yet.")
                    .font(.caption)
                    .foregroundColor(.secondary)
            } else {
                ForEach(alarmManager.alarms) { alarm in
                    HStack(spacing: 10) {
                        Text(alarm.time, style: .time)
                            .font(.system(size: 14, design: .monospaced))
                            .foregroundColor(alarm.enabled ? .primary : .secondary)
                        Spacer(minLength: 12)
                        Button { alarmManager.toggleAlarm(alarm) } label: {
                            Image(systemName: alarm.enabled ? "bell.fill" : "bell.slash")
                                .foregroundColor(alarm.enabled ? .green : .gray)
                        }
                        .buttonStyle(.plain)
                        .help(alarm.enabled ? "Disable" : "Enable")
                        Button { alarmManager.removeAlarm(alarm) } label: {
                            Image(systemName: "trash").foregroundColor(.red)
                        }
                        .buttonStyle(.plain)
                        .help("Delete")
                    }
                }
            }

            Divider()

            HStack(spacing: 10) {
                DatePicker("", selection: $newAlarmTime, displayedComponents: [.hourAndMinute])
                    .datePickerStyle(.field)
                    .labelsHidden()
                Button("Add") { alarmManager.addAlarm(time: newAlarmTime) }
                    .buttonStyle(.borderedProminent)
                    .tint(.green)
            }
        }
        .padding(16)
        .frame(minWidth: 220)
    }

    private func ringingBanner(for alarm: Alarm) -> some View {
        ZStack {
            // Any click anywhere silences.
            Color.black.opacity(0.55)
                .ignoresSafeArea()
                .onTapGesture { alarmManager.silence() }

            VStack(spacing: 14) {
                Image(systemName: "bell.fill")
                    .font(.system(size: 28))
                    .foregroundColor(.white)
                Text(alarm.time, style: .time)
                    .font(.system(size: 22, weight: .semibold, design: .monospaced))
                    .foregroundColor(.white)
                HStack(spacing: 12) {
                    Button("Snooze \(AlarmManager.snoozeMinutes) min") { alarmManager.snooze() }
                    Button("Dismiss") { alarmManager.silence() }
                        .buttonStyle(.borderedProminent)
                        .tint(.green)
                }
            }
            .padding(28)
            .background(RoundedRectangle(cornerRadius: 16).fill(Color(white: 0.12)))
        }
        .transition(.opacity)
    }

    /// Resize the window to the clock's own aspect ratio, so it bleeds on both axes at once.
    /// Height follows width, and the top edge stays put.
    private func fitWindowToClock() {
        guard let window = windowHolder.window,
              let contentSize = window.contentView?.bounds.size else { return }
        let groups = settings.showSeconds ? 3 : 2
        let target = FlipMetrics.fittedHeight(forWidth: contentSize.width, groups: groups)
        guard target > 0 else { return }

        var frame = window.frame
        let delta = target - contentSize.height
        frame.origin.y -= delta
        frame.size.height += delta
        window.setFrame(frame, display: true, animate: true)
    }

    /// All window chrome lives here — `AppWindowAccessor` is the only place with a window that
    /// reliably exists.
    private func configure(_ window: NSWindow) {
        windowHolder.window = window
        // The titlebar itself is hidden by .windowStyle(.hiddenTitleBar) on the scene.
        window.backgroundColor = .black
        window.isOpaque = true
        // No visible title bar to grab, so the clock face itself drags the window.
        window.isMovableByWindowBackground = true
        window.level = settings.alwaysOnTop ? .floating : .normal
        if window.frameAutosaveName.isEmpty {
            window.setFrameAutosaveName("FlipClockMainWindow")
        }

        let alpha: CGFloat = chromeIsVisible ? 1 : 0
        let buttons = [NSWindow.ButtonType.closeButton, .miniaturizeButton, .zoomButton]
            .compactMap { window.standardWindowButton($0) }
        guard let first = buttons.first, abs(first.alphaValue - alpha) > 0.01 else { return }
        NSAnimationContext.runAnimationGroup { context in
            context.duration = 0.15
            buttons.forEach { $0.animator().alphaValue = alpha }
        }
    }

}

#Preview {
    ContentView()
        .environmentObject(AlarmManager())
        .environmentObject(AppSettings())
}
