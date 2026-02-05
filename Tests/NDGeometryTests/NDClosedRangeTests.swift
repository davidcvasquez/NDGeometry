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

final class NDClosedRangeTests: XCTestCase {

    // MARK: - Closed range clamping.

    func testClosedRangeExtensionInt() {
        let rangeStart: Int = 1
        let rangeEnd: Int = 3
        let range: ClosedRange<Int> = rangeStart...rangeEnd
        let testValueInside = 2
        let testValueBefore = 0
        let testValueAfter = 5
        XCTAssertEqual(range.clamp(testValueInside), testValueInside)
        XCTAssertEqual(range.clamp(testValueBefore), rangeStart)
        XCTAssertEqual(range.clamp(testValueAfter), rangeEnd)
    }

    func testClosedRangeExtensionDouble() {
        let rangeStart: Double = 100.5
        let rangeEnd: Double = 256.0
        let range: ClosedRange<Double> = rangeStart...rangeEnd
        let testValueInside = 128.3
        let testValueBefore = 5.25
        let testValueAfter = 768.1
        XCTAssertEqual(range.clamp(testValueInside), testValueInside)
        XCTAssertEqual(range.clamp(testValueBefore), rangeStart)
        XCTAssertEqual(range.clamp(testValueAfter), rangeEnd)
    }
}
