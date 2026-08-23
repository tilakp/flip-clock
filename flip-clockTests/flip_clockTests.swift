//
//  flip_clockTests.swift
//  flip-clockTests
//
//  Created by Tilak Patel on 4/19/25.
//

import Testing
import CoreGraphics
import Foundation
@testable import flip_clock

@Suite("Flip metrics")
struct FlipMetricsTests {

    /// The footprint derived from the layout constants, as the views actually assemble it.
    private func expectedWidthUnits(groups: Int) -> CGFloat {
        let tiles = CGFloat(groups * 2) * FlipMetrics.tileWidth
        let withinGroups = CGFloat(groups) * FlipMetrics.pairSpacing
        let colons = CGFloat(groups - 1) * FlipMetrics.colonWidth
        let aroundColons = CGFloat(2 * (groups - 1)) * FlipMetrics.groupSpacing
        return tiles + withinGroups + colons + aroundColons
    }

    @Test("Width units match the assembled row", arguments: [2, 3])
    func widthUnits(groups: Int) {
        #expect(abs(FlipMetrics.widthUnits(groups: groups) - expectedWidthUnits(groups: groups)) < 0.0001)
    }

    @Test func knownAspectRatios() {
        #expect(abs(FlipMetrics.widthUnits(groups: 3) - 6.13) < 0.0001)   // HH:MM:SS
        #expect(abs(FlipMetrics.widthUnits(groups: 2) - 3.98) < 0.0001)   // HH:MM
        #expect(abs(FlipMetrics.heightUnits - 1.2777) < 0.0001)
    }

    /// A wide, short window is height-constrained: the clock must touch top and bottom exactly.
    @Test("Fills the constraining axis exactly", arguments: [2, 3])
    func fillsConstrainingAxis(groups: Int) {
        let size = CGSize(width: 4000, height: 300)
        let fontSize = FlipMetrics.fontSize(fitting: size, groups: groups)
        let usedHeight = fontSize * FlipMetrics.heightUnits + FlipMetrics.separatorHeight
        #expect(abs(usedHeight - size.height) < 0.0001)
        #expect(fontSize * FlipMetrics.widthUnits(groups: groups) <= size.width)
    }

    /// The old formula (min(width / 6.5, height) * 0.8) left ~10% slack when width-constrained
    /// and overflowed by ~2% when height-constrained. Neither may happen now.
    @Test("Never overflows, never leaves slack on both axes", arguments: [
        CGSize(width: 800, height: 400),
        CGSize(width: 1600, height: 200),
        CGSize(width: 300, height: 900),
        CGSize(width: 512, height: 512)
    ])
    func fitsWithoutOverflow(size: CGSize) {
        for groups in [2, 3] {
            let fontSize = FlipMetrics.fontSize(fitting: size, groups: groups)
            let usedWidth = fontSize * FlipMetrics.widthUnits(groups: groups)
            let usedHeight = fontSize * FlipMetrics.heightUnits + FlipMetrics.separatorHeight

            #expect(usedWidth <= size.width + 0.0001)
            #expect(usedHeight <= size.height + 0.0001)
            // One axis is filled to the edge — that is what "bleed" means.
            let fillsWidth = abs(usedWidth - size.width) < 0.0001
            let fillsHeight = abs(usedHeight - size.height) < 0.0001
            #expect(fillsWidth || fillsHeight)
        }
    }

    /// FlipView splits a card down the middle, so an odd card height would put the split on a
    /// half-pixel and show a seam.
    @Test("Card height is always evenly splittable", arguments: [10.0, 47.3, 100.0, 146.87, 300.5])
    func tileHeightIsEven(fontSize: Double) {
        let size = FlipMetrics.tileSize(fontSize: CGFloat(fontSize))
        #expect(size.height.truncatingRemainder(dividingBy: 2) == 0)
        #expect(size.height == size.height.rounded())
        #expect(size.width == size.width.rounded())
        #expect(size.height <= CGFloat(fontSize) * FlipMetrics.tileHeight)
    }

    @Test func degenerateSizesAreSafe() {
        #expect(FlipMetrics.fontSize(fitting: .zero, groups: 3) == 0)
        #expect(FlipMetrics.fontSize(fitting: CGSize(width: 100, height: 0.5), groups: 3) == 0)
    }

}

@Suite("Time ticker")
struct TimeTickerTests {

    @Test func nextBoundaryIsStrictlyAfterAnExactBoundary() {
        let onTheMinute = Date(timeIntervalSinceReferenceDate: 600)
        let next = TimeTicker.nextBoundary(after: onTheMinute, interval: 60)
        #expect(next.timeIntervalSinceReferenceDate == 660)
    }

    @Test func nextBoundaryRoundsUpFromMidInterval() {
        let midSecond = Date(timeIntervalSinceReferenceDate: 42.37)
        #expect(TimeTicker.nextBoundary(after: midSecond, interval: 1).timeIntervalSinceReferenceDate == 43)
    }

    /// The whole point: minute ticks land on :00 of the wall clock, no matter when the app started.
    @Test func minuteBoundariesLandOnZeroSeconds() {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone.current
        for offset in stride(from: 0.0, to: 300.0, by: 7.3) {
            let start = Date(timeIntervalSinceReferenceDate: 1_000_000 + offset)
            let next = TimeTicker.nextBoundary(after: start, interval: 60)
            #expect(calendar.component(.second, from: next) == 0)
            #expect(next > start)
            #expect(next.timeIntervalSince(start) <= 60)
        }
    }

    @Test func nextBoundaryNeverExceedsOneInterval() {
        for offset in stride(from: 0.0, to: 5.0, by: 0.11) {
            let start = Date(timeIntervalSinceReferenceDate: offset)
            let next = TimeTicker.nextBoundary(after: start, interval: 1)
            #expect(next > start)
            #expect(next.timeIntervalSince(start) <= 1)
        }
    }

}
