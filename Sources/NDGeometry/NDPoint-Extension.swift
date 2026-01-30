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
import SwiftUI

nonisolated public extension NDPoint {
    /// - Returns: A point rotated by the given angle, faded by the ratio of its magnitude to a max magnitude.
    func fadedRotate(maxMagnitude: NDFloat, angle: Angle) -> NDPoint {
        let startMagnitude = self.magnitude
        let startSwirledAngle = startMagnitude / maxMagnitude * angle.radians
        let cosAngle = cos(startSwirledAngle)
        let sinAngle = sin(startSwirledAngle)
        return NDPoint(
            x: cosAngle * self.x - sinAngle * self.y,
            y: sinAngle * self.x + cosAngle * self.y)
    }

    /// - Returns: A point rotated by the given angle, faded by the ratio of its magnitude to a max magnitude.
    func fadedRotate(minMagnitude: NDFloat, maxMagnitude: NDFloat, angle: Angle) -> NDPoint {
        let magnitudeRange = maxMagnitude - minMagnitude
        let relativeMagnitude = self.magnitude - minMagnitude
        let swirledAngle = relativeMagnitude / magnitudeRange * angle.radians
        let cosAngle = cos(swirledAngle)
        let sinAngle = sin(swirledAngle)
        return NDPoint(
            x: cosAngle * self.x - sinAngle * self.y,
            y: sinAngle * self.x + cosAngle * self.y)
    }
}
