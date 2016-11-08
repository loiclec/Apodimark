#if os(Linux)

import XCTest
@testable import ApodimarkTests

XCTMain([
    testCase(CommonMarkConformanceTests.allTests),
    testCase(LinkedListsTests.allTests),
    testCase(PerformanceTests.allTests),
])

#endif
