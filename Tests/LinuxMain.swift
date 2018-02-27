#if os(Linux)

import XCTest
@testable import ApodimarkTests
@testable import PerformanceTests

XCTMain([
    // ApodimarkTests
    testCase(CommonMarkConformanceTests.allTests),
    
    // PerformanceTests
    testCase(PerformanceTests.allTests),
])

#endif
