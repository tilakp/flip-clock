# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project

A macOS SwiftUI flip clock: edge-to-edge digits, retro flip animation, persisted alarms, and a Dock icon that redraws on the wall-clock minute. Single Xcode project, no package manager, no external dependencies.

## Commands

Build / run / test all use the single shared scheme `flip-clock`:

```bash
xcodebuild -project flip-clock.xcodeproj -scheme flip-clock -configuration Debug build
xcodebuild -project flip-clock.xcodeproj -scheme flip-clock test          # unit + UI tests
open ~/Library/Developer/Xcode/DerivedData/flip-clock-*/Build/Products/Debug/flip-clock.app
```

Run a single test (unit tests use **Swift Testing**, UI tests use **XCTest**):

```bash
xcodebuild -project flip-clock.xcodeproj -scheme flip-clock test \
  -only-testing:flip-clockTests/flip_clockTests/example
xcodebuild -project flip-clock.xcodeproj -scheme flip-clock test \
  -only-testing:flip-clockUITests/flip_clockUITests/testExample
```

Packaging: `./release.sh` builds Release, installs to `/Applications`, and writes a DMG to `release/`. The DMG step needs `create-dmg` (`brew install create-dmg`) and is skipped with a warning if it is missing.

## Project structure notes

- `project.pbxproj` uses `PBXFileSystemSynchronizedRootGroup` (objectVersion 77). **New `.swift` files dropped into `flip-clock/` are picked up automatically** — do not hand-edit the pbxproj to add sources.
- Deployment target is macOS **15.4** (the README's "macOS 12.0+" is stale). Sandboxed (`flip_clock.entitlements`), Swift 5, previews enabled.
- `flip-clock.app/` and `release/` at the repo root are build output committed into git, not sources. `flip-clock.zip` and `flip-clock.png` are release/icon-source assets.

## Architecture

**Everything time-based goes through `TimeTicker`** (`flip-clock/TimeTicker.swift`). It schedules a
one-shot `Timer` to the next true wall-clock boundary and re-arms from inside the fire block, so a
late or missed fire cannot accumulate drift; it installs on `RunLoop.main` in **`.common` mode**, so
ticks continue during live window resize, window drag, and menu tracking; and it re-fires on
`NSWorkspace.didWakeNotification`, `NSSystemClockDidChange`, and `NSSystemTimeZoneDidChange`. Three
independent instances: `ClockViewModel` (1 s, or 60 s when seconds are hidden), `AppDelegate` (60 s,
Dock icon), `AlarmManager` (1 s). Do not reintroduce a plain repeating `Timer` — the previous one
never re-aligned to the minute and was suspended during resize.

**`FlipMetrics` is the single source of truth for geometry** (`flip-clock/FlipMetrics.swift`). Card
size, spacings, and colon dots are all expressed in multiples of `fontSize`; `widthUnits(groups:)`
and `heightUnits` derive the footprint from those same constants, and `fontSize(fitting:groups:)`
inverts it so the clock fills the constraining axis exactly. `tileSize(fontSize:)` rounds the card to
an even whole number of points, because `FlipView` splits it down the middle and a fractional split
shows a seam. Change a constant here and the layout, the fit math, and the tests all follow — never
hardcode a spacing in a view.

**The flip card is drawn whole, then cropped.** `SingleFlipView` renders the full card and crops to
its top or bottom half via `.frame(height:alignment:)` + `.clipped()`. This matters: the original
selected each half with its own chain of negative paddings, which silently dropped ~0.033 × fontSize
of the glyph's middle and left strokes crossing the split visibly offset. Both halves must stay
crops of the same card. `FlipView` stacks top half + 1 pt separator + bottom half, each half a
`ZStack` of a static and a `rotation3DEffect`-rotated copy; `FlipViewModel.text`'s `didSet` drives
the two chained `withAnimation` blocks (top falls 0.2 s, bottom rises after a 0.2 s delay).

**Window chrome is applied from `ContentView.configure(_:)`** via `AppWindowAccessor`, which fires on
every SwiftUI update (not just creation) so hover state and always-on-top reach the window. The
titlebar itself is removed by `.windowStyle(.hiddenTitleBar)` on the scene — the AppKit style mask
alone does not remove SwiftUI's safe-area inset, which is what left a gray strip across the top.
Traffic lights and the alarm bell share one `chromeIsVisible` state driven by `.onHover`.
`isMovableByWindowBackground` is on because there is no titlebar left to grab.

**State ownership:** `AppSettings` and `AlarmManager` are `@StateObject`s on the `App` so `.commands`
can capture them, injected via `.environmentObject`. `ClockViewModel` is a `@StateObject` inside
`ClockView` — it was previously a plain `let` on the struct, which allocated a fresh view model and
timer on every body evaluation. Menu commands that need view state (`⌘N`, `⌘=`) post a
`Notification.Name` that `ContentView` observes.

**Alarms** (`AlarmManager`) are `Codable`, JSON-encoded into `UserDefaults` under `"alarms"`. Matching
is on hour+minute only; `lastFiredMinute` keyed by alarm id prevents a re-enabled alarm from firing
twice inside its own minute. Firing sets `ringingAlarm` (drives the banner), auto-disables the alarm,
loops the sound until silenced, and schedules a 60 s auto-silence.

**Colors** live only in `Color+Flip.swift`.

## Known gaps

- The clock and Dock icon use `"hh"` with no AM/PM indicator anywhere in the UI. Deliberate — the
  owner declined a meridiem/24-hour toggle.
- `NSApp` does not exist during `App.init()`. Appearance is set in `applicationDidFinishLaunching`;
  moving it back into `init()` crashes at launch.
- SwiftUI writes its own `NSWindow Frame SwiftUI…AppWindow-1` autosave key, which takes precedence
  over the explicit `setFrameAutosaveName` in `configure(_:)`.
