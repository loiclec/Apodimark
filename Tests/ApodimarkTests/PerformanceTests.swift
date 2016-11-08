
import XCTest
import Apodimark

private func baseStringForTest(_ name: String, result: Bool = false) -> String {
    let dirUrl = URL(fileURLWithPath: #file).deletingLastPathComponent().deletingLastPathComponent().deletingLastPathComponent()
    let fileUrl = dirUrl.appendingPathComponent("test-files/performance/" + name + ".txt")
    
    return try! String(contentsOf: fileUrl)
}

private func testString(size: Int) -> String {
    let base = baseStringForTest("mixed1")
    var s = ""
    while s.utf16.count < size {
        s += base
    }
    return s
}

class PerformanceTests : XCTestCase {
    static let allTests = [
        ("testArrayUTF8_100_000", testArrayUTF8_100_000),
        ("testArrayUTF8_1_000_000", testArrayUTF8_1_000_000),
        ("testArrayUTF8_10_000_000", testArrayUTF8_10_000_000),
        ("testCharacter_100_000", testCharacter_100_000),
        ("testCharacter_1_000_000", testCharacter_1_000_000),
        ("testCharacter_10_000_000", testCharacter_10_000_000),
        ("testCharacter_10_000_000", testCharacter_10_000_000),
        ("testUnicodeScalar_100_000", testUnicodeScalar_100_000),
        ("testUnicodeScalar_1_000_000", testUnicodeScalar_1_000_000),
        ("testUnicodeScalar_10_000_000", testUnicodeScalar_10_000_000),
        ("testUTF16_100_000", testUTF16_100_000),
        ("testUTF16_1_000_000", testUTF16_1_000_000),
        ("testUTF16_10_000_000", testUTF16_10_000_000),
    ]
    
    func testArrayUTF8_100_000() {
        let s = testString(size: 100_000)
        let a = Array(s.utf8)
        measure {
            _ = parsedMarkdown(source: a, definitionStore: DefaultReferenceDefinitionStore(), codec: UTF8MarkdownCodec.self)
        }
    }
    
    func testArrayUTF8_1_000_000() {
        let s = testString(size: 1_000_000)
        let a = Array(s.utf8)
        measure {
            _ = parsedMarkdown(source: a, definitionStore: DefaultReferenceDefinitionStore(), codec: UTF8MarkdownCodec.self)
        }
    }
    
    func testArrayUTF8_10_000_000() {
        let s = testString(size: 10_000_000)
        let a = Array(s.utf8)
        measure {
            _ = parsedMarkdown(source: a, definitionStore: DefaultReferenceDefinitionStore(), codec: UTF8MarkdownCodec.self)
        }
    }
    
    func testCharacter_100_000() {
        let s = testString(size: 100_000)
        measure {
            _ = parsedMarkdown(source: s.characters, definitionStore: DefaultReferenceDefinitionStore(), codec: CharacterMarkdownCodec.self)
        }
    }
    
    func testCharacter_1_000_000() {
        let s = testString(size: 1_000_000)
        measure {
            _ = parsedMarkdown(source: s.characters, definitionStore: DefaultReferenceDefinitionStore(), codec: CharacterMarkdownCodec.self)
        }
    }
    
    func testCharacter_10_000_000() {
        let s = testString(size: 10_000_000)
        measure {
            _ = parsedMarkdown(source: s.characters, definitionStore: DefaultReferenceDefinitionStore(), codec: CharacterMarkdownCodec.self)
        }
    }
    
    func testUnicodeScalar_100_000() {
        let s = testString(size: 100_000)
        measure {
            _ = parsedMarkdown(source: s.unicodeScalars, definitionStore: DefaultReferenceDefinitionStore(), codec: UnicodeScalarMarkdownCodec.self)
        }
    }
    
    func testUnicodeScalar_1_000_000() {
        let s = testString(size: 1_000_000)
        measure {
            _ = parsedMarkdown(source: s.unicodeScalars, definitionStore: DefaultReferenceDefinitionStore(), codec: UnicodeScalarMarkdownCodec.self)
        }
    }
    
    func testUnicodeScalar_10_000_000() {
        let s = testString(size: 10_000_000)
        measure {
            _ = parsedMarkdown(source: s.unicodeScalars, definitionStore: DefaultReferenceDefinitionStore(), codec: UnicodeScalarMarkdownCodec.self)
        }
    }
    
    func testUTF16_100_000() {
        let s = testString(size: 100_000)
        measure {
            _ = parsedMarkdown(source: s.utf16, definitionStore: DefaultReferenceDefinitionStore(), codec: UTF16MarkdownCodec.self)
        }
    }
    
    func testUTF16_1_000_000() {
        let s = testString(size: 1_000_000)
        measure {
            _ = parsedMarkdown(source: s.utf16, definitionStore: DefaultReferenceDefinitionStore(), codec: UTF16MarkdownCodec.self)
        }
    }
    
    func testUTF16_10_000_000() {
        let s = testString(size: 10_000_000)
        measure {
            _ = parsedMarkdown(source: s.utf16, definitionStore: DefaultReferenceDefinitionStore(), codec: UTF16MarkdownCodec.self)
        }
    }
}
