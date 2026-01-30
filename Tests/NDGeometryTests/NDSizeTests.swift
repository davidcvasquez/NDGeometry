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

final class NDSizeTests: XCTestCase {

    // MARK: - Init

    func testNDSizeInitByWidthHeight() {
        let size = NDSize(width: 3.0, height: 4.0)
        XCTAssertEqual(size.width, 3.0)
        XCTAssertEqual(size.height, 4.0)
    }

    func testInitByIntWidthHeight() {
        let s = NDSize(width: 3, height: 4)
        XCTAssertEqual(s.width, 3.0)
        XCTAssertEqual(s.height, 4.0)
    }

    func testInitFromCGVector() {
        let v = CGVector(dx: 3.0, dy: 4.0)
        let s = NDSize(v)
        XCTAssertEqual(s.width, 3.0)
        XCTAssertEqual(s.height, 4.0)
    }

    func testInitFromCGPoint() {
        let p = CGPoint(x: 3.0, y: 4.0)
        let s = NDSize(p)
        XCTAssertEqual(s.width, 3.0)
        XCTAssertEqual(s.height, 4.0)
    }

    func testInitFromCGSizeAndCGSizeRoundTrip() {
        let cg = CGSize(width: 3.0, height: 4.0)
        let s = NDSize(cg)
        XCTAssertEqual(s.width, 3.0)
        XCTAssertEqual(s.height, 4.0)

        let cg2 = s.cgSize
        XCTAssertEqual(cg2.width, cg.width)
        XCTAssertEqual(cg2.height, cg.height)
    }

    // MARK: - Constants

    func testZeroAndOneConstants() {
        XCTAssertEqual(NDSize.zero, NDSize(width: 0.0, height: 0.0))
        XCTAssertEqual(NDSize.one, NDSize(width: 1.0, height: 1.0))
    }

    // MARK: - isEmpty

    func testIsEmptyTrueWhenAnySideIsZero() {
        XCTAssertTrue(NDSize(width: 0.0, height: 10.0).isEmpty)
        XCTAssertTrue(NDSize(width: 10.0, height: 0.0).isEmpty)
        XCTAssertTrue(NDSize(width: 0.0, height: 0.0).isEmpty)
        XCTAssertFalse(NDSize(width: 1.0, height: 1.0).isEmpty)
    }

    // MARK: - Halves

    func testHalfSizeAndHalfDimensions() {
        let s = NDSize(width: 10.0, height: 20.0)

        XCTAssertEqual(s.halfWidth, 5.0)
        XCTAssertEqual(s.halfHeight, 10.0)

        let half = s.halfSize
        XCTAssertEqual(half.width, 5.0)
        XCTAssertEqual(half.height, 10.0)
    }

    // MARK: - Smallest / Largest

    func testSmallestAndLargestSide() {
        let s = NDSize(width: 3.0, height: 4.0)
        XCTAssertEqual(s.smallestSide, 3.0)
        XCTAssertEqual(s.largestSide, 4.0)

        let t = NDSize(width: 9.0, height: 2.0)
        XCTAssertEqual(t.smallestSide, 2.0)
        XCTAssertEqual(t.largestSide, 9.0)
    }

    // MARK: - scaled(by:)

    func testScaledBy() {
        let s = NDSize(width: 3.0, height: 4.0)
        let t = s.scaled(by: 2.0)

        XCTAssertEqual(t.width, 6.0)
        XCTAssertEqual(t.height, 8.0)

        // Ensure non-mutating
        XCTAssertEqual(s.width, 3.0)
        XCTAssertEqual(s.height, 4.0)
    }

    // MARK: - roundedDescription

    func testRoundedDescriptionFormatsAndRounds() {
        let s = NDSize(width: 1.23456, height: 7.89123)
        let desc = s.roundedDescription

        // Expected with hundredths rounding: 1.23 and 7.89
        XCTAssertTrue(desc.contains("w: 1.23"))
        XCTAssertTrue(desc.contains("h: 7.89"))
        XCTAssertTrue(desc.hasPrefix("("))
        XCTAssertTrue(desc.hasSuffix(")"))
    }

    // MARK: - Magnitude

    func testMagnitudeSquared() {
        let s = NDSize(width: 3.0, height: 4.0)
        XCTAssertEqual(s.magnitudeSquared, 25.0)
    }

    // MARK: - Operators

    func testSubtractionOperator() {
        let a = NDSize(width: 10.0, height: 20.0)
        let b = NDSize(width: 3.0, height: 4.0)
        let c = a - b

        XCTAssertEqual(c.width, 7.0)
        XCTAssertEqual(c.height, 16.0)
    }

    func testMultiplicationOperator() {
        let a = NDSize(width: 3.0, height: 4.0)
        let b = a * 2.0

        XCTAssertEqual(b.width, 6.0)
        XCTAssertEqual(b.height, 8.0)
    }

    func testDivisionOperator() {
        let a = NDSize(width: 6.0, height: 8.0)
        let b = a / 2.0

        XCTAssertEqual(b.width, 3.0)
        XCTAssertEqual(b.height, 4.0)
    }

    // MARK: - Comparable

    func testComparableUsesMagnitudeSquared() {
        let small = NDSize(width: 3.0, height: 4.0)   // msq = 25
        let big   = NDSize(width: 6.0, height: 8.0)   // msq = 100

        XCTAssertTrue(small < big)
        XCTAssertFalse(big < small)
        XCTAssertTrue(small <= big)
        XCTAssertTrue(big >= small)
    }

    // MARK: - Hashable

    func testHashableSetUniqueness() {
        let a = NDSize(width: 3.0, height: 4.0)
        let b = NDSize(width: 3.0, height: 4.0)

        var set = Set<NDSize>()
        set.insert(a)
        set.insert(b)

        XCTAssertEqual(set.count, 1)
    }

    // MARK: - Codable

    func testCodableRoundTrip() throws {
        let original = NDSize(width: 10.5, height: -2.25)

        let data = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(NDSize.self, from: data)

        XCTAssertEqual(decoded, original)
    }
}
