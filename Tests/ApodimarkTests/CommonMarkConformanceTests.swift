
import XCTest
import Foundation
import Apodimark

private let tests = [
      1,   2,   3,   4,   5,   6,   7,   8,   9,  10,
     11,  12,  13,  14,  15,  16,  17,  18,  19,  20,
     21,  22,  23,       25,  26,  27,  28,  29,  30,
     31,  32,  33,  34,  35,  36,  37,  38,  39,  40,
     41,  42,  43,  44,  45,


          72,  73,  74,  75,  76,  77,  78,  79,
     81,  82,  83,  84,  85,  86,  87,  88,  89,  90,
     91,  92,  93,  94,  95,  96,  97,  98,  99, 100,
    101, 102, 103, 104,      106, 107, 108, 109, 110,




              153,      155,                     160,
              163, 164, 165, 166,                170,
    171, 172, 173,      175, 176, 177, 178, 179, 180,
    181, 182, 183, 184, 185, 186, 187, 188, 189, 190,
    191, 192, 193, 194, 195, 196, 197, 198, 199, 200,
    201, 202, 203, 204, 205, 206, 207, 208,      210,
    211, 212, 213, 214, 215, 216, 217, 218, 219, 220,
    221, 222, 223, 224, 225, 226, 227, 228, 229, 230,
    231, 232, 233, 234, 235, 236, 237, 238, 239, 240,
    241, 242, 243, 244, 245, 246, 247, 248, 249, 250,
    251, 252, 253, 254, 255,      257, 258, 259, 260,
    261, 262, 263, 264, 265, 266, 267,

    281, 282, 283, 284, 285, 286, 287, 288, 289,

                                  307, 308, 309, 310,
    311, 312, 314, 315,                          320,
    321, 322, 323, 324,      326, 327, 328, 329, 330,
    331, 332, 333, 334, 335, 336, 337, 338, 339, 340,
    341, 342, 343, 344, 345, 346, 347, 348, 349, 350,
    351, 352, 353, 354, 355, 356, 357, 358, 359, 360,
    361, 362, 363, 364, 365, 366, 367, 368, 369, 370,
    371, 372, 373, 374, 375, 376, 377, 378, 379, 380,
    381, 382, 383, 384, 385, 386, 387, 388, 389, 390,
    391, 392, 393, 394, 395, 396, 397, 398, 399, 400,
    401, 402, 403, 404, 405, 406, 407, 408, 409, 410,
    411, 412, 413, 414, 415, 416, 417, 418, 419, 420,
    421, 422, 423, 424, 425, 426, 427, 428, 429, 430,
    431, 432, 433, 434, 435, 436, 437, 438, 439, 440,
    441, 442, 443,                447, 448,
    451, 452, 453,                          459,
                   464, 465, 466,
                   474, 475, 476, 477, 478, 479, 480,
                   484, 485, 486,      488,      490,
    491, 492, 493, 494,           497, 498,      500,
         502, 503,      505, 506, 507, 508, 509, 510,
    511, 512,      514,                          520,
    521, 522, 523, 524, 525, 526, 527, 528, 529, 530,
    531, 532, 533,                537, 538, 539,
    541, 542, 543,                547, 548, 549, 550,
    551, 552, 553,



                   594, 595, 596, 597, 598, 599, 600,
                        605, 606, 607, 608, 609, 610,
    611, 612, 613,
]


private func stringForTest(number: Int, result: Bool = false) -> String {
    let dirUrl = URL(fileURLWithPath: #file).deletingLastPathComponent().deletingLastPathComponent().deletingLastPathComponent()
    let fileUrl = dirUrl.appendingPathComponent("test-files/commonmark-conformance/\(number)" + (result ? "-result" : "") + ".txt")
    return try! String(contentsOf: fileUrl)
}

class CommonMarkConformanceTests : XCTestCase {

    static let allTests = [
        ("testSpecStringUTF16View", testSpecStringUTF16View),
        ("testSpecStringUnicodeScalarView", testSpecStringUnicodeScalarView),
        ("testSpecStringCharacterView", testSpecStringCharacterView),
        ("testSpecArrayUInt32", testSpecArrayUInt32),
        ("testSpecUnsafeBufferPointerUInt8", testSpecUnsafeBufferPointerUInt8),
    ]

    func testSpecStringUTF16View() {
        for no in tests {
            let source = stringForTest(number: no).utf16
            let doc = parsedMarkdown(source: source, definitionStore: DefaultReferenceDefinitionStore(), codec: UTF16MarkdownCodec.self)
            let desc = MarkdownBlock.output(nodes: doc, source: source, codec: UTF16MarkdownCodec.self)
            let result = stringForTest(number: no, result: true)
            XCTAssertEqual(desc, result, "\(no)")
        }
    }

    func testSpecStringUnicodeScalarView() {
        for no in tests {
            let source = stringForTest(number: no).unicodeScalars
            let doc = parsedMarkdown(source: source, definitionStore: DefaultReferenceDefinitionStore(), codec: UnicodeScalarMarkdownCodec.self)
            let desc = MarkdownBlock.output(nodes: doc, source: source, codec: UnicodeScalarMarkdownCodec.self)
            let result = stringForTest(number: no, result: true)
            XCTAssertEqual(desc, result, "\(no)")
        }
    }

    func testSpecStringCharacterView() {
        for no in tests {
            let source = stringForTest(number: no).characters
            let doc = parsedMarkdown(source: source, definitionStore: DefaultReferenceDefinitionStore(), codec: CharacterMarkdownCodec.self)
            let desc = MarkdownBlock.output(nodes: doc, source: source, codec: CharacterMarkdownCodec.self)
            let result = stringForTest(number: no, result: true)
            XCTAssertEqual(desc, result, "\(no)")
        }
    }

    func testSpecArrayUInt32() {
        for no in tests {
            let source = Array(stringForTest(number: no).unicodeScalars).map { $0.value }
            let doc = parsedMarkdown(source: source, definitionStore: DefaultReferenceDefinitionStore(), codec: UTF32MarkdownCodec.self)
            let desc = MarkdownBlock.output(nodes: doc, source: source, codec: UTF32MarkdownCodec.self)
            let result = stringForTest(number: no, result: true)
            XCTAssertEqual(desc, result, "\(no)")
        }
    }

    func testSpecUnsafeBufferPointerUInt8() {
        for no in tests {
            let arr = Array(stringForTest(number: no).utf8)
            let source = arr.withUnsafeBufferPointer { $0 }
            let doc = parsedMarkdown(source: source, definitionStore: DefaultReferenceDefinitionStore(), codec: UTF8MarkdownCodec.self)
            let desc = MarkdownBlock.output(nodes: doc, source: source, codec: UTF8MarkdownCodec.self)
            let result = stringForTest(number: no, result: true)
            XCTAssertEqual(desc, result, "\(no)")
        }
    }
}
