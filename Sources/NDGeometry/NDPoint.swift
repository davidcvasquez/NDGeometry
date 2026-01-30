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
import CoreGraphics

/// A nonisolated version of CGPoint, with additional conveniences for various constants and other common calculations.
@frozen
nonisolated public struct NDPoint: Equatable, Hashable, Codable {
    public var x: NDFloat
    public var y: NDFloat

    /// - Returns: This point converted to a CGPoint.
    @inlinable
    public var cgPoint: CGPoint {
        CGPoint(x: x, y: y)
    }

    /// Initializer from x and y coordinates.
    @inlinable
    public init(x: NDFloat, y: NDFloat) {
        self.x = x
        self.y = y
    }

    /// Initializer from a CGPoint.
    @inlinable
    public init(_ p: CGPoint) {
        self.init(x: p.x, y: p.y)
    }

    public static let zero = NDPoint(x: 0.0, y: 0.0)
    public static let one = NDPoint(x: 1.0, y: 1.0)

    public static let normalizedCenter = NDPoint(x: 0.5, y: 0.5)

    /// Initializer from rho and theta.
    /// - parameter ρ: Distance from the pole (rho).
    /// - parameter θ: Angular coordinate in the reference direction (theta).
    @inlinable
    public init(ρ: NDFloat, θ: NDFloat) {
        self.init(x: cos(θ) * (ρ), y: sin(θ) * -(ρ))
    }

    @inlinable
    public init(_ vector: NDVector) {
        self.init(x: vector.dx, y: vector.dy)
    }

    /// - Returns: A concise debug description of this point, rounded to two decimal places.
    public var roundedDescription: String {
        "(x: \(self.x.rounded(.hundredths)), y: \(self.y.rounded(.hundredths)))"
    }

    /// Unit vector û = u / |u| where |u| > 0
    @inlinable
    public var normalized: NDPoint {
        let _magnitude = magnitude
        return _magnitude > 0 ? self / _magnitude : NDPoint.zero
    }

    /// Distance from the pole (ρ).
    @inlinable
    public var rho: NDFloat {
        self.magnitude
    }

    /// Angular coordinate in the reference direction (θ); the unit arc length.
    @inlinable
    public var theta: Radians {
        atan2(self.y, self.x)
    }

    /// - Returns: The angle formed by this point as unsigned radians in the range 0...2π
    @inlinable
    public var uθ: Radians {
        var angle = atan2(y, x)
        if angle < 0 {
            angle += 2 * NDFloat.pi
        }
        return angle
    }

    /// - Returns: The length of the hypotenuse of a right-angled triangle with sides x and y.
    @inlinable
    public var magnitude: NDFloat {
        hypot(self.x, self.y)
    }

    /// - Returns: The magnitude squared (skips the square root).
    @inlinable
    public var magnitudeSquared: NDFloat {
        self.x * self.x + self.y * self.y
    }

    /// Unary (prefix) negation operator.
    @inlinable
    public static prefix func - (p: NDPoint) -> NDPoint {
        NDPoint(x: -p.x, y: -p.y)
    }

    /// Subtraction operator for two points.
    @inlinable
    public static func -(lhs: NDPoint, rhs: NDPoint) -> NDPoint {
        NDPoint(x: lhs.x - rhs.x, y: lhs.y - rhs.y)
    }

    /// Addition operator for two points.
    @inlinable
    public static func +(lhs: NDPoint, rhs: NDPoint) -> NDPoint {
        NDPoint(x: lhs.x + rhs.x, y: lhs.y + rhs.y)
    }

    /// Addition operator for a point and a vector.
    @inlinable
    public static func +(lhs: NDPoint, rhs: NDVector) -> NDPoint {
        NDPoint(x: lhs.x + rhs.dx, y: lhs.y + rhs.dy)
    }

    /// Subtraction operator for a point and a vector.
    @inlinable
    public static func -(lhs: NDPoint, rhs: NDVector) -> NDPoint {
        NDPoint(x: lhs.x - rhs.dx, y: lhs.y - rhs.dy)
    }

    /// Addition operator for a point and a size.
    @inlinable
    public static func +(lhs: NDPoint, rhs: NDSize) -> NDPoint {
        NDPoint(x: lhs.x + rhs.width, y: lhs.y + rhs.height)
    }

    /// Subtraction operator for a point and a size.
    @inlinable
    public static func -(lhs: NDPoint, rhs: NDSize) -> NDPoint {
        NDPoint(x: lhs.x - rhs.width, y: lhs.y - rhs.height)
    }

    /// Multiplication operator for a point and a size.
    @inlinable
    public static func *(lhs: NDPoint, rhs: NDSize) -> NDPoint {
        NDPoint(x: lhs.x * rhs.width, y: lhs.y * rhs.height)
    }

    /// Multiplication operator for a point and a float.
    @inlinable
    public static func *(lhs: NDPoint, rhs: NDFloat) -> NDPoint {
        NDPoint(x: lhs.x * rhs, y: lhs.y * rhs)
    }

    /// Multiplication operator for a float and a point.
    @inlinable
    public static func *(lhs: NDFloat, rhs: NDPoint) -> NDPoint {
        NDPoint(x: lhs * rhs.x, y: lhs * rhs.y)
    }

    /// Division operator for NDPoint ÷ NDFloat
    @inlinable
    public static func / (lhs: NDPoint, rhs: NDFloat) -> NDPoint {
        NDPoint(x: lhs.x / rhs, y: lhs.y / rhs)
    }

    /// Scalar Projection of this point onto the line segment formed by A and B,
    /// clipped to the range 0...1.
    ///
    ///   (AC ⋅ AB) / (||AB|| ** 2)
    ///
    ///  - Note: This projection uses the shortest perpendicular distance.
    ///  To find the closest angular projection, map the magnitude of AC onto AB.
    public func scalarProjection(a: NDPoint, b: NDPoint) -> NDFloat {

        let projection = ((NDVector(self - a) • NDVector(b - a))) /
                         NDVector(b - a).magnitudeSquared

        return min(max(projection, 0), 1.0)
    }

    /// - Returns: A rectangle surrounding this point with the given radius.
    public func toRect(radius: NDFloat) -> NDRect {
        let diameter = radius * 2.0
        return NDRect(x: self.x - radius,
                      y: self.y - radius,
                      width: diameter, height: diameter)
    }

    /// - Returns: A point projected beyond the line segment from this point to the given endpoint by the given length.
    public func projectPointBeyond(endPoint: NDPoint, by length: NDFloat) -> NDPoint {
        let vector: NDVector = NDVector(endPoint - self).normalized * length
        return endPoint + vector
    }

    /// - Returns: Positive and negative normals points projected on either side of the endpoint that forms a line segment with this point.
    public func projectNormalPoints(
        endPoint: NDPoint,
        by length: NDFloat
    ) -> (pos: NDPoint, neg: NDPoint) {
        let cotangent = endPoint - self
        let normalizedTangent = cotangent.normalized

        let normalPos = NDPoint(x: -normalizedTangent.y, y: normalizedTangent.x)
        let normalNeg = NDPoint(x: normalizedTangent.y, y: -normalizedTangent.x)

        let toPointPos = NDPoint(x: endPoint.x + normalPos.x * length,
                                 y: endPoint.y + normalPos.y * length)
        let toPointNeg = NDPoint(x: endPoint.x + normalNeg.x * length,
                                 y: endPoint.y + normalNeg.y * length)

        return (pos: toPointPos, neg: toPointNeg)
    }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
extension NDPoint : Sendable {
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
extension NDPoint : BitwiseCopyable {
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
extension NDPoint : Comparable {
    public static func < (lhs: NDPoint, rhs: NDPoint) -> Bool {
        lhs.magnitudeSquared < rhs.magnitudeSquared
    }
}
