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

import XCTest
import SwiftUI
@testable import NDGeometry

final class NDCurveFittingTests: XCTestCase {
    func testCurveFittingCountOpenMoveToFirst() {
        let path = Path.fitPointsToCurve(
            [
                NDPoint(x: 0, y: 0),
                NDPoint(x: 5, y: 5),
                NDPoint(x: 10, y: 0)
            ],
            errorTolerance: 0.001,
            moveToFirst: true
        )
        XCTAssertFalse(path.isEmpty)
    }

    func testCurveFittingCountClosedMoveToFirst() {
        let path = Path.fitPointsToCurve(
            [
                NDPoint(x: 0, y: 0),
                NDPoint(x: 5, y: 5),
                NDPoint(x: 10, y: 0),
                NDPoint(x: 0, y: 0)
            ],
            errorTolerance: 0.001,
            moveToFirst: true
        )
        XCTAssertFalse(path.isEmpty)
    }

    func testCurveFittingCountDoNotMoveToFirst() {
        let path = Path.fitPointsToCurve(
            [
                NDPoint(x: 0, y: 0),
                NDPoint(x: 5, y: 5),
                NDPoint(x: 10, y: 0)
            ],
            errorTolerance: 0.001,
            moveToFirst: false
        )
        XCTAssertFalse(path.isEmpty)
    }

    func testCurveFittingNotEnoughPoints() {
        let path = Path.fitPointsToCurve(
            [
                NDPoint(x: 0, y: 0)
            ],
            errorTolerance: 0.001,
            moveToFirst: true
        )
        XCTAssertTrue(path.isEmpty)
    }
}
