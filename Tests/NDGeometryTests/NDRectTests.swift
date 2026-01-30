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

final class NDRectTests: XCTestCase {

    // MARK: - Init

    func testNDRectInitByOriginSize() {
        let rect = NDRect(origin: NDPoint(x: 0, y: 0),
                          size: NDSize(width: 3.0, height: 4.0))
        XCTAssertEqual(rect.origin.x, 0.0)
        XCTAssertEqual(rect.origin.y, 0.0)
        XCTAssertEqual(rect.size.width, 3.0)
        XCTAssertEqual(rect.size.height, 4.0)
    }

    func testInitByXYAndSize() {
        let rect = NDRect(x: 1.0, y: 2.0, size: NDSize(width: 3.0, height: 4.0))
        XCTAssertEqual(rect.origin.x, 1.0)
        XCTAssertEqual(rect.origin.y, 2.0)
        XCTAssertEqual(rect.size.width, 3.0)
        XCTAssertEqual(rect.size.height, 4.0)
    }

    func testInitByXYWidthHeight() {
        let rect = NDRect(x: 1.0, y: 2.0, width: 3.0, height: 4.0)
        XCTAssertEqual(rect.origin.x, 1.0)
        XCTAssertEqual(rect.origin.y, 2.0)
        XCTAssertEqual(rect.size.width, 3.0)
        XCTAssertEqual(rect.size.height, 4.0)
    }

    func testInitFromCGRectAndCgRectRoundTrip() {
        let cg = CGRect(x: 10.0, y: 20.0, width: 30.0, height: 40.0)
        let nd = NDRect(cg)

        XCTAssertEqual(nd.origin.x, 10.0)
        XCTAssertEqual(nd.origin.y, 20.0)
        XCTAssertEqual(nd.size.width, 30.0)
        XCTAssertEqual(nd.size.height, 40.0)

        let cg2 = nd.cgRect
        XCTAssertEqual(cg2.origin.x, cg.origin.x)
        XCTAssertEqual(cg2.origin.y, cg.origin.y)
        XCTAssertEqual(cg2.size.width, cg.size.width)
        XCTAssertEqual(cg2.size.height, cg.size.height)
    }

    func testInitFromPointsEmptyAndNonEmpty() {
        // Empty list should yield .zero
        let empty = NDRect([])
        XCTAssertEqual(empty, .zero)
        XCTAssertTrue(empty.isEmpty)

        // Non-empty list should include all points
        let points: [NDPoint] = [
            NDPoint(x: 2, y: 3),
            NDPoint(x: -1, y: 10),
            NDPoint(x: 5, y: -2)
        ]
        let r = NDRect(points)

        XCTAssertTrue(r.contains(NDPoint(x: 2, y: 3)))
        XCTAssertTrue(r.contains(NDPoint(x: -1, y: 10)))
        XCTAssertTrue(r.contains(NDPoint(x: 5, y: -2)))

        XCTAssertEqual(r.minX, -1.0)
        XCTAssertEqual(r.minY, -2.0)
        XCTAssertEqual(r.maxX, 5.0)
        XCTAssertEqual(r.maxY, 10.0)
    }

    // MARK: - Constants

    func testZeroAndOneConstants() {
        XCTAssertEqual(NDRect.zero.origin, NDPoint(x: 0, y: 0))
        XCTAssertEqual(NDRect.zero.size, NDSize(width: 0, height: 0))
        XCTAssertTrue(NDRect.zero.isEmpty)

        XCTAssertEqual(NDRect.one.origin, NDPoint(x: 0, y: 0))
        XCTAssertEqual(NDRect.one.size, NDSize(width: 1, height: 1))
        XCTAssertFalse(NDRect.one.isEmpty)
    }

    // MARK: - isEmpty

