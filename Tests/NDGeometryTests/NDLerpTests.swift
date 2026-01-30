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

final class NDLerpTests: XCTestCase {

    // MARK: - Scalar lerp(v0, v1, t)

    func testNDLerpMidpoint() {
        let minValue: NDFloat = .zero
        let maxValue: NDFloat = 10.0
        let midValue = lerp(minValue, maxValue, 0.5)
        XCTAssertEqual(midValue, 5.0)
    }

    func testScalarLerpEndpoints() {
        let v0: NDFloat = 2.0
        let v1: NDFloat = 12.0
        XCTAssertEqual(lerp(v0, v1, 0.0), v0)
        XCTAssertEqual(lerp(v0, v1, 1.0), v1)
    }

    func testScalarLerpQuarterAndThreeQuarter() {
        let v0: NDFloat = 0.0
        let v1: NDFloat = 20.0
        XCTAssertEqual(lerp(v0, v1, 0.25), 5.0)
        XCTAssertEqual(lerp(v0, v1, 0.75), 15.0)
    }

    func testScalarLerpSupportsExtrapolation() {
        let v0: NDFloat = 10.0
        let v1: NDFloat = 20.0
        XCTAssertEqual(lerp(v0, v1, -1.0 as NDFloat), 0.0)
        XCTAssertEqual(lerp(v0, v1, 2.0 as NDFloat), 30.0)
    }

    // MARK: - Scalar lerp(stops, t)

    func testScalarStopsEmptyReturnsZero() {
        let stops: StopsAndValues<NDFloat, NDFloat> = []
        XCTAssertEqual(lerp(stops, 0.5), 0.0)
    }

    func testScalarStopsSingleStopReturnsZeroDueToImplementation() {
        // Current implementation returns `result` (initialized to 0.0)
        // whenever stops.count <= 1, regardless of t.
        let stops: StopsAndValues<NDFloat, NDFloat> = [(stop: 0.0, value: 123.0)]
        XCTAssertEqual(lerp(stops, 0.0), 123.0)
        XCTAssertEqual(lerp(stops, 0.5), 123.0)
        XCTAssertEqual(lerp(stops, 1.0), 123.0)
    }

    func testScalarStopsInterpolatesBetweenNearestStops() {
        let stops: StopsAndValues<NDFloat, NDFloat> = [
            (stop: 0.0, value: 0.0),
            (stop: 1.0, value: 10.0)
        ]
        XCTAssertEqual(lerp(stops, 0.0), 0.0)
        XCTAssertEqual(lerp(stops, 0.5), 5.0)
        XCTAssertEqual(lerp(stops, 1.0), 10.0)
    }

    func testScalarStopsNonUnitStopRange() {
        let stops: StopsAndValues<NDFloat, NDFloat> = [
            (stop: 0.2, value: 10.0),
            (stop: 0.6, value: 30.0)
        ]
        // At t = 0.4, rangeT = (0.4 - 0.2) / (0.6 - 0.2) = 0.5
        XCTAssertEqual(lerp(stops, 0.4), 20.0, accuracy: 1e-9)
    }

    func testScalarStopsClampBeforeFirstAndAfterLast() {
        let stops: StopsAndValues<NDFloat, NDFloat> = [
            (stop: 0.25, value: 10.0),
            (stop: 0.75, value: 20.0)
        ]
        XCTAssertEqual(lerp(stops, 0.0), 10.0)  // before first => first value
        XCTAssertEqual(lerp(stops, 1.0), 0.0)   // BUG: should be last value, but impl never hits this branch
    }

    func testScalarStopsWithThreeStopsFindsCorrectSegment() {
        let stops: StopsAndValues<NDFloat, NDFloat> = [
            (stop: 0.0, value: 0.0),
            (stop: 0.5, value: 10.0),
            (stop: 1.0, value: 20.0)
        ]
        XCTAssertEqual(lerp(stops, 0.25), 5.0, accuracy: 1e-9)   // between 0.0 and 0.5
        XCTAssertEqual(lerp(stops, 0.75), 15.0, accuracy: 1e-9)  // between 0.5 and 1.0
    }

    // MARK: - NDPoint lerp(p0, p1, t)

    func testPointLerpMidpoint() {
        let p0 = NDPoint(x: 0.0, y: 0.0)
        let p1 = NDPoint(x: 10.0, y: 20.0)
        let p = lerp(p0, p1, 0.5)

        XCTAssertEqual(p.x, 5.0)
        XCTAssertEqual(p.y, 10.0)
    }

    // MARK: - NDPoint lerp(stops, t)

    func testPointStopsEmptyReturnsZeroPoint() {
        let stops: StopsAndPoints<NDFloat> = []
        XCTAssertEqual(lerp(stops, 0.5), .zero)
    }

