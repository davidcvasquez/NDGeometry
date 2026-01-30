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

/// A nonisolated version of CGVector, with additional conveniences for various constants and other common calculations.
@frozen
nonisolated public struct NDVector: Equatable, Hashable, Codable {
    public var dx: NDFloat
    public var dy: NDFloat

    /// - Returns: This vector converted to a CGVector.
    @inlinable
    public var cgVector: CGVector {
        CGVector(dx: dx, dy: dy)
    }

    /// Initializer from delta X and Y values.
    @inlinable
    public init(dx: NDFloat, dy: NDFloat) {
        self.dx = dx
        self.dy = dy
    }

    /// Initializer from a CGVector.
    @inlinable
    public init(_ v: CGVector) {
        self.init(dx: v.dx, dy: v.dy)
    }

    /// Initializer from a CGPoint.
    @inlinable
    public init(_ p: CGPoint) {
        self.init(dx: p.x, dy: p.y)
    }

    /// Initializer from a point.
    @inlinable
    public init(_ point: NDPoint) {
        self.init(dx: point.x, dy: point.y)
    }

    /// Initializer from a size.
    @inlinable
    public init(_ size: NDSize) {
        self.init(dx: size.width, dy: size.height)
    }

    /// Initializer from rho and theta.
    /// - parameter ρ: Distance from the pole (rho).
    /// - parameter θ: Angular coordinate in the reference direction (theta).
    @inlinable
    public init(ρ: NDFloat, θ: NDFloat) {
        self.init(dx: cos(θ) * (ρ), dy: sin(θ) * -(ρ))
    }

    /// Addition operator for NDVector + NDFloat
    @inlinable
    public static func +(lhs: NDVector, rhs: NDFloat) -> NDVector {
        NDVector(
            dx: lhs.dx + rhs,
            dy: lhs.dy + rhs
        )
    }

    /// Addition operator for NDVector + NDVector
    @inlinable
    public static func +(lhs: NDVector, rhs: NDVector) -> NDVector {
        NDVector(
            dx: lhs.dx + rhs.dx,
            dy: lhs.dy + rhs.dy
        )
    }

    /// Subtraction operator for NDVector – NDVector
    @inlinable
    public static func -(lhs: NDVector, rhs: NDVector) -> NDVector {
        NDVector(
            dx: lhs.dx - rhs.dx,
            dy: lhs.dy - rhs.dy
        )
    }

    /// Multiplication operator for NDVector ✖️ NDFloat
    @inlinable
    public static func *(lhs: NDVector, rhs: NDFloat) -> NDVector {
        NDVector(
            dx: lhs.dx * rhs,
            dy: lhs.dy * rhs
        )
    }

    /// Division operator for NDVector ÷ NDFloat
    @inlinable
    public static func / (lhs: NDVector, rhs: NDFloat) -> NDVector {
        NDVector(
            dx: lhs.dx / rhs,
            dy: lhs.dy / rhs)
    }

    /// Multiplication operator for NDVector ✖️ NDSize
    @inlinable
    public static func * (lhs: NDVector, rhs: NDSize) -> NDVector {
        NDVector(
            dx: lhs.dx * rhs.width,
            dy: lhs.dy * rhs.height
        )
    }

    /// Dot product operator for NDVector • NDVector
    @inlinable
    public static func • (lhs: NDVector, rhs: NDVector) -> NDFloat {
        lhs.dx * rhs.dx + lhs.dy * rhs.dy
    }

    /// Comparison operator for two vectors.
    @inlinable
    public static func < (lhs: NDVector, rhs: NDVector) -> Bool {
        lhs.magnitudeSquared < rhs.magnitudeSquared
    }

    /// - Returns: The length of the hypotenuse of a right-angled triangle with sides dx and dy.
    @inlinable
    public var magnitude: NDFloat {
        hypot(self.dx, self.dy)
    }

    /// - Returns: The magnitude squared (skips the square root).
    @inlinable
    public var magnitudeSquared: NDFloat {
        dx * dx + dy * dy
    }

    /// A zero-length vector.
    public static var zero = NDVector(dx: 0.0, dy: 0.0)

    /// A unit vector.
    public static var one = NDVector(dx: 1.0, dy: 1.0)

    /// A concise debug description of this vector, rounded to two decimal places.
    public var roundedDescription: String {
        "(dx: \(self.dx.rounded(.hundredths)), dy: \(self.dy.rounded(.hundredths)))"
    }

    /// Distance from the pole (rho).
    public var ρ: NDFloat {
        self.magnitude
    }

    /// Angular coordinate in the reference direction (theta).
    /// aka the unit arc length.
    public var θ: Radians {
        atan2(dy, dx)
    }

    /// Diameter of the circle on which this vector sits.
    public var diameter: NDFloat {
        self.magnitude * 2
    }

    /// Arc length formed by this vector in the reference direction.
    public var s: Radians {
        θ * ρ
    }

    /// Unit tangent pointing in the CW direction.
    public var tan: NDVector {
        NDVector(dx: -dy, dy: dx).normalized
    }

    /// Unit cotangent pointing in the CCW direction
    public var cotan: NDVector {
        NDVector(dx: dy, dy: -dx).normalized
    }

    /// Unit vector û = u / |u| where |u| > 0
    @inlinable
    public var normalized: NDVector {
        let _magnitude = magnitude
        return _magnitude > 0 ? self / _magnitude : NDVector.zero
    }

    @inlinable
    public mutating func normalize() {
        self = self.normalized
    }

    /// Map from cartesian space to polar space and then convert back to cartesian.
    public var cartesianToPolar: NDVector {
        NDVector(ρ: self.dx, θ: -self.dy * 2)
    }

    /// Cartesian distance.
    public func distance(to another: NDVector) -> NDFloat {
        (self - another).magnitude
    }

    /// - Returns: Angular distance to another vector.
    /// θ = cos-1(a • b / |a||b|)
    public func θ(_ another: NDVector) -> Radians {
        let lengthProduct = self.magnitude * another.magnitude

        // If either vector has zero magnitude, then the angle is undefined.
        guard lengthProduct != 0 else {
            return NDFloat.zero
        }

        let ns = (self • another) / lengthProduct

        // Safely compute inverse cosine
        let radians = acos(ns.clamped(to: -1.0...1.0))

        // Determine the direction to make the result signed.
        return self.dx * another.dy - self.dy * another.dx < 0 ? -radians : radians
    }

    /// - Returns: The nearest angle to another vector, instead of wrapping around the long way.
    public func nearbyθ(_ another: NDVector, hint: NDFloat) -> Radians {
        let _θ = self.θ(another)
        let α: NDFloat = hint.truncatingRemainder(dividingBy: NDFloat.τ)

        if _θ < α - .π {
            return hint - α + _θ + NDFloat.τ
        } else if _θ > α + .π {
            return hint - α + _θ - NDFloat.τ
        }
        return hint - α + _θ
    }
}

/// Dot product operator.
infix operator • : MultiplicationPrecedence

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
extension NDVector : Sendable {
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
extension NDVector : BitwiseCopyable {
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
extension NDVector : Comparable {
}
