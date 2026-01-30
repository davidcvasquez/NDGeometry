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

final class NDPolarPointTests: XCTestCase {

    // MARK: - Init

    func testNDPolarPointInitByXY() {
        let point = NDPolarPoint(x: 3.0, y: 4.0)
        XCTAssertEqual(point.x, 3.0, accuracy: 1e-9)
        XCTAssertEqual(point.y, 4.0, accuracy: 1e-9)
    }

    func testInitByRhoTheta() {
        let p = NDPolarPoint(rho: 5.0, theta: .radians(.pi / 2))
        XCTAssertEqual(p.rho, 5.0)
        XCTAssertEqual(p.theta.radians, .pi / 2, accuracy: 1e-9)
        XCTAssertEqual(p.x, 0.0, accuracy: 1e-9)
        XCTAssertEqual(p.y, 5.0, accuracy: 1e-9)
    }

    func testInitByRhoDegrees() {
        let p = NDPolarPoint(rho: 2.0, degrees: 180.0)
        XCTAssertEqual(p.rho, 2.0)
        XCTAssertEqual(p.theta.degrees, 180.0, accuracy: 1e-9)
        XCTAssertEqual(p.x, -2.0, accuracy: 1e-9)
        XCTAssertEqual(p.y, 0.0, accuracy: 1e-9)
    }

    func testInitFromNDPointMatchesInitByXY() {
        let cart = NDPoint(x: 3.0, y: 4.0)
        let p1 = NDPolarPoint(cart)
        let p2 = NDPolarPoint(x: 3.0, y: 4.0)

        XCTAssertEqual(p1.rho, p2.rho, accuracy: 1e-9)
        XCTAssertEqual(p1.theta.radians, p2.theta.radians, accuracy: 1e-9)
        XCTAssertEqual(p1.x, p2.x, accuracy: 1e-9)
        XCTAssertEqual(p1.y, p2.y, accuracy: 1e-9)
    }

    // MARK: - Cartesian conversion

    func testCartesianPropertyMatchesXY() {
        let p = NDPolarPoint(x: 3.0, y: 4.0)
        let c = p.cartesian
        XCTAssertEqual(c.x, 3.0, accuracy: 1e-9)
        XCTAssertEqual(c.y, 4.0, accuracy: 1e-9)
    }

    func testCartesianRoundTripFromRhoTheta() {
        // pick an angle not aligned to axes
        let original = NDPolarPoint(rho: 10.0, theta: .radians(1.234))
        let c = original.cartesian
        let roundTrip = NDPolarPoint(c)

        XCTAssertEqual(roundTrip.rho, original.rho, accuracy: 1e-9)
        XCTAssertEqual(roundTrip.theta.radians, original.theta.radians, accuracy: 1e-9)
    }

    // MARK: - Rotate / Scale (mutating)

    func testRotateByMutatesThetaOnly() {
        var p = NDPolarPoint(rho: 5.0, theta: .radians(0.25))
        p.rotate(by: .radians(0.5))

        XCTAssertEqual(p.rho, 5.0)
        XCTAssertEqual(p.theta.radians, 0.75, accuracy: 1e-9)
    }

    func testScaleByMutatesRhoOnly() {
        var p = NDPolarPoint(rho: 5.0, theta: .radians(1.0))
        p.scale(by: 2.0)

        XCTAssertEqual(p.rho, 10.0, accuracy: 1e-9)
        XCTAssertEqual(p.theta.radians, 1.0, accuracy: 1e-9)
    }

    func testNormalizeThetaMutatesThetaIntoZeroToTwoPi() {
        var p = NDPolarPoint(rho: 1.0, theta: .radians(-.pi / 2))
        p.normalizeTheta()

        XCTAssertGreaterThanOrEqual(p.theta.radians, 0.0)
        XCTAssertLessThan(p.theta.radians, 2 * .pi)
        XCTAssertEqual(p.theta.radians, 3 * .pi / 2, accuracy: 1e-9)
    }

    // MARK: - rotated / scaled (non-mutating)

    func testRotatedReturnsNewValueAndDoesNotMutateOriginal() {
        let original = NDPolarPoint(rho: 5.0, theta: .radians(0.25))
        let rotated = original.rotated(by: .radians(0.5))

        XCTAssertEqual(original.rho, 5.0)
        XCTAssertEqual(original.theta.radians, 0.25, accuracy: 1e-9)

        XCTAssertEqual(rotated.rho, 5.0)
        XCTAssertEqual(rotated.theta.radians, 0.75, accuracy: 1e-9)
    }

    func testScaledReturnsNewValueAndDoesNotMutateOriginal() {
        let original = NDPolarPoint(rho: 5.0, theta: .radians(1.0))
        let scaled = original.scaled(by: 2.0)

        XCTAssertEqual(original.rho, 5.0, accuracy: 1e-9)
        XCTAssertEqual(original.theta.radians, 1.0, accuracy: 1e-9)

        XCTAssertEqual(scaled.rho, 10.0, accuracy: 1e-9)
        XCTAssertEqual(scaled.theta.radians, 1.0, accuracy: 1e-9)
    }

    // MARK: - Equatable / Hashable / Comparable

    func testEquatable() {
        let a = NDPolarPoint(rho: 5.0, theta: .radians(1.0))
        let b = NDPolarPoint(rho: 5.0, theta: .radians(1.0))
        let c = NDPolarPoint(rho: 5.0, theta: .radians(1.0001))
        let d = NDPolarPoint(rho: 6.0, theta: .radians(1.0))

        XCTAssertEqual(a, b)
        XCTAssertNotEqual(a, c)
        XCTAssertNotEqual(a, d)
    }

    func testHashableSetUniqueness() {
        let a = NDPolarPoint(rho: 5.0, theta: .radians(1.0))
        let b = NDPolarPoint(rho: 5.0, theta: .radians(1.0))

        var set = Set<NDPolarPoint>()
        set.insert(a)
        set.insert(b)
        XCTAssertEqual(set.count, 1)
    }

    func testComparableUsesBothRhoAndThetaAnd() {
        // Note: NDPolarPoint's `<` is implemented as:
        // lhs.rho < rhs.rho && lhs.theta < rhs.theta
        //
        // This is NOT a lexicographic ordering (and may not be a strict total order),
        // but we can still test that it matches the implementation.
        let a = NDPolarPoint(rho: 1.0, theta: .radians(1.0))
        let b = NDPolarPoint(rho: 2.0, theta: .radians(2.0))
        XCTAssertTrue(a < b)

        // rho smaller, theta larger => should be false due to &&
        let c = NDPolarPoint(rho: 1.0, theta: .radians(3.0))
        XCTAssertFalse(c < b)

        // rho larger, theta smaller => should be false due to &&
        let d = NDPolarPoint(rho: 3.0, theta: .radians(1.0))
        XCTAssertFalse(b < d)  // b.rho < d.rho is true, but b.theta < d.theta is false (2.0 < 1.0)
    }

    // MARK: - Codable

    func testCodableRoundTrip() throws {
        let original = NDPolarPoint(rho: 5.5, theta: .radians(1.234))

        let data = try JSONEncoder().encode(original)
        let json = String(data: data, encoding: .utf8) ?? ""
        XCTAssertTrue(json.contains("\"rho\""))
        XCTAssertTrue(json.contains("\"theta\""))

        let decoded = try JSONDecoder().decode(NDPolarPoint.self, from: data)
        XCTAssertEqual(decoded.rho, original.rho, accuracy: 1e-9)
        XCTAssertEqual(decoded.theta.radians, original.theta.radians, accuracy: 1e-9)
    }
}
