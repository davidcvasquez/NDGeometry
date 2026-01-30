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

final class NDPointTests: XCTestCase {

    // MARK: - Init / constants / bridging

    func testNDPointInitByXY() {
        let point = NDPoint(x: 3.0, y: 4.0)
        XCTAssertEqual(point.x, 3.0)
        XCTAssertEqual(point.y, 4.0)
    }

    func testInitFromCGPointAndCgPointRoundTrip() {
        let cg = CGPoint(x: 1.25, y: -2.5)
        let p = NDPoint(cg)
        XCTAssertEqual(p.x, 1.25)
        XCTAssertEqual(p.y, -2.5)

        let cg2 = p.cgPoint
        XCTAssertEqual(cg2.x, cg.x)
        XCTAssertEqual(cg2.y, cg.y)
    }

    func testConstantsZeroOneNormalizedCenter() {
        XCTAssertEqual(NDPoint.zero, NDPoint(x: 0.0, y: 0.0))
        XCTAssertEqual(NDPoint.one, NDPoint(x: 1.0, y: 1.0))
        XCTAssertEqual(NDPoint.normalizedCenter, NDPoint(x: 0.5, y: 0.5))
    }

    func testInitFromVector() {
        let v = NDVector(dx: 3.0, dy: 4.0)
        let p = NDPoint(v)
        XCTAssertEqual(p.x, 3.0)
        XCTAssertEqual(p.y, 4.0)
    }

    func testInitByRhoThetaUsesInvertedY() {
        // y = sin(θ) * -(ρ)
        let p = NDPoint(ρ: 10.0, θ: .pi / 2) // sin(pi/2)=1 -> y=-10, cos(pi/2)=0 -> x=0
        XCTAssertEqual(p.x, 0.0, accuracy: 1e-9)
        XCTAssertEqual(p.y, -10.0, accuracy: 1e-9)
    }

    // MARK: - Descriptions

    func testRoundedDescriptionFormatsAndRounds() {
        let p = NDPoint(x: 1.23456, y: 7.89123)
        let desc = p.roundedDescription

        XCTAssertTrue(desc.contains("x: 1.23"))
        XCTAssertTrue(desc.contains("y: 7.89"))
        XCTAssertTrue(desc.hasPrefix("("))
        XCTAssertTrue(desc.hasSuffix(")"))
    }

    // MARK: - Magnitude, rho, theta, uθ, normalized

    func testMagnitudeAndMagnitudeSquared() {
        let p = NDPoint(x: 3.0, y: 4.0)
        XCTAssertEqual(p.magnitude, 5.0, accuracy: 1e-9)
        XCTAssertEqual(p.magnitudeSquared, 25.0)
    }

    func testRhoEqualsMagnitude() {
        let p = NDPoint(x: 3.0, y: 4.0)
        XCTAssertEqual(p.rho, p.magnitude, accuracy: 1e-9)
    }

    func testThetaAndUnsignedTheta() {
        // Quadrant I: theta == uθ
        let p1 = NDPoint(x: 1.0, y: 1.0)
        XCTAssertEqual(p1.theta, .pi / 4, accuracy: 1e-9)
        XCTAssertEqual(p1.uθ, .pi / 4, accuracy: 1e-9)

        // Quadrant IV: theta negative, uθ in [0, 2π)
        let p2 = NDPoint(x: 1.0, y: -1.0)
        XCTAssertEqual(p2.theta, -(.pi / 4), accuracy: 1e-9)
        XCTAssertEqual(p2.uθ, 2 * .pi - (.pi / 4), accuracy: 1e-9)
    }

    func testNormalizedUnitLengthAndZeroBehavior() {
        let p = NDPoint(x: 3.0, y: 4.0)
        let u = p.normalized
        XCTAssertEqual(u.magnitude, 1.0, accuracy: 1e-9)
        XCTAssertEqual(u.x, 0.6, accuracy: 1e-9)
        XCTAssertEqual(u.y, 0.8, accuracy: 1e-9)

        let z = NDPoint.zero.normalized
        XCTAssertEqual(z, .zero)
    }

    // MARK: - Operators: point/point

    func testUnaryNegation() {
        let p = NDPoint(x: 3.0, y: -4.0)
        let n = -p
        XCTAssertEqual(n.x, -3.0)
        XCTAssertEqual(n.y, 4.0)
    }

    func testAdditionAndSubtractionPointPoint() {
        let a = NDPoint(x: 1.0, y: 2.0)
        let b = NDPoint(x: 3.0, y: 4.0)

        let sum = a + b
        XCTAssertEqual(sum.x, 4.0)
        XCTAssertEqual(sum.y, 6.0)

        let diff = b - a
        XCTAssertEqual(diff.x, 2.0)
        XCTAssertEqual(diff.y, 2.0)
    }

    // MARK: - Operators: point/vector

    func testAdditionAndSubtractionPointVector() {
        let p = NDPoint(x: 10.0, y: 20.0)
        let v = NDVector(dx: 3.0, dy: -4.0)

        let p2 = p + v
        XCTAssertEqual(p2.x, 13.0)
        XCTAssertEqual(p2.y, 16.0)

        let p3 = p - v
        XCTAssertEqual(p3.x, 7.0)
        XCTAssertEqual(p3.y, 24.0)
    }

    // MARK: - Operators: point/size

