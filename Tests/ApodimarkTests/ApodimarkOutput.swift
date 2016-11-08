
import Apodimark

// FUNCTIONS INTENDED ONLY FOR TESTING PURPOSES
// DO NOT USE “APODIMARK OUTPUT” IF YOU ARE NOT TESTING APODIMARK

extension ListBlockKind: CustomStringConvertible {
    public var description: String {
        switch self {
        case .unordered:
            return "Bullet"
        case .ordered(startingAt: let n):
            return "Number(\(n))"
        }
    }
}

extension MarkdownBlock where
    View.Iterator.Element: Comparable & Hashable,
    View.SubSequence: Collection,
    View.SubSequence.Iterator.Element == View.Iterator.Element,
    RefDef: CustomStringConvertible
{
    typealias Token = View.Iterator.Element

    static func combineNodeOutput <Codec: MarkdownParserCodec> (source: View, codec: Codec.Type) -> (String, MarkdownBlock) -> String
        where Codec.CodeUnit == Token
    {
        return { (acc: String, cur: MarkdownBlock) -> String in
            let appending = output(node: cur, source: source, codec: Codec.self)
            guard !appending.isEmpty else { return acc }
            return acc + appending + ", "
        }
    }

    static func combineNodeOutput <Codec: MarkdownParserCodec> (source: View, codec: Codec.Type) -> (String, MarkdownInline<View, RefDef>) -> String
        where Codec.CodeUnit == Token
    {
        return { (acc: String, cur: MarkdownInline<View, RefDef>) -> String in
            let appending = output(node: cur, source: source, codec: Codec.self)
            guard !appending.isEmpty else { return acc }
            return acc + appending
        }
    }

    static func output <Codec: MarkdownParserCodec> (nodes: [MarkdownBlock], source: View, codec: Codec.Type) -> String
        where Codec.CodeUnit == Token
    {
        return nodes.reduce("Document { ", combineNodeOutput(source: source, codec: Codec.self)) + "}"
    }
    static func output <Codec: MarkdownParserCodec> (nodes: [MarkdownInline<View, RefDef>], source: View, codec: Codec.Type) -> String
        where Codec.CodeUnit == Token
    {
        return nodes.reduce("", combineNodeOutput(source: source, codec: Codec.self))
    }

    static func output <Codec: MarkdownParserCodec> (node: MarkdownInline<View, RefDef>, source: View, codec: Codec.Type) -> String
        where Codec.CodeUnit == Token
    {
        switch node {

        case .text(let t):
            return Codec.string(fromTokens: source[t.span])

        case .emphasis(let e):
            return "e\(e.level)(" + e.content.reduce("", combineNodeOutput(source: source, codec: Codec.self)) + ")"

        case .monospacedText(let m):
            return "code(" + m.content.reduce("") { (acc, cur) in
                let next: String
                switch cur {
                case .softbreak, .hardbreak: next = " "
                case .text(let t): next = Codec.string(fromTokens: source[t.span])
                default: fatalError()
                }
                return acc + next
            } + ")"

        case .reference(let r):
            let kindDesc = r.kind == .unwrapped ? "uref" : "ref"
            let titleDesc = output(nodes: r.title, source: source, codec: Codec.self)
            return "[\(kindDesc): \(titleDesc)(\(r.definition))]"

        case .hardbreak:
            return "[hardbreak]"

        case .softbreak:
            return "[softbreak]"
        case .escapingBackslash:
            return ""
        }
    }

    static func output <Codec: MarkdownParserCodec> (node: MarkdownBlock, source: View, codec: Codec.Type) -> String
        where Codec.CodeUnit == Token
    {
        switch node {

        case .paragraph(let p):
            return "Paragraph(\(p.text.reduce("", combineNodeOutput(source: source, codec: Codec.self))))"

        case .header(let h):
            return "Header(\(h.level), \(h.text.reduce("", combineNodeOutput(source: source, codec: Codec.self))))"

        case .code(let c):
            if let first = c.text.first {
                return "Code[" + c.text.dropFirst().reduce(Codec.string(fromTokens: source[first])) { acc, cur in
                    return acc + "\n" + Codec.string(fromTokens: source[cur])
                    } + "]"
            } else {
                return "Code[]"
            }

        case .fence(let f):
            let name = Codec.string(fromTokens: source[f.name])
            if let first = f.text.first {
                return "Fence[" + name + "][" + f.text.dropFirst().reduce(Codec.string(fromTokens: source[first])) { acc, cur in
                    return acc + "\n" + Codec.string(fromTokens: source[cur])
                    } + "]"
            } else {
                return "Fence[" + name + "][]"
            }

        case .quote(let q):
            return "Quote { " + q.content.reduce("", combineNodeOutput(source: source, codec: Codec.self)) + "}"

        case .list(let l):
            var itemsDesc = ""
            for item in l.items {
                itemsDesc += "Item { " + item.content.reduce("", combineNodeOutput(source: source, codec: Codec.self)) + "}, "
            }
            return "List[\(l.kind)] { " + itemsDesc + "}"
            
            
        case .thematicBreak:
            return "ThematicBreak"
            
        case .referenceDefinition:
            return ""
        }
    }
}


