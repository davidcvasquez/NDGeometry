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

nonisolated public struct NDPolarPoint: Equatable {
    /// - Returns: The radius or distance to the pole (ρ) for this polar point.
    public var rho: NDFloat

    /// - Returns: The angle (θ) of this polar point.
    public var theta: NDAngle

    // ────────────────────────────────────────────────
    // MARK: - Initialization

    /// Initializer by rho and theta
    @inlinable public init(rho: NDFloat, theta: NDAngle) {
        self.rho = rho
        self.theta = theta
    }

    /// Creates a polar point from a radius and an angle in degrees (convenience).
    @inlinable public init(rho: NDFloat, degrees: NDFloat) {
        self.rho = rho
        self.theta = NDAngle(degrees: degrees)
    }

    /// Initializer by cartesian coordinates.
    @inlinable public init(x: NDFloat, y: NDFloat) {
        self.rho = hypot(x, y)
        self.theta = NDAngle(radians: atan2(y, x))
    }

    /// Initializer by an NDPoint.
    @inlinable public init(_ point: NDPoint) {
        self.init(x: point.x, y: point.y)
    }

    /// - Returns: A conversion of this polar point to a cartesian (x, y) point.
    @inlinable public var cartesian: NDPoint {
        NDPoint(
            x: rho * cos(theta.radians),
            y: rho * sin(theta.radians)
        )
    }

    /// - Returns: A cartesian X coordinate for this polar point.
    @inlinable public var x: NDFloat {
        rho * cos(theta.radians)
    }

    /// - Returns: A cartesian Y coordinate for this polar point.
    @inlinable public var y: NDFloat {
        rho * sin(theta.radians)
    }

    /// Rotate this polar point by the given angle.
    @inlinable public mutating func rotate(by delta: NDAngle) {
        theta += delta
    }

    /// Scale this polar point by the given scaling factor.
    @inlinable public mutating func scale(by factor: NDFloat) {
        rho *= factor
    }

    /// Normalize the angle (θ) of this polar point
    @inlinable public mutating func normalizeTheta() {
        theta.radians = theta.normalizedRadians
    }

    /// - Returns: This polar point rotated by the given angle.
    @inlinable public func rotated(by delta: NDAngle) -> NDPolarPoint {
        var copy = self
        copy.rotate(by: delta)
        return copy
    }

    /// - Returns: This polar point scaled by the given scaling factor.
    @inlinable public func scaled(by factor: NDFloat) -> NDPolarPoint {
        var copy = self
        copy.scale(by: factor)
        return copy
    }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
nonisolated extension NDPolarPoint: Hashable, Comparable {
    /// Returns a Boolean value indicating whether the value of the first
    /// argument is less than that of the second argument.
    ///
    /// This function is the only requirement of the `Comparable` protocol. The
    /// remainder of the relational operator functions are implemented by the
    /// standard library for any type that conforms to `Comparable`.
    ///
    /// - Parameters:
    ///   - lhs: A value to compare.
    ///   - rhs: Another value to compare.
    @inlinable
    public static func < (lhs: NDPolarPoint, rhs: NDPolarPoint) -> Bool {
        lhs.rho < rhs.rho && lhs.theta < rhs.theta
    }

    /// Returns a Boolean value indicating whether two values are equal.
    ///
    /// Equality is the inverse of inequality. For any values `a` and `b`,
    /// `a == b` implies that `a != b` is `false`.
    ///
    /// - Parameters:
    ///   - lhs: A value to compare.
    ///   - rhs: Another value to compare.
    @inlinable
    public static func == (lhs: NDPolarPoint, rhs: NDPolarPoint) -> Bool {
        lhs.rho == rhs.rho && lhs.theta == rhs.theta
    }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
nonisolated extension NDPolarPoint: Codable {

    private enum CodingKeys: String, CodingKey {
        case rho, theta
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(rho, forKey: .rho)
        try container.encode(theta, forKey: .theta)
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.rho   = try container.decode(NDFloat.self, forKey: .rho)
        self.theta = try container.decode(NDAngle.self, forKey: .theta)
    }
}