    func testAdditionSubtractionAndMultiplicationPointSize() {
        let p = NDPoint(x: 2.0, y: 3.0)
        let s = NDSize(width: 10.0, height: 20.0)

        let plus = p + s
        XCTAssertEqual(plus.x, 12.0)
        XCTAssertEqual(plus.y, 23.0)

        let minus = p - s
        XCTAssertEqual(minus.x, -8.0)
        XCTAssertEqual(minus.y, -17.0)

        let times = p * s
        XCTAssertEqual(times.x, 20.0)
        XCTAssertEqual(times.y, 60.0)
    }

    // MARK: - Operators: scalar mul/div

    func testMultiplyByScalarBothSidesAndDivide() {
        let p = NDPoint(x: 3.0, y: 4.0)

        let a = p * 2.0
        XCTAssertEqual(a.x, 6.0)
        XCTAssertEqual(a.y, 8.0)

        let b = 2.0 * p
        XCTAssertEqual(b.x, 6.0)
        XCTAssertEqual(b.y, 8.0)

        let c = p / 2.0
        XCTAssertEqual(c.x, 1.5, accuracy: 1e-9)
        XCTAssertEqual(c.y, 2.0, accuracy: 1e-9)
    }

    // MARK: - scalarProjection(a:b:)

    func testScalarProjectionClampsToZeroAndOne() {
        // Segment A(0,0) -> B(10,0)
        let a = NDPoint(x: 0, y: 0)
        let b = NDPoint(x: 10, y: 0)

        // Point beyond B projects > 1, should clamp to 1
        let pHigh = NDPoint(x: 20, y: 0)
        XCTAssertEqual(pHigh.scalarProjection(a: a, b: b), 1.0, accuracy: 1e-9)

        // Point before A projects < 0, should clamp to 0
        let pLow = NDPoint(x: -5, y: 0)
        XCTAssertEqual(pLow.scalarProjection(a: a, b: b), 0.0, accuracy: 1e-9)
    }

    func testScalarProjectionMidpointPerpendicularDoesNotMatter() {
        // Segment A(0,0) -> B(10,0)
        let a = NDPoint(x: 0, y: 0)
        let b = NDPoint(x: 10, y: 0)

        // Point above the midpoint still projects to 0.5
        let p = NDPoint(x: 5, y: 7)
        XCTAssertEqual(p.scalarProjection(a: a, b: b), 0.5, accuracy: 1e-9)
    }

    // MARK: - toRect(radius:)

    func testToRectRadius() {
        let p = NDPoint(x: 10.0, y: 20.0)
        let r = p.toRect(radius: 2.5)

        XCTAssertEqual(r.origin.x, 7.5, accuracy: 1e-9)
        XCTAssertEqual(r.origin.y, 17.5, accuracy: 1e-9)
        XCTAssertEqual(r.size.width, 5.0, accuracy: 1e-9)
        XCTAssertEqual(r.size.height, 5.0, accuracy: 1e-9)

        XCTAssertEqual(r.center, p)
    }

    // MARK: - projectPointBeyond(endPoint:by:)

    func testProjectPointBeyondExtendsPastEndPoint() {
        let start = NDPoint(x: 0, y: 0)
        let end = NDPoint(x: 10, y: 0)

        let projected = start.projectPointBeyond(endPoint: end, by: 5.0)
        XCTAssertEqual(projected.x, 15.0, accuracy: 1e-9)
        XCTAssertEqual(projected.y, 0.0, accuracy: 1e-9)
    }

    // MARK: - projectNormalPoints(endPoint:by:)

    func testProjectNormalPointsHorizontalSegment() {
        let start = NDPoint(x: 0, y: 0)
        let end = NDPoint(x: 10, y: 0)

        let normals = start.projectNormalPoints(endPoint: end, by: 2.0)

        // For tangent (1,0): normalPos = (0,1) and normalNeg = (0,-1)
        XCTAssertEqual(normals.pos.x, 10.0, accuracy: 1e-9)
        XCTAssertEqual(normals.pos.y, 2.0, accuracy: 1e-9)

        XCTAssertEqual(normals.neg.x, 10.0, accuracy: 1e-9)
        XCTAssertEqual(normals.neg.y, -2.0, accuracy: 1e-9)
    }

    func testProjectNormalPointsVerticalSegment() {
        let start = NDPoint(x: 0, y: 0)
        let end = NDPoint(x: 0, y: 10)

        let normals = start.projectNormalPoints(endPoint: end, by: 3.0)

        // For tangent (0,1): normalPos = (-1,0) and normalNeg = (1,0)
        XCTAssertEqual(normals.pos.x, -3.0, accuracy: 1e-9)
        XCTAssertEqual(normals.pos.y, 10.0, accuracy: 1e-9)

        XCTAssertEqual(normals.neg.x, 3.0, accuracy: 1e-9)
        XCTAssertEqual(normals.neg.y, 10.0, accuracy: 1e-9)
    }

    // MARK: - Comparable

    func testComparableUsesMagnitudeSquared() {
        let a = NDPoint(x: 3.0, y: 4.0)    // msq = 25
        let b = NDPoint(x: 6.0, y: 8.0)    // msq = 100
        XCTAssertTrue(a < b)
        XCTAssertFalse(b < a)
        XCTAssertTrue(a <= b)
        XCTAssertTrue(b >= a)
    }

    // MARK: - Hashable

    func testHashableSetUniqueness() {
        let a = NDPoint(x: 1, y: 2)
        let b = NDPoint(x: 1, y: 2)

        var set = Set<NDPoint>()
        set.insert(a)
        set.insert(b)
        XCTAssertEqual(set.count, 1)
    }

    // MARK: - Codable

    func testCodableRoundTrip() throws {
        let original = NDPoint(x: 10.5, y: -2.25)
        let data = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(NDPoint.self, from: data)
        XCTAssertEqual(decoded, original)
    }
}
