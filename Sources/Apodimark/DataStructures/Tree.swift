
/// The level of a node in the tree
struct DepthLevel {
    fileprivate var _level: Int
    
    static var root: DepthLevel {
        return .init(0)
    }
    
    private init(_ level: Int) {
        self._level = level
    }
    
    func incremented() -> DepthLevel {
        return .init(_level+1)
    }
    
    func decremented() -> DepthLevel {
        return .init(_level-1)
    }
}

fileprivate struct TreeNode <T> {
    let data: T
    var end: Int
    
    init(data: T, end: Tree<T>.Buffer.Index) {
        (self.data, self.end) = (data, end)
    }
}


/**
 An efficient append-depth-first-only tree.
 
 New elements can only be added to the last child of a node.
 In practice, this means that only the *last strand*
 (path connecting the root to the last leaf) can be modified.
 
 ## Example

 ```
                       (root)   | DepthLevel
                         |      |----
                     a - b      |  0
                         |      |----
     c - f ------------- h      |  1
     |   |               |      |----
 d - e   g   i ----- j - n      |  2
                     |   |      |----
             k - l - m   o      |  3
                                |----
                                |  4
 ```
 The *last strand* here is
 ```
 b-h-n-o
 ```
 And the *last leaf* is `o`.

 A pre-order traversal of the tree would give:
 ```
 a-b-c-d-e-f-g-h-i-j-k-l-m-n-o
 ```
 This is always the order by which the nodes are added to the tree.
 
 The next node, `p`, can only be added to nodes in the
 last strand.
 
 You specify the location of the new node by passing the
 appropriate *depth level* as argument. Let’s add `p` to
 the `root`.
 
 ```swift
 tree.append(p, depthLevel: DepthLevel.root)
 // DepthLevel.root corresponds to level 0
 // p will be added to the root’s children
 ```
 ```
                           (root)   | DepthLevel
                             |      |----
                     a - b - p      |  0
                         |          |----
     c - f ------------- h          |  1
     |   |               |
 d - e   g   i ----- j - n
                     |   |
             k - l - m   o
 
 ```

 ## Operations
 
 Appending a new node to the tree is *Θ(d)* where
 *d* is the length of the last strand.
 
 Accessing a node in the last strand is *Θ(1)*.
 
 Accessing the last leaf is *Θ(1)*.
 
 The tree can be traversed in pre-order or breadth-first
 in *Θ(n)* with *n* the total number of nodes.
 Note, however, that a pre-order traversal is faster 
 because it is essentially a simple array traversal.
 
 ## Misc.
 
 `Tree` does not have value semantics.
 */
final class Tree <T> {
    
    fileprivate typealias Buffer = ContiguousArray<TreeNode<T>>
    
    /// The underlying storage for the tree nodes.
    fileprivate var buffer: Buffer
    
    /// The indices of the nodes in the last strand
    fileprivate var lastStrand: [Buffer.Index]
    
    /// The last leaf of the tree
    var lastLeaf: T {
        return buffer[buffer.endIndex-1].data
    }
    
    /// Creates an empty tree
    init() {
        (self.buffer, self.lastStrand) = ([], [])
    }
    
    
    /// Access a node in the last strand.
    ///
    /// - parameter depthLevel: the depth level of the node to access
    ///
    /// - returns: the node in the last strand at level `depthLevel`, 
    ///            or `nil` if `depthLevel` was invalid.
    func last(depthLevel: DepthLevel) -> T? {
        guard lastStrand.indices.contains(depthLevel._level) else { return nil }
        return buffer[lastStrand[depthLevel._level]].data
    }
    
    
    /// Appends a node to the tree.
    ///
    /// - parameter data:  the data in the new node
    /// - parameter level: the level of the new node
    func append(_ data: T, depthLevel level: DepthLevel) {
        buffer.append(TreeNode(data: data, end: buffer.endIndex-1))
        repairStructure(addedStrandLength: 1, level: level)
    }

    
    /// After a serie of direct appends to the underlying `buffer`,
    /// call this method to repair the structure of the tree. Failure to do
    /// so will lead to an inconsistent state.
    /// - parameter addedStrandLength: the number of nodes added to `buffer`
    /// - parameter level:             the level of the first node added to `buffer`
    fileprivate func repairStructure(addedStrandLength: Int, level: DepthLevel) {
        lastStrand.removeSubrange(level._level ..< lastStrand.endIndex)
        lastStrand.append(contentsOf: (buffer.endIndex - addedStrandLength) ..< buffer.endIndex)
        
        for i in lastStrand {
            buffer[i].end += addedStrandLength
        }
    }
    
    /// - returns: an iterator for traversing the tree in pre-order.
    func makePreOrderIterator() ->  UnfoldSequence<T, Int> {
        return sequence(state: buffer.startIndex) { (idx: inout Int) -> T? in
            defer { idx += 1 }
            return idx < self.buffer.endIndex ? self.buffer[idx].data : nil
        }
    }
    