    func testIsEmptyTrueWhenAnySideIsZero() {
        XCTAssertTrue(NDRect(x: 0, y: 0, width: 0, height: 10).isEmpty)
        XCTAssertTrue(NDRect(x: 0, y: 0, width: 10, height: 0).isEmpty)
        XCTAssertTrue(NDRect(x: 0, y: 0, width: 0, height: 0).isEmpty)
        XCTAssertFalse(NDRect(x: 0, y: 0, width: 1, height: 1).isEmpty)
    }

    // MARK: - contains

    func testContainsIncludesEdges() {
        let r = NDRect(x: 10, y: 20, width: 30, height: 40)

        XCTAssertTrue(r.contains(NDPoint(x: 10, y: 20))) // min corner
        XCTAssertTrue(r.contains(NDPoint(x: 40, y: 20))) // maxX edge
        XCTAssertTrue(r.contains(NDPoint(x: 40, y: 60))) // max corner
        XCTAssertTrue(r.contains(NDPoint(x: 10, y: 60))) // maxY edge

        XCTAssertFalse(r.contains(NDPoint(x: 9.999, y: 20)))
        XCTAssertFalse(r.contains(NDPoint(x: 10, y: 19.999)))
        XCTAssertFalse(r.contains(NDPoint(x: 40.001, y: 20)))
        XCTAssertFalse(r.contains(NDPoint(x: 10, y: 60.001)))
    }

    // MARK: - add(point) / add(points)

    func testAddPointExpandsRectToIncludePoint() {
        var r = NDRect(x: 0, y: 0, width: 2, height: 2)

        r.add(NDPoint(x: 5, y: 1)) // expand to the right
        XCTAssertEqual(r.minX, 0.0)
        XCTAssertEqual(r.maxX, 5.0)
        XCTAssertEqual(r.minY, 0.0)
        XCTAssertEqual(r.maxY, 2.0)

        r.add(NDPoint(x: -3, y: -4)) // expand left and down
        XCTAssertEqual(r.minX, -3.0)
        XCTAssertEqual(r.minY, -4.0)
        XCTAssertEqual(r.maxX, 5.0)
        XCTAssertEqual(r.maxY, 2.0)
    }

    func testAddPointDoesNothingIfAlreadyContained() {
        var r = NDRect(x: 0, y: 0, width: 10, height: 10)
        r.add(NDPoint(x: 5, y: 5))
        XCTAssertEqual(r.origin, NDPoint(x: 0, y: 0))
        XCTAssertEqual(r.size, NDSize(width: 10, height: 10))
    }

    func testAddPointsExpandsRectToIncludeAllPoints() {
        var r = NDRect(x: 0, y: 0, width: 1, height: 1)
        r.add([
            NDPoint(x: 10, y: 0),
            NDPoint(x: -2, y: 3),
            NDPoint(x: 4, y: -5)
        ])

        XCTAssertEqual(r.minX, -2.0)
        XCTAssertEqual(r.minY, -5.0)
        XCTAssertEqual(r.maxX, 10.0)
        XCTAssertEqual(r.maxY, 3.0)
    }

    // MARK: - insetBy / offsetBy

    func testInsetByVector() {
        let r = NDRect(x: 10, y: 20, width: 30, height: 40)
        let inset = r.insetBy(NDVector(dx: 2, dy: 3))

        XCTAssertEqual(inset.origin.x, 12.0)
        XCTAssertEqual(inset.origin.y, 23.0)
        XCTAssertEqual(inset.width, 30.0 - 4.0)
        XCTAssertEqual(inset.height, 40.0 - 6.0)
    }

    func testInsetByDxDyNegativeExpands() {
        let r = NDRect(x: 10, y: 20, width: 30, height: 40)
        let inset = r.insetBy(dx: -2, dy: -3) // negative => expands

        XCTAssertEqual(inset.origin.x, 8.0)
        XCTAssertEqual(inset.origin.y, 17.0)
        XCTAssertEqual(inset.width, 30.0 + 4.0)
        XCTAssertEqual(inset.height, 40.0 + 6.0)
    }

