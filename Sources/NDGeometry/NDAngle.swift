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

/// A geometric angle whose value you access in either radians or degrees.
@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
@frozen nonisolated public struct NDAngle {
    /// - Returns: This angle in radians.
    public var radians: NDFloat

    /// - Returns: This angle in degrees.
    @inlinable public var degrees: NDFloat {
        get {
            radians * (180.0 / .pi)
        }
        set {
            radians = newValue * (.pi / 180.0)
        }
    }

    /// - Returns: If this angle has a value of zero.
    @inlinable var isZero: Bool {
        self.radians.isZero
    }

    /// - Returns: If this angle does not have a value of zero.
    @inlinable var isNonZero: Bool {
        !self.radians.isZero
    }

    /// - Returns: The normalized angle in the range [0, 2π) radians.
    @inlinable public var normalized: NDFloat {
        normalizedRadians
    }

    /// - Returns: The normalized angle in the range [0, 2π) radians.
    @inlinable public var normalizedRadians: NDFloat {
        (radians.truncatingRemainder(dividingBy: 2 * .pi) + 2 * .pi)
            .truncatingRemainder(dividingBy: 2 * .pi)
    }

    /// - Returns: The normalized angle in the range [0, 360) degrees.
    @inlinable public var normalizedDegrees: NDFloat {
        normalizedRadians * (180 / .pi)
    }

    /// Make this angle normalized, in the range [0, 2π) radians
    @inlinable public mutating func normalize() {
        radians = normalizedRadians
    }

    /// Default initializer to an angle of zero.
    @inlinable public init() {
        self.radians = 0.0
    }

    /// Initializer by radians.
    @inlinable public init(radians: NDFloat) {
        self.radians = radians
    }

    /// Initializer by degrees.
    @inlinable public init(degrees: NDFloat) {
        self.radians = degrees * (.pi / 180.0)
    }

    /// - Returns: Compact dot notation factory for an NDAngle initialized with the given radians.
    @inlinable public static func radians(_ radians: NDFloat) -> NDAngle {
        NDAngle(radians: radians)
    }

    /// - Returns: Compact dot notation factory for an NDAngle initialzied with the given degrees.
    @inlinable public static func degrees(_ degrees: NDFloat) -> NDAngle {
        NDAngle(degrees: degrees)
    }

    /// Unary (prefix) negation operator.
    @inlinable
    static prefix func - (a: NDAngle) -> NDAngle {
        .radians(-a.radians)
    }

    /// Subtraction operator for two angles.
    @inlinable
    public static func -(lhs: NDAngle, rhs: NDAngle) -> NDAngle {
        .radians(lhs.radians - rhs.radians)
    }

    /// Addition operator for two angles.
    @inlinable
    public static func +(lhs: NDAngle, rhs: NDAngle) -> NDAngle {
        .radians(lhs.radians + rhs.radians)
    }

    /// Addition += operator for two angles.
    @inlinable
    public static func += (left: inout NDAngle, right: NDAngle) {
        left = left + right
    }

    /// Subtraction -= operator for two angles.
    @inlinable
    public static func -= (left: inout NDAngle, right: NDAngle) {
        left = left - right
    }

    /// Multiplication operator for an angle and a float
    @inlinable
    public static func *(lhs: NDAngle, rhs: NDFloat) -> NDAngle {
        .radians(lhs.radians * rhs)
    }

    /// Division operator for an angle and a float
    @inlinable
    public static func /(lhs: NDAngle, rhs: NDFloat) -> NDAngle {
        .radians(lhs.radians / rhs)
    }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
nonisolated extension NDAngle: Hashable, Comparable {

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
    public static func < (lhs: NDAngle, rhs: NDAngle) -> Bool {
        lhs.radians < rhs.radians
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
    public static func == (lhs: NDAngle, rhs: NDAngle) -> Bool {
        lhs.radians == rhs.radians
    }
    
    /// Hashes the essential components of this value by feeding them into the
    /// given hasher.
    ///
    /// Implement this method to conform to the `Hashable` protocol. The
    /// components used for hashing must be the same as the components compared
    /// in your type's `==` operator implementation. Call `hasher.combine(_:)`
    /// with each of these components.
    ///
    /// - Important: In your implementation of `hash(into:)`,
    ///   don't call `finalize()` on the `hasher` instance provided,
    ///   or replace it with a different instance.
    ///   Doing so may become a compile-time error in the future.
    ///
    /// - Parameter hasher: The hasher to use when combining the components
    ///   of this instance.
    @inlinable
    public func hash(into hasher: inout Hasher) {
        hasher.combine(radians)
    }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
nonisolated extension NDAngle: Codable {

    public enum CodingKeys: String, CodingKey {
        case radians
        // We could add "degrees" as an alternative key.
    }

    /// Encodes this angle into the given encoder.
    ///
    /// Encodes only the `radians` value as the canonical representation.
    public func encode(to encoder: any Encoder) throws {
         var container = encoder.container(keyedBy: CodingKeys.self)
         try container.encode(radians, forKey: .radians)
    }

    /// Creates a new angle by decoding from the given decoder.
    ///
    /// Expects a single floating-point value representing radians.
    /// (If your JSON/Plist uses a keyed container with a "radians" key, switch to the keyed decoding style below.)
    public init(from decoder: any Decoder) throws {
         let container = try decoder.container(keyedBy: CodingKeys.self)
         self.radians = try container.decode(NDFloat.self, forKey: .radians)
    }
}
