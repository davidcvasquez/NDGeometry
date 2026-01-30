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

///  Functions for linear interpolation of various types.
///
///  Acknowledgments
///  Some of the code in this file was originally published from this URL as public domain code:
///
///  https://rtorres.me/blog/lerp-swift/
///
///  Written by Ramon Torres
///  Placed under public domain.

import CoreGraphics

// swiftlint:disable identifier_name

/// Linearly interpolates between two values.
///
/// Interpolates between the values `v0` and `v1` by a factor `t`.
///
/// - Parameters:
///   - v0: The first value.
///   - v1: The second value.
///   - t: The interpolation factor. Between `0` and `1`.
/// - Returns: The interpolated value.
@inline(__always)
nonisolated public func lerp<V: BinaryFloatingPoint, T: BinaryFloatingPoint>(
    _ v0: V, _ v1: V, _ t: T
) -> V {
    return v0 + V(t) * (v1 - v0)
}

public typealias StopsAndValues<V: BinaryFloatingPoint, T: BinaryFloatingPoint> =
    [(stop: T, value: V)]

/// Linearly interpolate across multiple values.
///
/// Use the simpler version without stops for interpolation between two values.
///
/// Interpolates between the nearest stop-and-value tuples by the factor `t`.
///
/// - Parameters:
///   - stops: An array of stop-and-value tuples.
///   - t: The interpolation factor. Between `0` and `1`.
/// - Returns: The interpolated value.
@inline(__always)
nonisolated public func lerp<V: BinaryFloatingPoint, T: BinaryFloatingPoint>(
    _ stops: StopsAndValues<V, T>, _ t: T
) -> V {
    guard !stops.isEmpty else {
        return 0.0
    }

    if let first = stops.first {
        if t <= first.stop {
            return first.value
        }
    }
    else if let last = stops.last {
        if t >= last.stop {
            return last.value
        }
    }

    var result: V = 0.0
    guard stops.count > 1 else {
        return stops[0].value
    }
    for index in 0..<stops.count - 1 {
        let leadingStop = stops[index]
        let trailingStop = stops[index + 1]
        if t >= leadingStop.stop && t <= trailingStop.stop {
            let range = trailingStop.stop - leadingStop.stop
            let rangeT = (t - leadingStop.stop) / range
            result = lerp(leadingStop.value, trailingStop.value, rangeT)
            break
        }
    }
    return result
}

/// Linearly interpolates between two points.
///
/// Interpolates between the points `p0` and `p1` by a factor `t`.
///
/// - Parameters:
///   - p0: The first point.
///   - p1: The second point.
///   - t: The interpolation factor. Between `0` and `1`.
/// - Returns: The interpolated point.
@inline(__always)
nonisolated public func lerp<T: BinaryFloatingPoint>(
    _ p0: NDPoint, _ p1: NDPoint, _ t: T
) -> NDPoint {
    return NDPoint(
        x: lerp(p0.x, p1.x, t),
        y: lerp(p0.y, p1.y, t)
    )
}

public typealias StopsAndPoints<T: BinaryFloatingPoint> = [(stop: T, point: NDPoint)]

/// Linearly interpolate between multiple points.
///
/// Use the simpler version without stops for interpolation between two points.
///
/// Interpolates between the nearest stop-and-point tuples by the factor `t`.
///
/// - Parameters:
///   - stops: An array of stop-and-point tuples.
///   - t: The interpolation factor. Between `0` and `1`.
/// - Returns: The interpolated point.
@inline(__always)
nonisolated public func lerp<T: BinaryFloatingPoint>(
    _ stops: StopsAndPoints<T>, _ t: T
) -> NDPoint {
    guard !stops.isEmpty else {
        return .zero
    }

    if let first = stops.first {
        if t <= first.stop {
            return first.point
        }
    }
    else if let last = stops.last {
        if t >= last.stop {
            return last.point
        }
    }

    var result = NDPoint.zero
    guard stops.count > 1 else {
        return stops[0].point
    }
    for index in 0..<stops.count - 1 {
        let leadingStop = stops[index]
        let trailingStop = stops[index + 1]
        if t >= leadingStop.stop && t <= trailingStop.stop {
            let range = trailingStop.stop - leadingStop.stop
            let rangeT = (t - leadingStop.stop) / range
            result = lerp(leadingStop.point, trailingStop.point, rangeT)
            break
        }
    }
    return result
}

