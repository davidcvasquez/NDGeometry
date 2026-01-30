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

nonisolated public extension NDAngle {
    /// - Returns: A SwiftUI angle for this angle.
    var swiftUIAngle: Angle {
        Angle(radians: Double(radians))
    }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
nonisolated extension NDAngle: Animatable {

    /// The type defining the data to animate.
    ///
    /// Since `NDAngle` is backed by a single floating-point value,
    /// we use `NDFloat` (which is `CGFloat` → `Double` on 64-bit platforms)
    /// as the animatable data type. This matches `SwiftUI.Angle`'s behavior.
    public typealias AnimatableData = NDFloat

    /// The data to animate.
    ///
    /// SwiftUI reads and writes this property during animations to interpolate
    /// between values. We use the stored `radians` directly.
    public var animatableData: NDFloat {
        get { radians }
        set { radians = newValue }
    }

    /// The zero value of this type, used as the identity for interpolation.
    ///
    /// Returns an angle of 0 radians (equivalent to 0 degrees).
    @inlinable public static var zero: NDAngle {
        NDAngle(radians: 0.0)
    }
}

nonisolated public extension Angle {
    /// - Returns: If this angle has a value of zero.
    @inlinable var isZero: Bool {
        self.radians.isZero
    }

    /// - Returns: If this angle does not have a value of zero.
    @inlinable var isNonZero: Bool {
        !self.radians.isZero
    }
}
