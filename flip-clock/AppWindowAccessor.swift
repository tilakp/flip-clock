import Cocoa
import SwiftUI

/// Hands back the hosting `NSWindow` so window chrome can be driven from SwiftUI state.
/// The callback runs again on every SwiftUI update, not just once at creation, so changes to
/// state it captures (hover, always-on-top) are applied to the window.
struct AppWindowAccessor: NSViewRepresentable {
    var callback: (NSWindow) -> Void

    func makeNSView(context: Context) -> NSView {
        let view = NSView()
        apply(to: view)
        return view
    }

    func updateNSView(_ nsView: NSView, context: Context) {
        apply(to: nsView)
    }

    private func apply(to view: NSView) {
        DispatchQueue.main.async {
            guard let window = view.window else { return }
            callback(window)
        }
    }
}
