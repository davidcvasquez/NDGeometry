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
import CoreGraphics

final class NDVectorTests: XCTestCase {

    // MARK: - Init / bridging / constants

    func testNDVectorInitBydXdY() {
        let vector = NDVector(dx: 3.0, dy: 4.0)
        XCTAssertEqual(vector.dx, 3.0)
        XCTAssertEqual(vector.dy, 4.0)
    }

    func testInitFromCGVectorAndCgVectorRoundTrip() {
        let cg = CGVector(dx: 1.25, dy: -2.5)
        let v = NDVector(cg)
        XCTAssertEqual(v.dx, 1.25)
        XCTAssertEqual(v.dy, -2.5)

        let cg2 = v.cgVector
        XCTAssertEqual(cg2.dx, cg.dx)
        XCTAssertEqual(cg2.dy, cg.dy)
    }

    func testInitFromCGPoint() {
        let p = CGPoint(x: 3.0, y: 4.0)
        let v = NDVector(p)
        XCTAssertEqual(v.dx, 3.0)
        XCTAssertEqual(v.dy, 4.0)
    }

    func testInitFromNDPoint() {
        let p = NDPoint(x: 3.0, y: 4.0)
        let v = NDVector(p)
        XCTAssertEqual(v.dx, 3.0)
        XCTAssertEqual(v.dy, 4.0)
    }

    func testInitFromNDSize() {
        let s = NDSize(width: 3.0, height: 4.0)
        let v = NDVector(s)
        XCTAssertEqual(v.dx, 3.0)
        XCTAssertEqual(v.dy, 4.0)
    }

    func testInitByRhoThetaUsesInvertedY() {
        // dy = sin(θ) * -(ρ)
        let v = NDVector(ρ: 10.0, θ: .pi / 2)
        XCTAssertEqual(v.dx, 0.0, accuracy: 1e-9)
        XCTAssertEqual(v.dy, -10.0, accuracy: 1e-9)
    }

    func testZeroAndOneConstants() {
        XCTAssertEqual(NDVector.zero, NDVector(dx: 0.0, dy: 0.0))
        XCTAssertEqual(NDVector.one, NDVector(dx: 1.0, dy: 1.0))
    }

    // MARK: - Description

    func testRoundedDescriptionFormatsAndRounds() {
        let v = NDVector(dx: 1.23456, dy: 7.89123)
        let desc = v.roundedDescription

        XCTAssertTrue(desc.contains("dx: 1.23"))
        XCTAssertTrue(desc.contains("dy: 7.89"))
        XCTAssertTrue(desc.hasPrefix("("))
        XCTAssertTrue(desc.hasSuffix(")"))
    }

    // MARK: - Magnitude / derived properties

    func testMagnitudeAndMagnitudeSquared() {
        let v = NDVector(dx: 3.0, dy: 4.0)
        XCTAssertEqual(v.magnitude, 5.0, accuracy: 1e-9)
        XCTAssertEqual(v.magnitudeSquared, 25.0)
    }

    func testRhoThetaDiameterArcLength() {
        let v = NDVector(dx: 3.0, dy: 4.0)
        XCTAssertEqual(v.ρ, 5.0, accuracy: 1e-9)
        XCTAssertEqual(v.θ, atan2(4.0, 3.0), accuracy: 1e-9)
        XCTAssertEqual(v.diameter, 10.0, accuracy: 1e-9)
        XCTAssertEqual(v.s, v.θ * v.ρ, accuracy: 1e-9)
    }

    func testTanAndCotanAreUnitAndPerpendicularForNonZeroVector() {
        let v = NDVector(dx: 3.0, dy: 4.0)

        let t = v.tan
        let c = v.cotan

        XCTAssertEqual(t.magnitude, 1.0, accuracy: 1e-9)
        XCTAssertEqual(c.magnitude, 1.0, accuracy: 1e-9)

        // Perpendicular to original: dot ~= 0
        XCTAssertEqual((NDVector(dx: v.dx, dy: v.dy) • t), 0.0, accuracy: 1e-9)
        XCTAssertEqual((NDVector(dx: v.dx, dy: v.dy) • c), 0.0, accuracy: 1e-9)

        // Opposite directions: tan == -cotan (for this definition)
        XCTAssertEqual(t.dx, -c.dx, accuracy: 1e-9)
        XCTAssertEqual(t.dy, -c.dy, accuracy: 1e-9)
    }

    func testNormalizedUnitLengthAndZeroBehavior() {
        let v = NDVector(dx: 3.0, dy: 4.0)
        let u = v.normalized
        XCTAssertEqual(u.magnitude, 1.0, accuracy: 1e-9)
        XCTAssertEqual(u.dx, 0.6, accuracy: 1e-9)
        XCTAssertEqual(u.dy, 0.8, accuracy: 1e-9)

        let z = NDVector.zero.normalized
        XCTAssertEqual(z, .zero)
    }

    func testNormalizeMutates() {
        var v = NDVector(dx: 3.0, dy: 4.0)
        v.normalize()
        XCTAssertEqual(v.magnitude, 1.0, accuracy: 1e-9)
    }

    // MARK: - Operators

    func testAddVectorAndScalar() {
        let v = NDVector(dx: 1.0, dy: 2.0)
        let w = v + 3.0
        XCTAssertEqual(w.dx, 4.0)
        XCTAssertEqual(w.dy, 5.0)
    }

