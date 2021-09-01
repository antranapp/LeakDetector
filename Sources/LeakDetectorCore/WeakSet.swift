//
// Copyright © 2021 An Tran. All rights reserved.
//

import Foundation

/// Set of weakly referenced objects.
/// - warning: Element must conform to `AnyObject`.
public struct WeakSet<Element>: ExpressibleByArrayLiteral, CustomDebugStringConvertible {

    private typealias Key = AnyObject
    private typealias Value = AnyObject

    /// Returns an array with a strong reference to elements.
    public var asArray: [Element] {
        storage.dictionaryRepresentation().values.compactMap { $0 as? Element }
    }

    public var isEmpty: Bool {
        count == 0
    }

    /// The number of elements in the set.
    public var count: Int {
        asArray.count
    }

    private var storage: NSMapTable<Key, Value> = .strongToWeakObjects()

    public init(arrayLiteral elements: Element...) {
        for element in elements {
            insertToStorage(object: element)
        }
    }

    public init<S: Sequence>(_ elements: S) where S.Element == Element {
        for element in elements {
            insertToStorage(object: element)
        }
    }

    /// `True` if element is contained in the set.
    /// - parameter element: `Element` to compare.
    /// - parameter element: Returns
    public func contains(_ element: Element) -> Bool {
        storage.object(forKey: keyForElement(element)) != nil
    }

    public mutating func formUnion<T>(_ other: WeakSet<T>) {
        objc_sync_enter(storage); defer { objc_sync_exit(storage) }
        if !isKnownUniquelyReferenced(&storage) {
            storage = storageCopy()
        }

        let enumerator = other.storage.objectEnumerator()
        while let object = enumerator?.nextObject() {
            if let object = object as? Element {
                insertToStorage(object: object)
            }
        }
    }

    public mutating func insert(_ element: Element) {
        objc_sync_enter(storage); defer { objc_sync_exit(storage) }
        if !isKnownUniquelyReferenced(&storage) {
            storage = storageCopy()
        }
        insertToStorage(object: element)
    }

    private func insertToStorage(object: Element) {
        storage.setObject(object as Value, forKey: keyForElement(object))
    }

    public mutating func removeAll() {
        objc_sync_enter(storage); defer { objc_sync_exit(storage) }
        storage = .strongToWeakObjects()
    }

    public mutating func remove(_ element: Element) {
        objc_sync_enter(storage); defer { objc_sync_exit(storage) }
        if !isKnownUniquelyReferenced(&storage) {
            storage = storageCopy()
        }
        storage.removeObject(forKey: keyForElement(element))
    }

    private func keyForElement(_ element: Element) -> Key {
        NSNumber(value: ObjectIdentifier(element as AnyObject).hashValue)
    }

    private func storageCopy() -> NSMapTable<Key, Value> {
        storage.copy() as? NSMapTable<Key, Value> ?? .strongToWeakObjects()
    }

    public var debugDescription: String {
        var description = "["
        var nextSpacer = ""
        let enumerator = storage.objectEnumerator()
        while let object = enumerator?.nextObject() {
            description += nextSpacer + memoryAddressDescription(for: object as AnyObject)
            nextSpacer = ", "
        }
        return description + "]"
    }
}

public func memoryAddress(for object: AnyObject) -> String {
    String(format: "%018p", unsafeBitCast(object, to: Int.self))
}

public func memoryAddressDescription(for object: AnyObject) -> String {
    if object is NSObject {
        return "\(object)"
    } else {
        return "<\(object): \(memoryAddress(for: object))>"
    }
}
