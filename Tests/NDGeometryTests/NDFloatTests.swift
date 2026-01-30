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

import XCTest
import NDGeometry

final class NDFloatTests: XCTestCase {

    // MARK: - Unary negation

    func testNDFloatUnaryNegationOperator() {
        let value = NDFloat(5.0)
        let negativeValue = -value
        XCTAssertEqual(negativeValue, -5.0)
    }

    func testUnaryNegationOfNegativeValue() {
        let value = NDFloat(-12.5)
        XCTAssertEqual(-value, 12.5)
    }

    // MARK: - Constants (π, τ, zero/one, etc.)

    func testPiAndTauConstants() {
        XCTAssertEqual(NDFloat.π, NDFloat.pi, accuracy: 1e-12)
        XCTAssertEqual(NDFloat.τ, 2.0 * NDFloat.π, accuracy: 1e-12)
    }

    func testZeroOneAndHalfUnit() {
        XCTAssertEqual(NDFloat.zero, 0.0)
        XCTAssertEqual(NDFloat.one, 1.0)
        XCTAssertEqual(NDFloat.halfUnit, 0.5, accuracy: 1e-12)
    }

    func testUnitWidthHeightAndHalves() {
        XCTAssertEqual(NDFloat.unitWidth, 1.0)
        XCTAssertEqual(NDFloat.unitHeight, 1.0)
        XCTAssertEqual(NDFloat.halfUnitWidth, 0.5, accuracy: 1e-12)
        XCTAssertEqual(NDFloat.halfUnitHeight, 0.5, accuracy: 1e-12)
    }

    func testUnitFloatToPercent() {
        XCTAssertEqual(NDFloat.unitFloatToPercent, 100.0)
    }

    // MARK: - RoundingPrecision

    func testRoundingPrecisionDecimalPlaces() {
        XCTAssertEqual(RoundingPrecision.ones.decimalPlaces, 0)
        XCTAssertEqual(RoundingPrecision.halves.decimalPlaces, 1)
        XCTAssertEqual(RoundingPrecision.quarters.decimalPlaces, 2)
        XCTAssertEqual(RoundingPrecision.tenths.decimalPlaces, 1)
        XCTAssertEqual(RoundingPrecision.hundredths.decimalPlaces, 2)
        XCTAssertEqual(RoundingPrecision.thousandths.decimalPlaces, 3)
    }

    func testRoundingPrecisionRoundingFactors() {
        XCTAssertEqual(RoundingPrecision.ones.roundingFactor, 1.0)
        XCTAssertEqual(RoundingPrecision.halves.roundingFactor, 2.0)
        XCTAssertEqual(RoundingPrecision.quarters.roundingFactor, 4.0)
        XCTAssertEqual(RoundingPrecision.tenths.roundingFactor, 10.0)
        XCTAssertEqual(RoundingPrecision.hundredths.roundingFactor, 100.0)
        XCTAssertEqual(RoundingPrecision.thousandths.roundingFactor, 1000.0)
    }

    // MARK: - rounded(_:) and round(_:)

    func testRoundedOnes() {
        XCTAssertEqual(NDFloat(3.2).rounded(.ones), 3.0, accuracy: 1e-12)
        XCTAssertEqual(NDFloat(3.7).rounded(.ones), 4.0, accuracy: 1e-12)
        XCTAssertEqual(NDFloat(-3.2).rounded(.ones), -3.0, accuracy: 1e-12)
        XCTAssertEqual(NDFloat(-3.7).rounded(.ones), -4.0, accuracy: 1e-12)
    }

    func testRoundedHalves() {
        XCTAssertEqual(NDFloat(1.24).rounded(.halves), 1.0, accuracy: 1e-12)
        XCTAssertEqual(NDFloat(1.26).rounded(.halves), 1.5, accuracy: 1e-12)
        XCTAssertEqual(NDFloat(1.74).rounded(.halves), 1.5, accuracy: 1e-12)
        XCTAssertEqual(NDFloat(1.76).rounded(.halves), 2.0, accuracy: 1e-12)
    }

    func testRoundedQuarters() {
        XCTAssertEqual(NDFloat(1.12).rounded(.quarters), 1.0, accuracy: 1e-12)
        XCTAssertEqual(NDFloat(1.13).rounded(.quarters), 1.25, accuracy: 1e-12)
        XCTAssertEqual(NDFloat(1.37).rounded(.quarters), 1.25, accuracy: 1e-12)
        XCTAssertEqual(NDFloat(1.38).rounded(.quarters), 1.5, accuracy: 1e-12)
        XCTAssertEqual(NDFloat(1.62).rounded(.quarters), 1.5, accuracy: 1e-12)
        XCTAssertEqual(NDFloat(1.63).rounded(.quarters), 1.75, accuracy: 1e-12)
    }

