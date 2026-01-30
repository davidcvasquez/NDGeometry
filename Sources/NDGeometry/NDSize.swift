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

/// A nonisolated version of CGSize, with additional conveniences for various constants and other common calculations.
@frozen
nonisolated public struct NDSize: Equatable, Hashable, Codable {
    public var width: NDFloat
    public var height: NDFloat

    /// - Returns: This size converted to a CGSize.
    @inlinable
    public var cgSize: CGSize {
        CGSize(width: width, height: height)
    }

    /// Initializer from a width and a height.
    @inlinable
    public init(width: NDFloat, height: NDFloat) {
        self.width = width
        self.height = height
    }

    /// Initializer from an integer width and height.
    @inlinable
    public init(width: Int, height: Int) {
        self.width = NDFloat(width)
        self.height = NDFloat(height)
    }

    /// Initializer from a vector.
    @inlinable
    public init(_ v: CGVector) {
        self.init(width: v.dx, height: v.dy)
    }

    /// Initializer from a CGPoint.
    @inlinable
    public init(_ p: CGPoint) {
        self.init(width: p.x, height: p.y)
    }

    /// Initializer from a CGSize.
    @inlinable
    public init(_ s: CGSize) {
        self.init(width: s.width, height: s.height)
    }

    /// An empty size.
    public static let zero = NDSize(width: 0.0, height: 0.0)

    /// A unit size.
    public static let one = NDSize(width: 1.0, height: 1.0)

    /// - Returns: Whether the width or height is zero.
    public var isEmpty: Bool {
        self.width == 0 || self.height == 0
    }

    /// A half unit size.
    public var halfSize: NDSize { self * 0.5 }
    public var halfWidth: NDFloat { self.width * 0.5 }
    public var halfHeight: NDFloat { self.height * 0.5 }

    /// The smallest dimension of this size, either the width or the height.
    public var smallestSide: NDFloat { min(self.width, self.height) }

    /// The largest dimension of this size, either the width or the height.
    public var largestSide: NDFloat { max(self.width, self.height) }

    /// - Returns: This size scaled by the given scale.
    @inlinable
    public func scaled(by scale: NDFloat) -> Self {
        NDSize(width: self.width * scale, height: self.height * scale)
    }

    /// - Returns: A concise debug description, rounded to two decimal places.
    public var roundedDescription: String {
        "(w: \(self.width.rounded(.hundredths)), h: \(self.height.rounded(.hundredths)))"
    }

    /// - Returns: The magnitude squared (skips the square root).
    @inlinable
    public var magnitudeSquared: NDFloat {
        width * width + height * height
    }

    /// Subtraction operator for two sizes.
    public static func -(lhs: NDSize, rhs: NDSize) -> NDSize {
        return NDSize(
            width: lhs.width - rhs.width,
            height: lhs.height - rhs.height
        )
    }

    /// Multiplication operator for two sizes.
    public static func *(lhs: NDSize, rhs: NDFloat) -> NDSize {
        return NDSize(
            width: lhs.width * rhs,
            height: lhs.height * rhs
        )
    }

    /// Division operator for two sizes.
    public static func /(lhs: NDSize, rhs: NDFloat) -> NDSize {
        return NDSize(
            width: lhs.width / rhs,
            height: lhs.height / rhs
        )
    }

    /// Comparison operator for two sizes.
    @inlinable
    public static func < (lhs: NDSize, rhs: NDSize) -> Bool {
        lhs.magnitudeSquared < rhs.magnitudeSquared
    }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
extension NDSize : Sendable {
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
extension NDSize : BitwiseCopyable {
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
extension NDSize : Comparable {
}