    /// - returns: an iterator for traversing the tree breadth-first
    func makeBreadthFirstIterator() -> TreeBreadthFirstIterator<T> {
        return .init(self)
    }
}


/**
 A breadth-first iterator for a `Tree`.
 
 The elements generated by the iterator are:
 1. The data in the node being visited
 2. An optional breadth-first iterator for the node’s children
 */
struct TreeBreadthFirstIterator <T>: IteratorProtocol, Sequence {
    
    private typealias Buffer = Tree<T>.Buffer
    
    /// The tree being traversed
    private let tree: Tree<T>
    
    /// The index past the last node of the level being visited
    private let endIndex: Buffer.Index
    
    /// The index of the next node
    private var index: Buffer.Index
    
    fileprivate init(_ tree: Tree<T>) {
        (self.tree, self.endIndex) = (tree, tree.buffer.endIndex)
        self.index = 0
    }

    /// Creates an iterator for the subtree defined by the arguments
    ///
    /// - parameter tree:       the tree to traverse
    /// - parameter startIndex: the index of the first node to visit
    /// - parameter endIndex:   the index past the last node to visit
    private init(_ tree: Tree<T>, startIndex: Buffer.Index, endIndex: Buffer.Index) {
        (self.tree, self.endIndex) = (tree, endIndex)
        self.index = startIndex
    }

    mutating func next() -> (T, TreeBreadthFirstIterator?)? {
        
        guard index < endIndex else {
            return nil
        }
        
        let node = tree.buffer[index]
        
        defer {
            index = node.end+1
        }
        
        return (node.data, diving())
    }
    
    /// - returns: an iterator for the children of the next node
    private func diving() -> TreeBreadthFirstIterator? {
        assert(index < tree.buffer.endIndex)

        let end = tree.buffer[index].end
        
        guard index.distance(to: end) > 0 else {
            return nil
        }
        
        return .some(.init(tree, startIndex: index+1, endIndex: end+1))
    }
    
    /// - returns: a copy of `self`
    func makeIterator() -> TreeBreadthFirstIterator {
        return self
    }
}



// This should be an extension of Tree<MarkdownParser.Block> but Swift isn’t ready for this
extension MarkdownParser {
    
    private func appendStrand(line: Line, previousEnd: Tree<Block>.Buffer.Index) {
        
        func append(_ block: Block) {
            blockTree.buffer.append(.init(data: block, end: previousEnd))
        }
        
        guard line.indent.level < TAB_INDENT else {
            var newLine = line
            newLine.indent.level -= TAB_INDENT
            restoreIndentInLine(&newLine)
            append(.code(.init(text: [newLine.indices], trailingEmptyLines: [])))
            return
        }
        
        switch line.kind {
        case .quote(let rest):
            append(.quote(.init(firstMarker: line.indices.lowerBound)))
            appendStrand(line: rest, previousEnd: previousEnd)
            
        case .text:
            append(.paragraph(.init(text: [line.indices])))
            
        case .header(let text, let level):
            let startHashes = line.indices.lowerBound ..< view.index(line.indices.lowerBound, offsetBy: numericCast(level))
            let endHashes: Range<View.Index>? = {
                let tmp = text.upperBound ..< line.indices.upperBound
                return tmp.isEmpty ? nil : tmp
            }()
            append(.header(.init(markers: (startHashes, endHashes), text: text, level: level)))
            
        case let .list(kind, rest):
            let state: ListState = rest.kind.isEmpty() ? .followedByEmptyLine : .normal
            
            let markerSpan = line.indices.lowerBound ..< view.index(line.indices.lowerBound, offsetBy: numericCast(kind.width))
            
            let list = ListNode<View>(kind: kind, state: state)
            let item = ListItemNode<View>(markerSpan: markerSpan)
            
            append(.list(list))
            append(.listItem(item))
            
            list.minimumIndent = line.indent.level + kind.width + rest.indent.level + 1
            
            guard !rest.kind.isEmpty() else {
                return
            }
            
            let nextNodeIdx = blockTree.buffer.endIndex
            appendStrand(line: rest, previousEnd: previousEnd)
            
            if case .code = blockTree.buffer[nextNodeIdx].data {
                list.minimumIndent = line.indent.level + kind.width + 1
            }
            
        case let .fence(kind, name, level):
            let startMarker = line.indices.lowerBound ..< view.index(line.indices.lowerBound, offsetBy: numericCast(level))
            append(.fence(.init(kind: kind, startMarker: startMarker, name: name, text: [], level: level, indent: line.indent.level)))
            
        case .thematicBreak:
            append(.thematicBreak(.init(span: line.indices)))
            
        case .empty:
            append(.paragraph(.init(text: [])))
            
        case let .reference(title, definition):
            append(.referenceDefinition(.init(title: title, definition: definition)))
        }
    }
    
    func appendStrand(from line: Line, level: DepthLevel) {
        let prevCount = blockTree.buffer.count
        appendStrand(line: line, previousEnd: prevCount-1)
        let curCount = blockTree.buffer.count
        blockTree.repairStructure(addedStrandLength: prevCount.distance(to: curCount), level: level)
    }
}

