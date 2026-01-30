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

nonisolated public extension CGAffineTransform {
    /// Shear (skew) specified as angles.
    ///
    /// Matrix form:
    ///   x' = x + c*y   where c = tan(xAngle)   (horizontal / x-shear)
    ///   y' = y + b*x   where b = tan(yAngle)   (vertical / y-shear)
    static func shear(
        xAngle: NDAngle = NDAngle(),
        yAngle: NDAngle = NDAngle(),
        clampToAngle limitAngle: NDAngle = NDAngle(degrees: 85)
    ) -> CGAffineTransform {

        // Clamp to avoid tan() exploding near ±90°
        let xa = xAngle.clamped(to: -limitAngle...limitAngle)
        let ya = yAngle.clamped(to: -limitAngle...limitAngle)

        return CGAffineTransform(
            a: 1,
            b: tan(ya.radians),   // vertical shear
            c: tan(xa.radians),   // horizontal shear
            d: 1,
            tx: 0,
            ty: 0
        )
    }

    /// Build a transform that applies shear first, then rotation.
    ///
    /// Usage:
    ///
    /// let transform = CGAffineTransform.shearThenRotate(
    ///     xShearAngle: shearX,
    ///     yShearAngle: shearY,
    ///     rotationAngle: rotation,
    ///     clampShearToAngle: Angle(degrees: 85)
    /// )
    ///
    /// let newPath = path.applying(transform)
    ///
    static func shearThenRotate(
        xShearAngle: NDAngle = NDAngle(),
        yShearAngle: NDAngle = NDAngle(),
        rotationAngle: NDAngle,
        clampShearToAngle limitAngle: NDAngle = NDAngle(degrees: 85)
    ) -> CGAffineTransform {

        let shear = CGAffineTransform.shear(
            xAngle: xShearAngle,
            yAngle: yShearAngle,
            clampToAngle: limitAngle
        )

        let rot = CGAffineTransform(rotationAngle: rotationAngle.radians)

        // Apply shear first, then rotation.
        return shear.concatenating(rot)
    }
}