    func testAddAndSubtractVectors() {
        let a = NDVector(dx: 1.0, dy: 2.0)
        let b = NDVector(dx: 3.0, dy: 4.0)

        let sum = a + b
        XCTAssertEqual(sum.dx, 4.0)
        XCTAssertEqual(sum.dy, 6.0)

        let diff = b - a
        XCTAssertEqual(diff.dx, 2.0)
        XCTAssertEqual(diff.dy, 2.0)
    }

    func testMultiplyDivideByScalar() {
        let v = NDVector(dx: 3.0, dy: 4.0)

        let m = v * 2.0
        XCTAssertEqual(m.dx, 6.0)
        XCTAssertEqual(m.dy, 8.0)

        let d = v / 2.0
        XCTAssertEqual(d.dx, 1.5, accuracy: 1e-9)
        XCTAssertEqual(d.dy, 2.0, accuracy: 1e-9)
    }

    func testMultiplyBySize() {
        let v = NDVector(dx: 2.0, dy: 3.0)
        let s = NDSize(width: 10.0, height: 20.0)

        let r = v * s
        XCTAssertEqual(r.dx, 20.0)
        XCTAssertEqual(r.dy, 60.0)
    }

    func testDotProductOperator() {
        let a = NDVector(dx: 1.0, dy: 2.0)
        let b = NDVector(dx: 3.0, dy: 4.0)

        XCTAssertEqual(a • b, 11.0) // 1*3 + 2*4
    }

    // MARK: - cartesianToPolar

    func testCartesianToPolarMatchesImplementation() {
        let v = NDVector(dx: 1.5, dy: 2.0)
        let p = v.cartesianToPolar

        // Implementation: NDVector(ρ: self.dx, θ: -self.dy * 2)
        let expected = NDVector(ρ: 1.5, θ: -2.0 * 2.0)
        XCTAssertEqual(p.dx, expected.dx, accuracy: 1e-9)
        XCTAssertEqual(p.dy, expected.dy, accuracy: 1e-9)
    }

    // MARK: - Distance

    func testDistanceTo() {
        let a = NDVector(dx: 0.0, dy: 0.0)
        let b = NDVector(dx: 3.0, dy: 4.0)
        XCTAssertEqual(a.distance(to: b), 5.0, accuracy: 1e-9)
        XCTAssertEqual(b.distance(to: a), 5.0, accuracy: 1e-9)
    }

    // MARK: - Signed angular distance θ(another)

    func testThetaToAnotherVectorBasicCases() {
        let x = NDVector(dx: 1.0, dy: 0.0)
        let y = NDVector(dx: 0.0, dy: 1.0)
        let ny = NDVector(dx: 0.0, dy: -1.0)

        // x -> y should be +pi/2 (CCW)
        XCTAssertEqual(x.θ(y), .pi / 2, accuracy: 1e-9)

        // x -> -y should be -pi/2 (CW)
        XCTAssertEqual(x.θ(ny), -(.pi / 2), accuracy: 1e-9)
    }

    func testThetaToAnotherVectorZeroMagnitudeReturnsZero() {
        let z = NDVector.zero
        let x = NDVector(dx: 1.0, dy: 0.0)
        XCTAssertEqual(z.θ(x), 0.0)
        XCTAssertEqual(x.θ(z), 0.0)
    }

    // MARK: - nearbyθ(another, hint:)

    func testNearbyThetaPrefersNearestToHintAcrossWrap() {
        // If the true angle is near -π but hint is near +π (or vice versa),
        // nearbyθ should return a value close to the hint rather than jumping by ~2π.
        let a = NDVector(dx: 1.0, dy: 0.0)
        let b = NDVector(dx: -1.0, dy: 0.0)

        // a -> b is π (or -π depending on sign logic; in this implementation it's +π)
        let raw = a.θ(b)
        XCTAssertEqual(abs(raw), .pi, accuracy: 1e-9)

        // Hint is slightly above +π; nearby should stay near that neighborhood
        let hint: NDFloat = .pi + 0.1
        let near = a.nearbyθ(b, hint: hint)

        // Should be within π of hint (i.e. no 2π jump)
        XCTAssertLessThan(abs(near - hint), .pi + 1e-6)
    }

    // MARK: - Comparable / Hashable / Codable

    func testComparableUsesMagnitudeSquared() {
        let a = NDVector(dx: 3.0, dy: 4.0) // 25
        let b = NDVector(dx: 6.0, dy: 8.0) // 100
        XCTAssertTrue(a < b)
        XCTAssertFalse(b < a)
        XCTAssertTrue(a <= b)
        XCTAssertTrue(b >= a)
    }

    func testHashableSetUniqueness() {
        let a = NDVector(dx: 1.0, dy: 2.0)
        let b = NDVector(dx: 1.0, dy: 2.0)

        var set = Set<NDVector>()
        set.insert(a)
        set.insert(b)
        XCTAssertEqual(set.count, 1)
    }

    func testCodableRoundTrip() throws {
        let original = NDVector(dx: 10.5, dy: -2.25)
        let data = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(NDVector.self, from: data)
        XCTAssertEqual(decoded, original)
    }
}