    func testRoundedTenthsHundredthsThousandths() {
        XCTAssertEqual(NDFloat(1.04).rounded(.tenths), 1.0, accuracy: 1e-12)
        XCTAssertEqual(NDFloat(1.05).rounded(.tenths), 1.1, accuracy: 1e-12)

        XCTAssertEqual(NDFloat(1.234).rounded(.hundredths), 1.23, accuracy: 1e-12)
        XCTAssertEqual(NDFloat(1.235).rounded(.hundredths), 1.24, accuracy: 1e-12)

        XCTAssertEqual(NDFloat(1.2344).rounded(.thousandths), 1.234, accuracy: 1e-12)
        XCTAssertEqual(NDFloat(1.2345).rounded(.thousandths), 1.235, accuracy: 1e-12)
    }

    func testMutatingRound() {
        var value: NDFloat = 1.234
        value.round(.hundredths)
        XCTAssertEqual(value, 1.23, accuracy: 1e-12)
    }

    // MARK: - Exponentiation operator **

    func testExponentiationOperator() {
        XCTAssertEqual(NDFloat(2.0) ** 3.0, 8.0, accuracy: 1e-12)
        XCTAssertEqual(NDFloat(9.0) ** 0.5, 3.0, accuracy: 1e-12)
        XCTAssertEqual(NDFloat(5.0) ** 0.0, 1.0, accuracy: 1e-12)
    }

    // MARK: - Percent helpers

    func testPercent() {
        XCTAssertEqual(NDFloat.percent(0.0 as NDFloat), 0.0, accuracy: 1e-12)
        XCTAssertEqual(NDFloat.percent(50.0 as NDFloat), 0.5, accuracy: 1e-12)
        XCTAssertEqual(NDFloat.percent(12.5 as NDFloat), 0.125, accuracy: 1e-12)
    }

    func testDegreesAsPercent() {
        XCTAssertEqual(NDFloat.degreesAsPercent(0.0 as NDFloat), 0.0, accuracy: 1e-12)
        XCTAssertEqual(NDFloat.degreesAsPercent(180.0 as NDFloat), 0.5, accuracy: 1e-12)
        XCTAssertEqual(NDFloat.degreesAsPercent(360.0 as NDFloat), 1.0, accuracy: 1e-12)
    }

    // MARK: - Degrees/Radians conversion

    func testDegreesToRadiansAndRadiansToDegrees() {
        XCTAssertEqual(NDFloat.degreesToRadians, NDFloat.τ / 360.0, accuracy: 1e-12)
        XCTAssertEqual(NDFloat.radiansToDegrees, 360.0 / NDFloat.τ, accuracy: 1e-12)

        XCTAssertEqual(NDFloat(180.0).degreesToRadians, NDFloat.π, accuracy: 1e-12)
        XCTAssertEqual(NDFloat(90.0).degreesToRadians, NDFloat.π / 2.0, accuracy: 1e-12)

        XCTAssertEqual(NDFloat(NDFloat.π).radiansToDegrees, 180.0, accuracy: 1e-12)
        XCTAssertEqual(NDFloat(NDFloat.π / 2.0).radiansToDegrees, 90.0, accuracy: 1e-12)
    }

    func testDegreesRadiansRoundTrip() {
        let degrees: NDFloat = 37.25
        let radians = degrees.degreesToRadians
        let degrees2 = radians.radiansToDegrees
        XCTAssertEqual(degrees2, degrees, accuracy: 1e-10)
    }

    // MARK: - Comparable.clamped(to:)

    func testClampedWithInts() {
        XCTAssertEqual(15.clamped(to: 0...10), 10)
        XCTAssertEqual((-5).clamped(to: 0...10), 0)
        XCTAssertEqual(7.clamped(to: 0...10), 7)
    }

    func testClampedWithFloats() {
        let a: NDFloat = 15.0
        let b: NDFloat = -2.0
        let c: NDFloat = 0.25

        XCTAssertEqual(a.clamped(to: 0.0...10.0), 10.0, accuracy: 1e-12)
        XCTAssertEqual(b.clamped(to: 0.0...10.0), 0.0, accuracy: 1e-12)
        XCTAssertEqual(c.clamped(to: 0.0...10.0), 0.25, accuracy: 1e-12)
    }

    func testClampedWithStrings() {
        XCTAssertEqual("a".clamped(to: "g"..."y"), "g")
        XCTAssertEqual("z".clamped(to: "g"..."y"), "y")
        XCTAssertEqual("m".clamped(to: "g"..."y"), "m")
    }

    // MARK: - ClosedRange<NDFloat> unit ranges

    func testUnitRanges() {
        XCTAssertEqual(ClosedRange<NDFloat>.unitRange.lowerBound, 0.0)
        XCTAssertEqual(ClosedRange<NDFloat>.unitRange.upperBound, 1.0)

        XCTAssertEqual(ClosedRange<NDFloat>.signedUnitRange.lowerBound, -1.0)
        XCTAssertEqual(ClosedRange<NDFloat>.signedUnitRange.upperBound, 1.0)
    }

