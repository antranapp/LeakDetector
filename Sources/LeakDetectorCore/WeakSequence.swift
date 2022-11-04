//
// Copyright © 2021 An Tran. All rights reserved.
//

import Foundation
import Metal

// Taken from: https://gist.github.com/hooman/e103cac5ea929dbeda0b0f6ad8e83b5d

/// A protocol to provide an abstraction of types that hold a weak reference to a target object.
///
/// It is defined because a single generic implementation cannot support existentials, as they
/// do not conform to themselves or `AnyObject`. Most of its API is defined by protocol extensions
/// to makes it easier to create existential wrapper `struct`s or `final class`es.
///
/// Here is an example protocol and the corresponding weak reference
/// container:
///
///     protocol MyDelegateProtocol: AnyObject { func didSomething() }
///
///     struct MyDelegateRef: WeakReference {
///       private(set) weak var ref: MyDelegateProtocol?
///       init(_ reference: MyDelegateProtocol?) { self.ref = reference }
///     }
///
/// That is all that is needed to get the rest of the API.
///
/// This protocol is `ExpressibleByNilLiteral` (implementation provided)
/// to support creating empty or sentinel values that are useful in some
/// situations.
public protocol WeakReference: ExpressibleByNilLiteral {
    
    /// The type of the reference stored by this type.
    ///
    /// It is not constrained to `AnyObject` to support existentials from class-constrained
    /// non-Objective-C protocols.
    associatedtype ReferenceType
    
    /// Returns the reference stored by this type.
    ///
    /// Returns `nil` if the reference is already released (deallocated).
    var ref: ReferenceType? { get }
    
    /// Returns true if the object is released (deallocated).
    ///
    /// Default implementation provided.
    var isGone: Bool { get }
    
    /// Returns true if the object is still available.
    ///
    /// Default implementation provided.
    var isAvailable: Bool { get }
    
    /// Creates a new wrapper from the given optional `reference`.
    ///
    /// - Parameter `reference`: The reference to be weakly held.
    init(_ reference: ReferenceType?)
    
    /// Returns `true` if the wrapper contains the given object.
    ///
    /// Default implementation provided.
    func contains(_ object: Any?) -> Bool
    
    /// A map function that returns another weak reference to help provide a monadish behavior for this type.
    ///
    /// It does not return `Self` to aid in jumping between generic and concrete (existential) containers.
    ///
    /// Default implementation provided.
    ///
    /// - Parameter transform: A function that returns an object
    /// - Returns: A weak reference to the result of applying `transform` to the reference stored in
    /// this type.
    func map<T, W: WeakReference>(_ transform: (ReferenceType) throws -> T?) rethrows -> W where W.ReferenceType == T
}

public extension WeakReference {
    
    var isGone: Bool { ref == nil }
    
    var isAvailable: Bool { ref != nil }
    
    func contains(_ object: Any?) -> Bool {
        guard let ref = ref as AnyObject?, let object = object as AnyObject? else { return false }
        return ref === object
    }
    
    func map<T, W: WeakReference>(_ transform: (ReferenceType) throws -> T?) rethrows -> W where W.ReferenceType == T {
        try W(ref.flatMap(transform))
    }
}

public extension WeakReference /* ExpressibleByNilLiteral */ {
    
    init(nilLiteral: ()) { self.init(nil) }
}

public extension WeakReference /* CustomStringConvertible */ {
    
    var description: String {
        if let ref = ref { return "「\(ref)」" } else { return "「」" }
    }
}

public extension WeakReference /* Identity based equality */ {
    
    /// Identity-bases equality test operator.
    static func == (lhs: Self, rhs: Self) -> Bool {
        if lhs.ref == nil, rhs.ref == nil { return true }
        guard let lhs = lhs.ref, let rhs = rhs.ref else { return false }
        return lhs as AnyObject === rhs as AnyObject
    }
    
    /// Identity-bases inequality test operator.
    static func != (lhs: Self, rhs: Self) -> Bool { !(lhs == rhs) }
}

public extension WeakReference where ReferenceType: Equatable {
    
    /// `Equatable` conditional conformance.
    static func == (lhs: Self, rhs: Self) -> Bool {
        if lhs.ref == nil, rhs.ref == nil { return true }
        guard let lhs = lhs.ref, let rhs = rhs.ref else { return false }
        return lhs == rhs
    }

    /// `Equatable` conditional conformance.
    static func != (lhs: Self, rhs: Self) -> Bool { !(lhs == rhs) }
}

public extension WeakReference where ReferenceType: Hashable {
    
    var hashValue: Int {
        guard let ref = ref else { return Int.min }
        return ref.hashValue
    }
}

/// A generic wrapper type to keep a weak reference to an object.
///
/// This wrapper type is used to keep a weak reference to an object in some other container such as array or dictionary.
/// It could also be defined as a `final class` to reduce the number of copies of the weak reference created to help
/// improve performance with old (pre-Swift 4.0) behavior of the weak references. `final class` can still help with
/// lifetime of side tables, but I don't think this is really going to matter. On the other hand, class has a higher cost
/// in temrs construction, per-instance memory and reference counting.
public struct Weak<Object: AnyObject>: WeakReference {
    public typealias ReferenceType = Object
    public private(set) weak var ref: ReferenceType?
    public init(_ reference: ReferenceType?) { ref = reference }
}

extension Weak: CustomStringConvertible {}

#if swift(>=4.1)
extension Weak: Equatable where Weak.ReferenceType: Equatable {}
extension Weak: Hashable where Weak.ReferenceType: Hashable {}
#endif