    func testOffsetByVectorAndDxDy() {
        let r = NDRect(x: 10, y: 20, width: 30, height: 40)

        let moved1 = r.offsetBy(NDVector(dx: 5, dy: -7))
        XCTAssertEqual(moved1.origin.x, 15.0)
        XCTAssertEqual(moved1.origin.y, 13.0)
        XCTAssertEqual(moved1.size, r.size)

        let moved2 = r.offsetBy(dx: 5, dy: -7)
        XCTAssertEqual(moved2, moved1)
    }

    // MARK: - Computed geometry

    func testWidthHeightMinMidMaxCenterSides() {
        let r = NDRect(x: 10, y: 20, width: 30, height: 40)

        XCTAssertEqual(r.width, 30.0)
        XCTAssertEqual(r.height, 40.0)

        XCTAssertEqual(r.minX, 10.0)
        XCTAssertEqual(r.minY, 20.0)
        XCTAssertEqual(r.midX, 25.0) // 10 + 30/2
        XCTAssertEqual(r.midY, 40.0) // 20 + 40/2
        XCTAssertEqual(r.maxX, 40.0) // 10 + 30
        XCTAssertEqual(r.maxY, 60.0) // 20 + 40

        XCTAssertEqual(r.center, NDPoint(x: 25.0, y: 40.0))

        XCTAssertEqual(r.shortestSide, 30.0)
        XCTAssertEqual(r.longestSide, 40.0)
    }

    func testPointsReturnsCornersInExpectedOrder() {
        let r = NDRect(x: 10, y: 20, width: 30, height: 40)
        let pts = r.points
        XCTAssertEqual(pts.count, 4)

        XCTAssertEqual(pts[0], NDPoint(x: 10, y: 20)) // minX, minY
        XCTAssertEqual(pts[1], NDPoint(x: 40, y: 20)) // maxX, minY
        XCTAssertEqual(pts[2], NDPoint(x: 40, y: 60)) // maxX, maxY
        XCTAssertEqual(pts[3], NDPoint(x: 10, y: 60)) // minX, maxY
    }

    // MARK: - roundedDescription

    func testRoundedDescriptionBasicFormat() {
        let r = NDRect(x: 1.23456, y: 7.89012, width: 3.45678, height: 9.01234)
        let s = r.roundedDescription

        // We don't assume the exact NDPoint/NDSize formatting beyond "origin size" concatenation.
        XCTAssertTrue(s.contains(" "))
        XCTAssertFalse(s.isEmpty)
    }

    // MARK: - Comparable semantics

    func testComparableMatchesImplementationAnd() {
        // Implementation:
        // lhs.origin.magnitudeSquared < rhs.origin.magnitudeSquared &&
        // lhs.size.magnitudeSquared   < rhs.size.magnitudeSquared

        let a = NDRect(x: 0, y: 0, width: 1, height: 1) // origin msq = 0, size msq = 2
        let b = NDRect(x: 3, y: 4, width: 10, height: 0) // origin msq = 25, size msq = 100

        // size msq: (10^2 + 0^2) = 100, a.size msq = (1^2 + 1^2) = 2
        XCTAssertTrue(a < b)

        // Now make a rect where only one side is "less" -> should be false due to &&
        let c = NDRect(x: 100, y: 0, width: 1, height: 1) // origin msq huge, size msq small
        XCTAssertFalse(c < b) // origin condition fails
    }

    // MARK: - Codable

    func testCodableRoundTrip() throws {
        let original = NDRect(x: 10.5, y: -2.25, width: 3.75, height: 4.125)

        let data = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(NDRect.self, from: data)

        XCTAssertEqual(decoded, original)
    }

    // MARK: - Hashable

    func testHashableSetUniqueness() {
        let a = NDRect(x: 1, y: 2, width: 3, height: 4)
        let b = NDRect(x: 1, y: 2, width: 3, height: 4)

        var set = Set<NDRect>()
        set.insert(a)
        set.insert(b)
        XCTAssertEqual(set.count, 1)
    }
}
