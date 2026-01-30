//===----------------------------------------------------------------------===//
//
// This source file is part of the NDGeometry open source project
//
// Copyright (c) 2026 David C. Vasquez and the NDGeometry project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See the project's LICENSE.txt for license information
//
//===----------------------------------------------------------------------===//

import Foundation

public typealias NDFloat = CGFloat
public typealias Radians = NDFloat

/// A named precision for rounding.
nonisolated public enum RoundingPrecision {
    case ones
    case halves
    case quarters
    case tenths
    case hundredths
    case thousandths

    /// - Returns: The number of significant decimal places for this precision.
    public var decimalPlaces: Int {
        switch self {
        case .ones:
            0

        case .halves:       // .0 or .5
            1

        case .quarters:     // .00, .25, .50, or .75
            2

        case .tenths:       // .0, .1, .2, .3, etc.
            1

        case .hundredths:   // .00, .01, .02, .03, etc.
            2

        case .thousandths:  // .000, .001, .002, .003, etc.
            3
        }
    }

    /// - Returns: A factor used for an operation to calculate a rounded value.
    /// - Seealso: NDFloat.round() -> NDFloat
    public var roundingFactor: NDFloat {
        switch self {
        case .ones:
            1

        case .halves:       // .0 or .5
            2

        case .quarters:     // .00, .25, .50, or .75
            4

        case .tenths:       // .0, .1, .2, .3, etc.
            10

        case .hundredths:   // .00, .01, .02, .03, etc.
            100

        case .thousandths:  // .000, .001, .002, .003, etc.
            1000
        }
    }
}

/// Declare ** as an infix exponentiation operator, which is implemented by NDFloat.
infix operator **: MultiplicationPrecedence

nonisolated public extension NDFloat {
    static let π = NDFloat.pi
    static let τ = .π * 2.0

    /// - Returns: This value rounded to the given precision.
    @inlinable
    func rounded(_ precision: RoundingPrecision) -> NDFloat {
        Darwin.round(self * precision.roundingFactor) / precision.roundingFactor
    }

    /// Round this value to the given precision.
    @inlinable
    mutating func round(_ precision: RoundingPrecision) {
        self = self.rounded(precision)
    }

    /// Unary (prefix) negation operator.
    @inlinable
    static prefix func - (p: NDFloat) -> NDFloat {
        0 - p
    }

    /// Infix exponentiation operator
    @inlinable
    static func **(base: NDFloat, exp: NDFloat) -> NDFloat {
        return NDFloat(pow(Double(base), Double(exp)))
    }

    @inline(__always)
    static func percent<V: BinaryFloatingPoint>(_ value: V) -> V {
        value * 0.01
    }

    @inline(__always)
    static func degreesAsPercent<V: BinaryFloatingPoint>(_ value: V) -> V {
        value / 360.0
    }

    static let degreesToRadians: NDFloat = .τ / 360
    @inlinable
    var degreesToRadians: NDFloat {
        self * Self.degreesToRadians
    }

    static let radiansToDegrees: NDFloat = 360 / .τ
    @inlinable
    var radiansToDegrees: NDFloat {
        self * Self.radiansToDegrees
    }

    static let zero = NDFloat(0.0)
    static let one = NDFloat(1.0)
    static let halfUnit: NDFloat = .one * 0.5

    static let unitWidth: NDFloat = .one
    static let unitHeight: NDFloat = .one

    static let halfUnitWidth: NDFloat = .one * 0.5
    static let halfUnitHeight: NDFloat = .one * 0.5

    static let unitFloatToPercent = NDFloat(100.0)
}

nonisolated public extension Comparable {
    /// Clamp a value to a closed range of values.
    /// ```
    ///    15.clamped(to: 0...10) // returns 10
    ///    3.0.clamped(to: 0.0...10.0) // returns 3.0
    ///    "a".clamped(to: "g"..."y") // returns "g"
    ///
    ///    // this also works (thanks to Strideable extension)
    ///    let range: CountableClosedRange<Int> = 0...10
    ///    15.clamped(to: range) // returns 10
    /// ```
    @inlinable
    func clamped(to limits: ClosedRange<Self>) -> Self {
        return min(max(self, limits.lowerBound), limits.upperBound)
    }
}

nonisolated public extension ClosedRange<NDFloat> {
    static let unitRange = NDFloat(0)...NDFloat(1.0)
    static let signedUnitRange = NDFloat(-1.0)...NDFloat(1.0)
}

nonisolated public func smoothstep(_ t: NDFloat) -> NDFloat {
    t * t * (3 - 2 * t)
}

/// - Returns: The interpolated thickness across a signed range of thickness values for the given signed arc lengths.
nonisolated public func smoothInterpolatedThickness(
    s: Double,
    negativeArcLength: NDFloat,
    positiveArcLength: NDFloat,
    negativeThickness: NDFloat,
    centerThickness: NDFloat,
    positiveThickness: NDFloat
) -> NDFloat {

    let s_mid = (negativeArcLength + positiveArcLength) * 0.5

    if s <= s_mid {
        let length = s_mid - negativeArcLength
        if length == 0 {
            return centerThickness  // Degenerate case: no left segment
        }
        let t = (s - negativeArcLength) / length
        return lerp(negativeThickness, centerThickness, smoothstep(t))
    } else {
        let length = positiveArcLength - s_mid
        if length == 0 {
            return centerThickness  // Degenerate case: no right segment
        }
        let t = (s - s_mid) / length
        return lerp(centerThickness, positiveThickness, smoothstep(t))
    }
}