/// Note: Support for vector types was not included in the original code.
///
/// Linearly interpolates between two vectors.
///
/// Interpolates between the vectors `v0` and `v1` by a factor `t`.
///
/// - Parameters:
///   - v0: The first vector.
///   - v1: The second vector.
///   - t: The interpolation factor. Between `0` and `1`.
/// - Returns: The interpolated vector.
@inline(__always)
nonisolated public func lerp<T: BinaryFloatingPoint>(
    _ v0: CGVector, _ v1: CGVector, _ t: T
) -> CGVector {
    return CGVector(
        dx: lerp(v0.dx, v1.dx, t),
        dy: lerp(v0.dy, v1.dy, t)
    )
}

/// Note: Support for vector types was not included in the original code.
///
/// Linearly interpolates between two vectors.
///
/// Interpolates between the vectors `v0` and `v1` by a factor `t`.
///
/// - Parameters:
///   - v0: The first vector.
///   - v1: The second vector.
///   - t: The interpolation factor. Between `0` and `1`.
/// - Returns: The interpolated vector.
@inline(__always)
nonisolated public func lerp<T: BinaryFloatingPoint>(
    _ v0: NDVector, _ v1: NDVector, _ t: T
) -> NDVector {
    return NDVector(
        dx: lerp(v0.dx, v1.dx, t),
        dy: lerp(v0.dy, v1.dy, t)
    )
}

/// Linearly interpolates between two sizes.
///
/// Interpolates between the sizes `s0` and `s1` by a factor `t`.
///
/// - Parameters:
///   - s0: The first size.
///   - s1: The second size.
///   - t: The interpolation factor. Between `0` and `1`.
/// - Returns: The interpolated size.
@inline(__always)
nonisolated public func lerp<T: BinaryFloatingPoint>(
    _ s0: NDSize, _ s1: NDSize, _ t: T
) -> NDSize {
    return NDSize(
        width: lerp(s0.width, s1.width, t),
        height: lerp(s0.height, s1.height, t)
    )
}

/// Linearly interpolates between two rectangles.
///
/// Interpolates between the rectangles `r0` and `r1` by a factor `t`.
///
/// - Parameters:
///   - r0: The first rectangle.
///   - r1: The second rectangle.
///   - t: The interpolation factor. Between `0` and `1`.
/// - Returns: The interpolated rectangle.
@inline(__always)
nonisolated public func lerp<T: BinaryFloatingPoint>(
    _ r0: NDRect, _ r1: NDRect, _ t: T
) -> NDRect {
    return NDRect(
        origin: lerp(r0.origin, r1.origin, t),
        size: lerp(r0.size, r1.size, t)
    )
}

/// Inverse linear interpolation.
///
/// Given a value `v` between `v0` and `v1`, returns the interpolation factor `t`
/// such that `v == lerp(v0, v1, t)`.
///
/// - Parameters:
///   - v0: The lower bound of the interpolation range.
///   - v1: The upper bound of the interpolation range.
///   - v: The value to interpolate.
/// - Returns: The interpolation factor `t` such that `v == lerp(v0, v1, t)`.
@inline(__always)
nonisolated public func inverseLerp<V: BinaryFloatingPoint, T: BinaryFloatingPoint>(
    _ v0: V, _ v1: V, _ v: V
) -> T {
    return T((v - v0) / (v1 - v0))
}

// swiftlint:enable identifier_name
