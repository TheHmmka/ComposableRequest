//
//  Reference.swift
//  ComposableRequest
//
//  Created by Stefano Bertagno on 23/02/21.
//

import Foundation

/// A `class` defining a reference-typed rapper
/// for some value.
public final class Reference<Value> {
    /// The underlying value.
    public var value: Value

    /// Init.
    ///
    /// - parameter value: A valid `Value`.
    public init(_ value: Value) {
        self.value = value
    }
}

/// A `class` defining an atomic reference to some value.
final class Atomic<Value> {
    /// The underlying serial queue.
    private let queue = DispatchQueue(label: "com.sbertix.swiftagram.\(UUID().uuidString)")
    /// The underlying value.
    private var _value: Value

    /// Init.
    ///
    /// - parameter value: A valid `Value`.
    public init(_ value: Value) {
        self._value = value
    }

    /// The underlying value.
    public var value: Value {
        queue.sync { self._value }
    }

    /// Sync the underlying value.
    ///
    /// - parameter transform: A valid transformation.
    func sync<T>(_ transform: (inout Value) -> T) -> T {
        queue.sync { transform(&self._value) }
    }

    /// Mutate the undelrying value.
    ///
    /// - parameter transform: A valid transformation.
    func mutate(_ transform: (inout Value) -> Void) {
        sync(transform)
    }
}
