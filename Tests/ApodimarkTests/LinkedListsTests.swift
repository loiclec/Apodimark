//
//  LinkedListsTests.swift
//  Apodimark
//

import XCTest
@testable import Apodimark

extension LinkedList {
    func index(_ idx: LinkedListIndex<Element>, offsetBy dist: Int) -> LinkedListIndex<Element> {
        var i = idx
        for _ in 0 ..< dist {
            i = index(after: i)
        }
        return i
    }
}

class LinkedListsTests: XCTestCase {

    static let allTests = [
        ("testEmptyList", testEmptyList),
        ("testPrepend", testPrepend),
        ("testAddAfterNonOptionalIndex", testAddAfterNonOptionalIndex),
        ("testAddAfterOptionalIndex", testAddAfterOptionalIndex),
    ]

    func testEmptyList() {
        let l1 = LinkedList<Int>()
        XCTAssertTrue(l1.count == 0)
        
        let l2: LinkedList<Int> = []
        XCTAssertTrue(l2.count == 0)
    }
    
    func testPrepend() {
        let l: LinkedList<Int> = []
        for x in 0 ..< 10 {
            l.prepend(x)
        }
        XCTAssertEqual(Array(l), Array(0 ..< 10).reversed())
    }

    func testAddAfterNonOptionalIndex() {
        let l: LinkedList<Int> = [1, 2, 3, 4]
        
        l.add(20, after: l.index(after: l.startIndex))
        XCTAssertEqual(Array(l), [1, 2, 20, 3, 4])
    
        let indexOf3BeforeAdding30 = l.index(l.startIndex, offsetBy: 3)
        
        l.add(30, after: indexOf3BeforeAdding30)
        XCTAssertEqual(Array(l), [1, 2, 20, 3, 30, 4])
        
        let indexOf30 = l.index(after: indexOf3BeforeAdding30)
        
        l.add(31, after: indexOf30)
        XCTAssertEqual(Array(l), [1, 2, 20, 3, 30, 31, 4])
        
        l.add(40, after: l.index(indexOf30, offsetBy: 2))
        XCTAssertEqual(Array(l), [1, 2, 20, 3, 30, 31, 4, 40])
    }
    
    func testAddAfterOptionalIndex() {
        let l: LinkedList<Int> = [2, 3, 4]
                
        l.add(1, after: nil)
        XCTAssertEqual(Array(l), [1, 2, 3, 4])

        l.add(10, after: .some(l.startIndex))
        XCTAssertEqual(Array(l), [1, 10, 2, 3, 4])
        
        l.add(40, after: l.index(l.startIndex, offsetBy: l.count - 1))
        XCTAssertEqual(Array(l), [1, 10, 2, 3, 4, 40])
    }
}
