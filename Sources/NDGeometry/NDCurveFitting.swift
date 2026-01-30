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

import SwiftUI

nonisolated public extension Path {
    /// Fits one or more cubic Bézier segments to a polyline (sample points) using
    /// the classic Schneider “FitCurves” approach (Graphics Gems).
    ///
    /// - Parameters:
    ///   - points: Samples along an unknown smooth curve.
    ///   - errorTolerance: Max allowed squared distance (in your unit space) from samples to fitted curve.
    /// - Returns: A SwiftUI Path built only from move(to:), addCurve(to:control1:control2:), and closeSubpath().
    static func fitPointsToCurve(
        _ points: [NDPoint],
        errorTolerance: NDFloat,
        moveToFirst: Bool = true
    ) -> Path {
        var path = Path()
        guard points.count >= 2 else { return path }

        // If they gave a closed polyline (first == last), fit the open set then close.
        let isClosed = points.count >= 3 && points.first == points.last
        let pts = isClosed ? Array(points.dropLast()) : points

        guard pts.count >= 2 else { return path }

        if moveToFirst {
            path.move(to: pts[0].cgPoint)
        }

        // End tangents from the polyline.
        let tanL = (pts[1] - pts[0]).normalized
        let tanR = (pts[pts.count - 2] - pts[pts.count - 1]).normalized

        let beziers = fitCubic(pts, 0, pts.count - 1, tanL, tanR, errorTolerance)

        // Stitch segments.
        for b in beziers {
            path.addCurve(to: b.p3.cgPoint, control1: b.p1.cgPoint, control2: b.p2.cgPoint)
        }

        if isClosed {
            path.closeSubpath()
        }

        return path
    }

    // MARK: - Core fitter (Schneider / FitCurves)

    private struct Cubic {
        var p0: NDPoint
        var p1: NDPoint
        var p2: NDPoint
        var p3: NDPoint
    }

    private static func fitCubic(
        _ pts: [NDPoint],
        _ first: Int,
        _ last: Int,
        _ tanL: NDPoint,
        _ tanR: NDPoint,
        _ error: NDFloat
    ) -> [Cubic] {

        // Base case: fit a single cubic to two points by placing handles along tangents.
        if last - first == 1 {
            let p0 = pts[first]
            let p3 = pts[last]
            let dist = (p3 - p0).magnitude
            let alpha = dist / 3.0
            let p1 = p0 + tanL * alpha
            let p2 = p3 + tanR * alpha
            return [Cubic(p0: p0, p1: p1, p2: p2, p3: p3)]
        }

        // 1) Parameterize points (chord-length).
        var u = chordLengthParameterize(pts, first, last)

        // 2) Generate initial Bézier.
        var bez = generateBezier(pts, first, last, u, tanL, tanR)

        // 3) Find max error.
        var (maxErr, splitIndex) = computeMaxError(pts, first, last, bez, u)

        // If within tolerance, accept.
        if maxErr <= error {
            return [bez]
        }

        // If "kind of close", try reparameterization iterations.
        // (These iterations are important for “wiggly” shapes like sine-like waves.)
        let iterationError = error * 4.0
        if maxErr < iterationError {
            for _ in 0..<10 {
                u = reparameterize(pts, first, last, bez, u)
                bez = generateBezier(pts, first, last, u, tanL, tanR)
                let r = computeMaxError(pts, first, last, bez, u)
                maxErr = r.0
                splitIndex = r.1
                if maxErr <= error { return [bez] }
            }
        }

        // 4) Split at point of max error and recurse.
        // Center tangent at split is averaged from neighbors.
        let tanCenter = computeCenterTangent(pts, splitIndex)
        let left = fitCubic(pts, first, splitIndex, tanL, tanCenter, error)
        let right = fitCubic(pts, splitIndex, last, -tanCenter, tanR, error)
        return left + right
    }

    // MARK: - Parameterization

    private static func chordLengthParameterize(
        _ pts: [NDPoint], _ first: Int, _ last: Int) -> [NDFloat] {
        let n = last - first + 1
        var u = Array(repeating: NDFloat.zero, count: n)
        u[0] = 0
        for i in 1..<n {
            u[i] = u[i - 1] + (pts[first + i] - pts[first + i - 1]).magnitude
        }
        let total = u[n - 1]
        if total > 0 {
            for i in 1..<n { u[i] /= total }
        } else {
            // Degenerate: all points identical; keep u all zeros.
        }
        return u
    }

    // MARK: - Bézier generation (least squares)

    private static func generateBezier(
        _ pts: [NDPoint],
        _ first: Int,
        _ last: Int,
        _ u: [NDFloat],
        _ tanL: NDPoint,
        _ tanR: NDPoint
    ) -> Cubic {

        let p0 = pts[first]
        let p3 = pts[last]
        let n = last - first + 1

        // Set up normal equations for alphaL, alphaR.
        var C00: NDFloat = 0, C01: NDFloat = 0, C11: NDFloat = 0
        var X0: NDFloat = 0, X1: NDFloat = 0

        for i in 0..<n {
            let t = u[i]
            let b0 = bernstein0(t)
            let b1 = bernstein1(t)
            let b2 = bernstein2(t)
            let b3 = bernstein3(t)

            // A’s are tangent vectors scaled by basis for control points 1 and 2.
            let a1 = tanL * b1
            let a2 = tanR * b2

            // rhs = P(t) - (P0*b0 + P0*b1 + P3*b2 + P3*b3) but with control points unknown,
            // we move the known parts to the right:
            let tmp = pts[first + i] - (p0 * (b0 + b1)) - (p3 * (b2 + b3))

            C00 += dot(a1, a1)
            C01 += dot(a1, a2)
            C11 += dot(a2, a2)

            X0 += dot(a1, tmp)
            X1 += dot(a2, tmp)
        }

        // Solve:
        // [C00 C01][alphaL] = [X0]
        // [C01 C11][alphaR]   [X1]
        let det = C00 * C11 - C01 * C01

        var alphaL: NDFloat = 0
        var alphaR: NDFloat = 0

        if abs(det) > 1e-12 {
            alphaL = (X0 * C11 - X1 * C01) / det
            alphaR = (C00 * X1 - C01 * X0) / det
        } else {
            // Nearly singular: fall back to simple handle lengths.
            let dist = (p3 - p0).magnitude
            alphaL = dist / 3.0
            alphaR = dist / 3.0
        }

        // Clamp alphas if they go negative or too small.
        // Negative alphas imply control points “behind” the endpoints along tangents.
        let segLen = (p3 - p0).magnitude
        let eps: NDFloat = 1e-6
        let minAlpha = segLen * 1e-3 + eps

        if alphaL < minAlpha || alphaR < minAlpha {
            alphaL = segLen / 3.0
            alphaR = segLen / 3.0
        }

        let p1 = p0 + tanL * alphaL
        let p2 = p3 + tanR * alphaR

        return Cubic(p0: p0, p1: p1, p2: p2, p3: p3)
    }

    // MARK: - Error computation

    private static func computeMaxError(
        _ pts: [NDPoint],
        _ first: Int,
        _ last: Int,
        _ bez: Cubic,
        _ u: [NDFloat]
    ) -> (NDFloat, Int) {

        var maxDist: NDFloat = 0
        var split = (last + first) / 2
        let n = last - first + 1

        for i in 1..<(n - 1) { // ignore endpoints
            let p = pts[first + i]
            let q = bezierPoint(bez, u[i])
            let d = (q - p).magnitudeSquared
            if d > maxDist {
                maxDist = d
                split = first + i
            }
        }
        return (maxDist, split)
    }

    // MARK: - Reparameterization (Newton-Raphson)

    private static func reparameterize(
        _ pts: [NDPoint],
        _ first: Int,
        _ last: Int,
        _ bez: Cubic,
        _ u: [NDFloat]
    ) -> [NDFloat] {

        let n = last - first + 1
        var uPrime = u
        for i in 0..<n {
            uPrime[i] = newtonRaphsonRootFind(bez, pts[first + i], u[i])
            // Keep parameters in [0, 1] to avoid blow-ups.
            uPrime[i] = min(1, max(0, uPrime[i]))
        }
        return uPrime
    }

    private static func newtonRaphsonRootFind(_ bez: Cubic, _ p: NDPoint, _ u: NDFloat) -> NDFloat {
        let q = bezierPoint(bez, u)
        let q1 = bezierFirstDerivative(bez, u)
        let q2 = bezierSecondDerivative(bez, u)

        let diff = q - p
        let numerator = dot(diff, q1)
        let denominator = dot(q1, q1) + dot(diff, q2)

        if abs(denominator) < 1e-12 { return u }
        return u - numerator / denominator
    }

    // MARK: - Center tangent

    private static func computeCenterTangent(_ pts: [NDPoint], _ center: Int) -> NDPoint {
        let v1 = (pts[center - 1] - pts[center]).normalized
        let v2 = (pts[center] - pts[center + 1]).normalized
        let t = (v1 + v2).normalized
        // If degenerate, fall back to simple direction.
        return t.magnitudeSquared > 0 ? t : (pts[center + 1] - pts[center - 1]).normalized
    }

    // MARK: - Bézier evaluation

    private static func bezierPoint(_ b: Cubic, _ t: NDFloat) -> NDPoint {
        let mt = 1 - t
        let mt2 = mt * mt
        let t2 = t * t

        let a = b.p0 * (mt2 * mt)
        let c1 = b.p1 * (3 * mt2 * t)
        let c2 = b.p2 * (3 * mt * t2)
        let d = b.p3 * (t2 * t)
        return a + c1 + c2 + d
    }

    private static func bezierFirstDerivative(_ b: Cubic, _ t: NDFloat) -> NDPoint {
        // 3*( (P1-P0)*(1-t)^2 + 2*(P2-P1)*(1-t)*t + (P3-P2)*t^2 )
        let mt = 1 - t
        let a = (b.p1 - b.p0) * (mt * mt)
        let c = (b.p2 - b.p1) * (2 * mt * t)
        let d = (b.p3 - b.p2) * (t * t)
        return (a + c + d) * 3
    }

    private static func bezierSecondDerivative(_ b: Cubic, _ t: NDFloat) -> NDPoint {
        // 6*( (P2 - 2P1 + P0)*(1-t) + (P3 - 2P2 + P1)*t )
        let mt = 1 - t
        let a = (b.p2 - (b.p1 * 2) + b.p0) * mt
        let c = (b.p3 - (b.p2 * 2) + b.p1) * t
        return (a + c) * 6
    }

    // MARK: - Bernstein basis (cubic)

    private static func bernstein0(_ t: NDFloat) -> NDFloat {
        let mt = 1 - t; return mt * mt * mt
    }

    private static func bernstein1(_ t: NDFloat) -> NDFloat {
        let mt = 1 - t; return 3 * mt * mt * t
    }

    private static func bernstein2(_ t: NDFloat) -> NDFloat {
        let mt = 1 - t; return 3 * mt * t * t
    }

    private static func bernstein3(_ t: NDFloat) -> NDFloat {
        return t * t * t
    }

    // MARK: - Vector helpers

    private static func dot(_ a: NDPoint, _ b: NDPoint) -> NDFloat {
        a.x * b.x + a.y * b.y
    }

    private static func abs(_ x: NDFloat) -> NDFloat {
        Swift.abs(x)
    }
}
