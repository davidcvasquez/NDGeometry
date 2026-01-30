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

/// A nonisolated version of CGRect, with additional conveniences for various constants and other common calculations.
@frozen
nonisolated public struct NDRect: Equatable, Hashable, Codable {
    public var origin: NDPoint
    public var size: NDSize

    /// - Returns: This rectangle converted to a CGRect.
    @inlinable
    public var cgRect: CGRect {
        CGRect(origin: origin.cgPoint, size: size.cgSize)
    }

    /// If either the width or the height is zero, the rectangle is considered to be empty.
    public var isEmpty: Bool {
        self.size.isEmpty
    }

    /// Initializer from a point and a size.
    @inlinable
    public init(origin: NDPoint, size: NDSize) {
        self.origin = origin
        self.size = size
    }

    /// Initializer from x and y coordinates and a size.
    @inlinable
    public init(x: NDFloat, y: NDFloat, size: NDSize) {
        self.origin = NDPoint(x: x, y: y)
        self.size = size
    }

    /// Initializer from x and y coordinates and a width and a height.
    @inlinable
    public init(x: NDFloat, y: NDFloat, width: NDFloat, height: NDFloat) {
        self.origin = NDPoint(x: x, y: y)
        self.size = NDSize(width: width, height: height)
    }

    /// Initializer from another rectangle.
    @inlinable
    public init(_ r: CGRect) {
        self.init(origin: NDPoint(r.origin), size: NDSize(r.size))
    }

    /// Convenience initializer for a rectangle that fits an arbitrary number of points.
    @inlinable
    public init(_ points: [NDPoint]) {
        self = .zero
        for (index, point) in points.enumerated() {
            if index == 0 {
                self = point.toRect(radius: 0.0)
            }
            else {
                self.add(point)
            }
        }
    }

    /// Reposition or resize this rectangle to include the given point.
    mutating public func add(_ point: NDPoint) {
        // Preserve existing extents first
        let oldMinX = self.minX
        let oldMinY = self.minY
        let oldMaxX = self.maxX
        let oldMaxY = self.maxY

        let newMinX = min(oldMinX, point.x)
        let newMinY = min(oldMinY, point.y)
        let newMaxX = max(oldMaxX, point.x)
        let newMaxY = max(oldMaxY, point.y)

        self.origin.x = newMinX
        self.origin.y = newMinY
        self.size.width  = newMaxX - newMinX
        self.size.height = newMaxY - newMinY
    }

    /// Reposition or resize this rectangle to include all of the given points.
    mutating public func add(_ points: [NDPoint]) {
        for point in points {
            self.add(point)
        }
    }

    /// - Returns: Whether the given point is contained by this rectangle.
    public func contains(_ point: NDPoint) -> Bool {
        (self.origin.x...self.origin.x + self.size.width).contains(point.x) &&
        (self.origin.y...self.origin.y + self.size.height).contains(point.y)
    }

    /// An empty rectangle at the origin.
    public static let zero = NDRect(
        origin: NDPoint(x: 0.0, y: 0.0), size: NDSize(width: 0.0, height: 0.0))

    /// A unit-sized rectangle at the origin.
    public static let one = NDRect(
        origin: NDPoint(x: 0.0, y: 0.0), size: NDSize(width: 1.0, height: 1.0))

    /// A concise debug description with two digits of decimal precision.
    public var roundedDescription: String {
        "\(self.origin.roundedDescription) \(self.size.roundedDescription)"
    }

    /// - New origin: (x + vector.dx, y + vector.dy)
    /// - New width: width - (2 * vector.dx)
    /// - New height: height - (2 * vector.dy)
    ///
    /// Negative values cause the rectangle to increase in size along the corresponding axis.
    /// - Returns: This rectangle inset by the given dx and dy values.
    @inlinable
    public func insetBy(_ vector: NDVector) -> Self {
        NDRect(origin: NDPoint(x: self.origin.x + vector.dx,
                               y: self.origin.y + vector.dy),
               size: NDSize(width: self.width - 2.0 * vector.dx,
                            height: self.height - 2.0 * vector.dy))
    }

    /// - New origin: (x + dx, y + dy)
    /// - New width: width - (2 * dx)
    /// - New height: height - (2 * dy)
    ///
    /// Negative values cause the rectangle to increase in size along the corresponding axis.
    /// - Returns: This rectangle inset by the given dx and dy values.
    @inlinable
    public func insetBy(dx: NDFloat, dy: NDFloat) -> Self {
        NDRect(origin: NDPoint(x: self.origin.x + dx,
                               y: self.origin.y + dy),
               size: NDSize(width: self.width - 2.0 * dx,
                            height: self.height - 2.0 * dy))
    }

    /// - Returns: This rectangle offset by the given vector.
    @inlinable
    public func offsetBy(_ vector: NDVector) -> Self {
        NDRect(origin: self.origin + vector, size: self.size)
    }

    /// - Returns: This rectangle offset by the given x and y deltas.
    @inlinable
    public func offsetBy(dx: NDFloat, dy: NDFloat) -> Self {
        self.offsetBy(NDVector(dx: dx, dy: dy))
    }

    /// - Returns: The width from the size of this rectangle.
    public var width: NDFloat {
        size.width
    }

    /// - Returns: The height from the size of this rectangle.
    public var height: NDFloat {
        size.height
    }

    /// - Returns: The minimum X coordinate of this rectangle.
    public var minX: NDFloat {
        self.origin.x
    }

    /// - Returns: The minimum Y coordinate of this rectangle.
    public var minY: NDFloat {
        self.origin.y
    }

    /// - Returns: The X coordinate at the center of this rectangle.
    public var midX: NDFloat {
        self.origin.x + self.size.width / 2.0
    }

    /// - Returns: The Y coordinate at the center of this rectangle.
    public var midY: NDFloat {
        self.origin.y + self.size.height / 2.0
    }

    /// - Returns: The maximum X coordinate of this rectangle.
    public var maxX: NDFloat {
        self.origin.x + self.size.width
    }

    /// - Returns: The maximum Y coordinate of this rectangle.
    public var maxY: NDFloat {
        self.origin.y + self.size.height
    }

    /// - Returns: The center point of this rectangle.
    public var center: NDPoint {
        NDPoint(x: self.midX, y: self.midY)
    }

    /// - Returns: The shortest side of this rectangle, either the width or the height.
    public var shortestSide: NDFloat {
        min(self.width, self.height)
    }

    /// - Returns: The longest side of this rectangle, either the width or the height.
    public var longestSide: NDFloat {
        max(self.width, self.height)
    }

    /// - Returns: An array of points representing the corners of this rectangle.
    public var points: [NDPoint] {
        [
            NDPoint(x: self.minX, y: self.minY),
            NDPoint(x: self.maxX, y: self.minY),
            NDPoint(x: self.maxX, y: self.maxY),
            NDPoint(x: self.minX, y: self.maxY)
        ]
    }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
extension NDRect : Sendable {
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
extension NDRect : BitwiseCopyable {
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
extension NDRect : Comparable {
    public static func < (lhs: NDRect, rhs: NDRect) -> Bool {
        lhs.origin.magnitudeSquared < rhs.origin.magnitudeSquared &&
        lhs.size.magnitudeSquared < rhs.size.magnitudeSquared
    }
}