/// A sequence of weak pointers to objects.
///
/// Besides `Sequence` operations, this type supports basic mutating operations
/// `add(_:)` and `remove(_:)`.
///
/// It is intended to be used to store a list of weak references to target objects
/// typically to notify them with a `for`-loop. Considering `MyDelegateProtocol`
/// from `WeakReference` documentation, here is an example use of `WeakSequence`:
///
///     typealias MyDelegates = WeakSequence<MyDelegateRef>
///
///     var myDelegates = MyDelegates()
///
///     class SomeClass {}
///
///     extension SomeClass: MyDelegateProtocol { func didSomething() { /* ... */ } }
///
///     let aDelegate = SomeClass()
///     myDelegates.add(aDelegate)
///     for delegate in myDelegates { delegate.didSomething() }
///
public struct WeakSequence<WeakHolder: WeakReference>: Sequence {
    
    public struct Iterator: IteratorProtocol {
        
        private var iterator: Array<WeakHolder>.Iterator
        
        fileprivate init(_ weakSeq: WeakSequence) { iterator = weakSeq.weakElements.makeIterator() }
        
        /// Returns the next available object in the sequence, or `nil` if there are no more objects.
        ///
        /// - Returns: The next available reference in the sequence; or `nil` is there are no more references left.
        public mutating func next() -> Element? {
            repeat {
                guard let nextHolder = iterator.next() else { return nil }
                if let nextRef = nextHolder.ref { return nextRef }
            } while true
        }
    }
    
    /// The `Sequence` element type.
    public typealias Element = WeakHolder.ReferenceType
    
    // Storage for weak references
    private var weakElements: [WeakHolder]
    
    /// Creates a `WeakSequence` from the given sequence of weak reference holders.
    public init<S: Sequence>(_ elements: S) where S.Element == WeakHolder { weakElements = Array(elements) }
    
    /// Creates a `WeakSequence` from the given sequence of weak reference holders.
    public init<S: Sequence>(_ elements: S) where S.Element == WeakHolder.ReferenceType { weakElements = elements.map(WeakHolder.init) }
    
    /// Creates a `WeakSequence` from the given sequence of weak reference holders.
    public init<S: Sequence>(_ elements: S) where S.Element == WeakHolder.ReferenceType? { weakElements = elements.map(WeakHolder.init) }
    
    public func makeIterator() -> Iterator { Iterator(self) }
    
    /// Removes all deallocated objects from the sequence.
    ///
    /// This operation does not have any visible impact on
    /// the sequence behavior as it always returns available
    /// references.
    @discardableResult
    public mutating func compact() -> [WeakHolder.ReferenceType] {
        weakElements = weakElements.filter(\.isAvailable)
        return asArray
    }
    
    public var asArray: [WeakHolder.ReferenceType] {
        Array(self)
    }
    
    /// Adds an object to the sequence in an undefined order.
    ///
    /// - Parameter element: The reference to be added to the sequence.
    /// - Parameter allowDuplicates: If you pass `true`, it will allow duplicates to be added. The default
    /// is `false`. When you are sure it will not be duplicate, passing `true` improves performance.
    /// - Returns: `true` if the `element` was actually added; `false` otherwise.
    @discardableResult
    public mutating func add(_ element: Element?, allowDuplicates: Bool = false) -> Bool {
        guard let element = element else { return false }
        guard allowDuplicates || !contains(element) else { return false }
        if let index = emptyIndex() {
            weakElements[index] = WeakHolder(element)
        } else {
            weakElements.append(WeakHolder(element))
        }
        return true
    }
    
    @discardableResult
    public mutating func insert(_ element: Element?, allowDuplicates: Bool = false) -> Bool {
        add(element, allowDuplicates: allowDuplicates)
    }
    
    public mutating func formUnion<T: AnyObject>(_ other: WeakSequenceOf<T>) {
        var iterator = other.makeIterator()
        while let object = iterator.next() {
            if let object = object as? Element {
                add(object, allowDuplicates: false)
            }
        }
        
    }
    
    /// Removes the given object from the sequence if it is there.
    ///
    /// - Parameter object: The reference to be removed from the sequence.
    /// - Returns: `true` if the `element` was actually removed; `false` otherwise.
    @discardableResult
    public mutating func remove(_ element: Any?) -> Bool {
        guard let element = element, let index = index(of: element) else { return false }
        weakElements[index] = nil
        return true
    }
    
    /// Determines if the sequence contains a given `object`.
    ///
    /// - Parameter object: The reference to look for.
    /// - Returns: `true` if `object` is found; `false` otherwise.
    public func contains(_ element: Any?) -> Bool { index(of: element) != nil }
    
    public mutating func removeAll() {
        weakElements.removeAll()
    }
    
    // Finds the index of the given object; if present.
    private func index(of element: Any?) -> Int? { weakElements.firstIndex(where: { $0.contains(element) }) }
    
    // Finds the first empty index (where the reference is gone)
    private func emptyIndex() -> Int? {
        var index = 0
        let end = weakElements.endIndex
        while index < end, weakElements[index].isAvailable { index += 1 }
        guard index < end else { return nil }
        return index
    }
}

public extension WeakSequence {
    
    /// Creates an empty `WeakSequence`.
    init() { weakElements = [] }
}

extension WeakSequence: ExpressibleByArrayLiteral {
    
    public init(arrayLiteral elements: Element?...) { self.init(elements.map(WeakHolder.init)) }
}

extension WeakSequence: CustomStringConvertible {
    
    public var description: String { Array(self).description }
}

extension WeakSequence: CustomDebugStringConvertible {
    
    public var debugDescription: String { "[\(weakElements.map(\.description).joined())]" }
}

public typealias WeakSequenceOf<T> = WeakSequence<Weak<T>> where T: AnyObject
