import CoreGraphics

/// The flip clock's geometry, expressed in multiples of `fontSize`.
///
/// Single source of truth: `SingleFlipView` and `ClockView` lay out from these constants, and the
/// fit math below derives the exact footprint from the same numbers, so the clock can be sized to
/// fill its window precisely instead of guessing at a fudge factor.
enum FlipMetrics {

    // Card geometry, in multiples of fontSize. A card holds one digit; FlipView splits it in
    // half across the separator.
    static let tileWidth: CGFloat = 0.88
    static let tileHeight: CGFloat = 1.2778

    // Row geometry, as used by ClockView.
    static let pairSpacing: CGFloat = 0.07       // between the two digits of a group
    static let groupSpacing: CGFloat = 0.11      // between a group and a colon
    /// The colon is drawn as two circles rather than a ":" glyph: a Text clips to its frame
    /// instead of overhanging it, so a narrow frame sliced the dots in half.
    static let colonWidth: CGFloat = 0.10        // == dot diameter, no side bearings to pay for
    static let colonDotDiameter: CGFloat = 0.10
    static let colonDotGap: CGFloat = 0.10       // vertical space between the two dots
    static let separatorHeight: CGFloat = 1      // points — the hairline in FlipView, not scaled

    /// Breathing room on each side of the clock, in fontSize units. Because it scales with the
    /// font it stays proportional at every window size, and it folds into the fit math below as
    /// two extra units per axis rather than needing a separate padding pass.
    static let margin: CGFloat = 0.12

    // Flip animation.
    static let flipPerspective: CGFloat = 0.42
    /// How dark a leaf goes when it is edge-on to the light.
    static let leafMaxShade: Double = 0.55

    /// Card corner radius, scaled so large digits don't look sharp-cornered.
    static func cornerRadius(fontSize: CGFloat) -> CGFloat { max(3, fontSize * 0.028) }


    /// Total width, in font-size units, of `groups` two-digit groups separated by colons.
    /// 3 groups (HH:MM:SS) ≈ 7.29, 2 groups (HH:MM) ≈ 4.56.
    static func widthUnits(groups: Int) -> CGFloat {
        guard groups > 0 else { return 0 }
        let tiles = CGFloat(groups * 2) * tileWidth
        let withinGroups = CGFloat(groups) * pairSpacing
        let colons = CGFloat(groups - 1) * colonWidth
        let aroundColons = CGFloat(2 * (groups - 1)) * groupSpacing
        return tiles + withinGroups + colons + aroundColons
    }

    static let heightUnits = tileHeight

    /// Card size in points, rounded so the half-way split lands on whole pixels — a fractional
    /// split shows up as a seam between the two halves.
    static func tileSize(fontSize: CGFloat) -> CGSize {
        let height = max((fontSize * tileHeight).rounded(.down), 2)
        return CGSize(width: (fontSize * tileWidth).rounded(),
                      height: height - height.truncatingRemainder(dividingBy: 2))
    }

    /// The height at which a clock of the given width has equal margins on all four sides.
    static func fittedHeight(forWidth width: CGFloat, groups: Int) -> CGFloat {
        guard groups > 0, width > 0 else { return 0 }
        let fontSize = width / (widthUnits(groups: groups) + 2 * margin)
        return contentSize(fontSize: fontSize, groups: groups).height
    }

    /// Total space the clock occupies at this font size, margins included. `fontSize(fitting:)`
    /// is its inverse, so the two can't drift apart.
    static func contentSize(fontSize: CGFloat, groups: Int) -> CGSize {
        CGSize(width: fontSize * (widthUnits(groups: groups) + 2 * margin),
               height: fontSize * (heightUnits + 2 * margin) + separatorHeight)
    }

    /// The largest font size whose clock, margins included, fits `size` — it fills the
    /// constraining axis exactly and never overflows the other.
    static func fontSize(fitting size: CGSize, groups: Int) -> CGFloat {
        guard groups > 0, size.width > 0, size.height > 0 else { return 0 }
        let usableHeight = max(size.height - separatorHeight, 0)
        return max(min(size.width / (widthUnits(groups: groups) + 2 * margin),
                       usableHeight / (heightUnits + 2 * margin)), 0)
    }

}
