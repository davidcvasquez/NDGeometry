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
@testable import NDGeometry

final class NDAngleTests: XCTestCase {

    // MARK: - Init / Factories

    func testInitDefaultIsZero() {
        let a = NDAngle()
        XCTAssertEqual(a.radians, 0.0)
        XCTAssertTrue(a.isZero)
        XCTAssertFalse(a.isNonZero)
    }

    func testNDAngleInitByRadians() {
        let angle1 = NDAngle(radians: 1.0)
        XCTAssertEqual(angle1.radians, 1.0)

        let angle2: NDAngle = .radians(2.0)
        XCTAssertEqual(angle2.radians, 2.0)
    }

    func testInitByDegreesAndFactoryDegrees() {
        let a1 = NDAngle(degrees: 180.0)
        XCTAssertEqual(a1.radians, .pi, accuracy: 1e-6)

        let a2: NDAngle = .degrees(90.0)
        XCTAssertEqual(a2.radians, .pi / 2, accuracy: 1e-6)
    }

    // MARK: - Degrees computed property

    func testDegreesGetter() {
        let a = NDAngle(radians: .pi)
        XCTAssertEqual(a.degrees, 180.0, accuracy: 1e-6)
    }

    func testDegreesSetterUpdatesRadians() {
        var a = NDAngle(radians: 0.0)
        a.degrees = 90.0
        XCTAssertEqual(a.radians, .pi / 2, accuracy: 1e-6)
        XCTAssertEqual(a.degrees, 90.0, accuracy: 1e-6)
    }

    // MARK: - isZero / isNonZero

    func testIsZeroAndIsNonZero() {
        let zero = NDAngle()
        XCTAssertTrue(zero.isZero)
        XCTAssertFalse(zero.isNonZero)

        let nonZero = NDAngle(radians: 0.0001)
        XCTAssertFalse(nonZero.isZero)
        XCTAssertTrue(nonZero.isNonZero)
    }

    // MARK: - Normalization

    func testNormalizedRadiansAlreadyInRange() {
        let a = NDAngle(radians: 1.234)
        XCTAssertEqual(a.normalizedRadians, 1.234, accuracy: 1e-6)
        XCTAssertEqual(a.normalized, 1.234, accuracy: 1e-6)
    }

    func testNormalizedRadiansWrapsNegativeIntoRange() {
        // -π/2 should normalize to 3π/2
        let a = NDAngle(radians: -(.pi / 2))
        XCTAssertEqual(a.normalizedRadians, 3 * .pi / 2, accuracy: 1e-6)
    }

    func testNormalizedRadiansWrapsAboveTwoPiIntoRange() {
        // 5π should normalize to π (since 5π mod 2π = π)
        let a = NDAngle(radians: 5 * .pi)
        XCTAssertEqual(a.normalizedRadians, .pi, accuracy: 1e-6)
    }

    func testNormalizeMutatesRadians() {
        var a = NDAngle(radians: -(.pi / 2))
        a.normalize()
        XCTAssertEqual(a.radians, 3 * .pi / 2, accuracy: 1e-6)
    }

    func testNormalizedDegreesMatchesNormalizedRadians() {
        let a = NDAngle(radians: -(.pi / 2))
        XCTAssertEqual(a.normalizedDegrees, 270.0, accuracy: 1e-6)
    }

    // MARK: - Operators

    func testUnaryNegation() {
        let a = NDAngle(radians: 1.5)
        let b = -a
        XCTAssertEqual(b.radians, -1.5)
    }

    func testAdditionAndSubtraction() {
        let a = NDAngle(radians: 1.0)
        let b = NDAngle(radians: 2.5)

        XCTAssertEqual((a + b).radians, 3.5)
        XCTAssertEqual((b - a).radians, 1.5)
    }

    func testPlusEqualsAndMinusEquals() {
        var a = NDAngle(radians: 1.0)
        let b = NDAngle(radians: 2.5)

        a += b
        XCTAssertEqual(a.radians, 3.5)

        a -= NDAngle(radians: 0.5)
        XCTAssertEqual(a.radians, 3.0)
    }

    func testMultiplicationByScalar() {
        let a = NDAngle(radians: 2.0)
        let b = a * 3.0
        XCTAssertEqual(b.radians, 6.0)
    }

    func testDivisionByScalar() {
        let a = NDAngle(radians: 6.0)
        let b = a / 3.0
        XCTAssertEqual(b.radians, 2.0)
    }

    // MARK: - Comparable / Equatable / Hashable

    func testComparable() {
        let a = NDAngle(radians: 1.0)
        let b = NDAngle(radians: 2.0)

        XCTAssertTrue(a < b)
        XCTAssertFalse(b < a)
    }

    func testEquatable() {
        let a = NDAngle(radians: 1.0)
        let b = NDAngle(radians: 1.0)
        let c = NDAngle(radians: 1.0001)

        XCTAssertEqual(a, b)
        XCTAssertNotEqual(a, c)
    }

    func testHashableConsistentWithEquality() {
        let a1 = NDAngle(radians: 1.0)
        let a2 = NDAngle(radians: 1.0)

        XCTAssertEqual(a1, a2)

        var set = Set<NDAngle>()
        set.insert(a1)
        set.insert(a2)
        XCTAssertEqual(set.count, 1)
    }

    // MARK: - Codable

    func testCodableRoundTripEncodesRadiansKey() throws {
        let original = NDAngle(radians: 1.2345)

        let data = try JSONEncoder().encode(original)

        // Sanity check: key exists
        let json = String(data: data, encoding: .utf8) ?? ""
        XCTAssertTrue(json.contains("\"radians\""))

        let decoded = try JSONDecoder().decode(NDAngle.self, from: data)
        XCTAssertEqual(decoded.radians, original.radians, accuracy: 1e-6)
    }
}
