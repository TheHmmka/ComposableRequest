//
//  Receivable.swift
//  ComposableRequest
//
//  Created by Stefano Bertagno on 19/08/21.
//

#if canImport(Combine)
import Combine
#endif
import Foundation

/// A `protocol` defining an instance returned by a `Requester`.
public protocol Receivable {
    /// The associated success type.
    associatedtype Success
}

public extension Receivable {
    #if canImport(Combine)
    /// Decode the underlying data.
    ///
    /// - parameters:
    ///     - type: A concrete implementation of `TopLevelDecoder`.
    ///     - decoder: A valid `Decoder`.
    /// - returns: Some `Receivable`.
    @available(iOS 13, macOS 10.15, tvOS 13, watchOS 6, *)
    func decode<O: Decodable, D: TopLevelDecoder>(type: O.Type, decoder: D) -> Receivables.FlatMap<Self, O> where D.Input == Success {
        tryMap { try decoder.decode(type, from: $0) }
    }
    #endif

    /// Flat map the current success.
    ///
    /// - parameter mapper: A valid mapper.
    /// - returns: Some `Receivable`.
    func flatMap<S>(_ mapper: @escaping (Success) -> Result<S, Error>) -> Receivables.FlatMap<Self, S> {
        .init(parent: self, mapper: mapper)
    }

    /// Flat map the current error.
    ///
    /// - parameter mapper: A valid mapper.
    /// - returns: Some `Receivable`.
    func flatMapError(_ mapper: @escaping (Error) -> Result<Success, Error>) -> Receivables.FlatMapError<Self> {
        .init(parent: self, mapper: mapper)
    }

    /// Map the current success.
    ///
    /// - parameter mapper: A valid mapper.
    /// - returns: Some `Receivable`.
    func map<S>(_ mapper: @escaping (Success) -> S) -> Receivables.Map<Self, S> {
        .init(parent: self, mapper: mapper)
    }

    /// Map the current error.
    ///
    /// - parameter mapper: A valid mapper.
    /// - returns: Some `Receivable`.
    func mapError(_ mapper: @escaping (Error) -> Error) -> Receivables.MapError<Self> {
        .init(parent: self, mapper: mapper)
    }

    /// Print the current state.
    ///
    /// - returns: Some `Receivable`.
    func print() -> Receivables.Print<Self> {
        .init(parent: self)
    }

    /// Type-erase the current receivable.
    ///
    /// - parameter requester: A concrete implementation of `Requester`.
    /// - returns: Some `Receivable`.
    func requested<R: Requester>(by requester: R) -> Receivables.Requested<R, Success> {
        .init(reference: self)
    }

    /// Switch to a new receivable.
    ///
    /// - parameter generator: A valid child generator.
    /// - returns: Some `Receivable`.
    func `switch`<C: Receivable>(to generator: @escaping (Success) throws -> C) -> Receivables.Switch<Self, C> {
        .init(parent: self, generator: generator)
    }

    /// Try mapping the current success.
    ///
    /// - parameter mapper:A valid mapper.
    /// - returns: Some `Receivable`.
    func tryMap<S>(_ mapper: @escaping (Success) throws -> S) -> Receivables.FlatMap<Self, S> {
        flatMap { success in .init { try mapper(success) } }
    }
}

public extension Receivable where Success == Data {
    /// Decode into a wrapper.
    ///
    /// - returns: Some `Receivable`.
    func decode() -> Receivables.FlatMap<Self, Wrapper> {
        tryMap(Wrapper.decode)
    }
}

#if canImport(Combine)
@available(iOS 13, macOS 10.15, tvOS 13, watchOS 6, *)
public extension Receivable where Success: Encodable {
    /// Encode the underlying value.
    ///
    /// - parameter encoder: A concrete implementation of `TopLeverEncoder`.
    /// - returns: Some `Receivable`.
    func encode<E: TopLevelEncoder>(encoder: E) -> Receivables.FlatMap<Self, E.Output> {
        tryMap(encoder.encode)
    }
}
#endif