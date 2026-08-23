//
//  flip_clockApp.swift
//  flip-clock
//
//  Created by Tilak Patel on 4/19/25.
//

import SwiftUI

extension Notification.Name {
    /// Posted by the New Alarm menu command; ContentView opens the alarm popover.
    static let newAlarmRequested = Notification.Name("newAlarmRequested")

    /// Posted by the Fit Window to Clock command; ContentView resizes the window.
    static let fitWindowRequested = Notification.Name("fitWindowRequested")
}

@main
struct flip_clockApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject private var settings = AppSettings()
    @StateObject private var alarmManager = AlarmManager()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(settings)
                .environmentObject(alarmManager)
        }
        // SwiftUI's own titlebar handling — without this the content keeps a safe-area inset
        // below the titlebar no matter what the AppKit style mask says.
        .windowStyle(.hiddenTitleBar)
        .commands {
            CommandGroup(replacing: .newItem) { }
            CommandMenu("Clock") {
                Button("New Alarm") {
                    NotificationCenter.default.post(name: .newAlarmRequested, object: nil)
                }
                .keyboardShortcut("n")
                Divider()
                Button("Fit Window to Clock") {
                    NotificationCenter.default.post(name: .fitWindowRequested, object: nil)
                }
                .keyboardShortcut("=")
                Toggle("Show Seconds", isOn: $settings.showSeconds)
                    .keyboardShortcut("s")
                Toggle("Always on Top", isOn: $settings.alwaysOnTop)
                    .keyboardShortcut("t")
            }
        }
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {

    func applicationDidFinishLaunching(_ notification: Notification) {
        // NSApp does not exist yet in the App's init, so the dark appearance is forced here.
        NSApp.appearance = NSAppearance(named: .darkAqua)
        ticker.start()
    }

    // MARK: - Private

    /// Redraws the Dock icon on each wall-clock minute — and re-syncs after sleep/wake or a
    /// clock change, which a plain repeating timer would sail straight past.
    private lazy var ticker = TimeTicker(interval: 60) { [weak self] date in
        self?.updateDockIcon(at: date)
    }

    private func updateDockIcon(at date: Date) {
        NSApp.applicationIconImage = FlipClockDockIconRenderer.icon(for: date)
    }

}

struct FlipClockDockIconRenderer {

    static func icon(for date: Date) -> NSImage {
        let size = NSSize(width: 256, height: 256)
        let timeString = formatter.string(from: date) as NSString

        return NSImage(size: size, flipped: false) { rect in
            NSColor.black.setFill()
            NSBezierPath(roundedRect: rect, xRadius: 48, yRadius: 48).fill()

            let attributes = attributes(fitting: timeString, in: rect)
            let textSize = timeString.size(withAttributes: attributes)
            let origin = NSPoint(x: rect.midX - textSize.width / 2,
                                 y: rect.midY - textSize.height / 2)
            timeString.draw(at: origin, withAttributes: attributes)
            return true
        }
    }

    // MARK: - Private

    private static let horizontalMargin: CGFloat = 20

    private static let formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "hh:mm"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter
    }()

    /// Largest font size at which the time still clears the icon's margins.
    private static func attributes(fitting text: NSString, in rect: NSRect) -> [NSAttributedString.Key: Any] {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center

        var attributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: NSColor.white,
            .paragraphStyle: paragraphStyle
        ]
        for fontSize in stride(from: CGFloat(88), through: 40, by: -4) {
            attributes[.font] = NSFont.monospacedDigitSystemFont(ofSize: fontSize, weight: .bold)
            if text.size(withAttributes: attributes).width <= rect.width - 2 * horizontalMargin {
                break
            }
        }
        return attributes
    }

}