    // MARK: - smoothstep(t)

    func testSmoothstepEndpointsAndMidpoint() {
        XCTAssertEqual(smoothstep(0.0), 0.0, accuracy: 1e-12)
        XCTAssertEqual(smoothstep(1.0), 1.0, accuracy: 1e-12)
        XCTAssertEqual(smoothstep(0.5), 0.5, accuracy: 1e-12)
    }

    func testSmoothstepShape() {
        // smoothstep should ease-in/ease-out: at 0.25 it should be < 0.25, at 0.75 it should be > 0.75
        XCTAssertLessThan(smoothstep(0.25), 0.25)
        XCTAssertGreaterThan(smoothstep(0.75), 0.75)
    }

    // MARK: - smoothInterpolatedThickness

    func testSmoothInterpolatedThicknessAtEndpointsAndCenter() {
        let negArc: NDFloat = 0.0
        let posArc: NDFloat = 10.0
        let negThick: NDFloat = 2.0
        let centerThick: NDFloat = 4.0
        let posThick: NDFloat = 6.0

        let mid = Double((negArc + posArc) * 0.5)

        XCTAssertEqual(
            smoothInterpolatedThickness(
                s: Double(negArc),
                negativeArcLength: negArc,
                positiveArcLength: posArc,
                negativeThickness: negThick,
                centerThickness: centerThick,
                positiveThickness: posThick
            ),
            negThick,
            accuracy: 1e-9
        )

        XCTAssertEqual(
            smoothInterpolatedThickness(
                s: mid,
                negativeArcLength: negArc,
                positiveArcLength: posArc,
                negativeThickness: negThick,
                centerThickness: centerThick,
                positiveThickness: posThick
            ),
            centerThick,
            accuracy: 1e-9
        )

        XCTAssertEqual(
            smoothInterpolatedThickness(
                s: Double(posArc),
                negativeArcLength: negArc,
                positiveArcLength: posArc,
                negativeThickness: negThick,
                centerThickness: centerThick,
                positiveThickness: posThick
            ),
            posThick,
            accuracy: 1e-9
        )
    }

    func testSmoothInterpolatedThicknessDegenerateLeftSegmentReturnsCenter() {
        // negativeArcLength == positiveArcLength => s_mid == negArc, left segment length == 0
        let negArc: NDFloat = 5.0
        let posArc: NDFloat = 5.0

        let result = smoothInterpolatedThickness(
            s: Double(negArc),
            negativeArcLength: negArc,
            positiveArcLength: posArc,
            negativeThickness: 1.0,
            centerThickness: 3.0,
            positiveThickness: 10.0
        )
        XCTAssertEqual(result, 3.0, accuracy: 1e-12)
    }

    func testSmoothInterpolatedThicknessDegenerateRightSegmentReturnsCenter() {
        // Make s_mid == positiveArcLength so right segment length == 0:
        // This happens when positiveArcLength == negativeArcLength (already covered), OR more generally:
        // right length = positiveArcLength - s_mid == 0 => positiveArcLength == (negArc + posArc)/2 => posArc == negArc
        // So we test the same degenerate but drive the else branch by setting s > s_mid.
        let negArc: NDFloat = 5.0
        let posArc: NDFloat = 5.0
        let mid = Double((negArc + posArc) * 0.5)

        let result = smoothInterpolatedThickness(
            s: mid + 1.0, // ensures else branch
            negativeArcLength: negArc,
            positiveArcLength: posArc,
            negativeThickness: 1.0,
            centerThickness: 3.0,
            positiveThickness: 10.0
        )
        XCTAssertEqual(result, 3.0, accuracy: 1e-12)
    }

    func testSmoothInterpolatedThicknessMonotonicAcrossRange() {
        // With increasing thicknesses, the function should stay within [min,max] and be monotonic-ish.
        let negArc: NDFloat = 0.0
        let posArc: NDFloat = 10.0
        let negThick: NDFloat = 2.0
        let centerThick: NDFloat = 4.0
        let posThick: NDFloat = 8.0

        let values: [NDFloat] = stride(from: 0.0, through: 10.0, by: 1.0).map { s in
            smoothInterpolatedThickness(
                s: s,
                negativeArcLength: negArc,
                positiveArcLength: posArc,
                negativeThickness: negThick,
                centerThickness: centerThick,
                positiveThickness: posThick
            )
        }

        // Should stay within bounds
        for v in values {
            XCTAssertGreaterThanOrEqual(v, negThick - 1e-9)
            XCTAssertLessThanOrEqual(v, posThick + 1e-9)
        }

        // Simple check: start <= mid <= end for this increasing case
        XCTAssertLessThanOrEqual(values.first ?? 0.0, values[5] + 1e-9)
        XCTAssertLessThanOrEqual(values[5], values.last ?? 0.0 + 1e-9)
    }
}