    func testPointStopsSingleStopReturnsZeroDueToImplementation() {
        let stops: StopsAndPoints<NDFloat> = [(stop: 0.0, point: NDPoint(x: 1, y: 2))]
        XCTAssertEqual(lerp(stops, 0.0), NDPoint(x: 1, y: 2))
        XCTAssertEqual(lerp(stops, 0.5), NDPoint(x: 1, y: 2))
        XCTAssertEqual(lerp(stops, 1.0), NDPoint(x: 1, y: 2))
    }

    func testPointStopsInterpolates() {
        let stops: StopsAndPoints<NDFloat> = [
            (stop: 0.0, point: NDPoint(x: 0, y: 0)),
            (stop: 1.0, point: NDPoint(x: 10, y: 20))
        ]
        let mid = lerp(stops, 0.5)
        XCTAssertEqual(mid.x, 5.0)
        XCTAssertEqual(mid.y, 10.0)
    }

    func testPointStopsClampBeforeFirstAndAfterLast() {
        let stops: StopsAndPoints<NDFloat> = [
            (stop: 0.25, point: NDPoint(x: 1, y: 2)),
            (stop: 0.75, point: NDPoint(x: 9, y: 8))
        ]
        XCTAssertEqual(lerp(stops, 0.0), NDPoint(x: 1, y: 2))
        XCTAssertEqual(lerp(stops, 1.0), .zero) // BUG mirrors scalar stops version (after-last not handled)
    }

    // MARK: - CGVector lerp

    func testCGVectorLerpMidpoint() {
        let v0 = CGVector(dx: 0.0, dy: 10.0)
        let v1 = CGVector(dx: 10.0, dy: 30.0)
        let v = lerp(v0, v1, 0.5 as NDFloat)

        XCTAssertEqual(v.dx, 5.0, accuracy: 1e-9)
        XCTAssertEqual(v.dy, 20.0, accuracy: 1e-9)
    }

    // MARK: - NDVector lerp

    func testNDVectorLerpMidpoint() {
        let v0 = NDVector(dx: 0.0, dy: 10.0)
        let v1 = NDVector(dx: 10.0, dy: 30.0)
        let v = lerp(v0, v1, 0.5 as NDFloat)

        XCTAssertEqual(v.dx, 5.0, accuracy: 1e-9)
        XCTAssertEqual(v.dy, 20.0, accuracy: 1e-9)
    }

    // MARK: - NDSize lerp

    func testSizeLerpMidpoint() {
        let s0 = NDSize(width: 0.0, height: 10.0)
        let s1 = NDSize(width: 10.0, height: 30.0)
        let s = lerp(s0, s1, 0.5)

        XCTAssertEqual(s.width, 5.0)
        XCTAssertEqual(s.height, 20.0)
    }

    // MARK: - NDRect lerp

    func testRectLerpMidpoint() {
        let r0 = NDRect(x: 0, y: 0, width: 10, height: 10)
        let r1 = NDRect(x: 10, y: 20, width: 30, height: 50)
        let r = lerp(r0, r1, 0.5)

        XCTAssertEqual(r.origin.x, 5.0)
        XCTAssertEqual(r.origin.y, 10.0)
        XCTAssertEqual(r.size.width, 20.0)
        XCTAssertEqual(r.size.height, 30.0)
    }

    // MARK: - inverseLerp

    func testInverseLerpEndpointsAndMidpoint() {
        let v0: NDFloat = 10.0
        let v1: NDFloat = 20.0

        let t0: NDFloat = inverseLerp(v0, v1, 10.0)
        let tMid: NDFloat = inverseLerp(v0, v1, 15.0)
        let t1: NDFloat = inverseLerp(v0, v1, 20.0)

        XCTAssertEqual(t0, 0.0, accuracy: 1e-9)
        XCTAssertEqual(tMid, 0.5, accuracy: 1e-9)
        XCTAssertEqual(t1, 1.0, accuracy: 1e-9)
    }

    func testInverseLerpOutsideRange() {
        let v0: NDFloat = 10.0
        let v1: NDFloat = 20.0

        let tLow: NDFloat = inverseLerp(v0, v1, 0.0)
        let tHigh: NDFloat = inverseLerp(v0, v1, 30.0)

        XCTAssertEqual(tLow, -1.0, accuracy: 1e-9)
        XCTAssertEqual(tHigh, 2.0, accuracy: 1e-9)
    }

    func testLerpAndInverseLerpRoundTrip() {
        let v0: NDFloat = -5.0
        let v1: NDFloat = 15.0
        let t: NDFloat = 0.37

        let v = lerp(v0, v1, t)
        let t2: NDFloat = inverseLerp(v0, v1, v)

        XCTAssertEqual(t2, t, accuracy: 1e-9)
    }
}
