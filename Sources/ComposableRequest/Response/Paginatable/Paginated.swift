//
//  Paginated.swift
//  ComposableRequest
//
//  Created by Stefano Bertagno on 14/03/2020.
//

import Foundation

/// A `struct` for changing expected `Paginatable`s.
public struct Paginated<Request: Expecting, Response: DataMappable>: Paginatable {
    /// The `Expecting` value.
    public var expecting: Request
    /// The `name` of the `URLQueryItem` used for paginating.
    public var key: String
    /// The inital `value` of the `URLQueryItem` used for paginating.
    public var initial: String?
    /// The next `value` of the `URLQueryItem` user for paginating, based on the last `Response`.
    public var next: (Result<Response, Error>) -> String?
}

// MARK: Composable
extension Paginated: Composable where Request: Composable { }
extension Paginated: WrappedComposable where Request: Composable {
    /// A valid `Composable`.
    public var composable: Request {
        get { return expecting }
        set { expecting = newValue }
    }
}

// MARK: Requestable
extension Paginated: Requestable where Request: Requestable {
    /// Compute the `URLRequest`.
    /// - returns: An optional `URLRequest`.
    public func request() -> URLRequest? { return expecting.request() }
}

// MARK: Lockable
extension Paginated: Lockable where Request: Lockable {
    /// Update `self` according to the authentication `Secret`.
    /// - parameters:
    ///     - request: An instance of `Self`.
    ///     - secret: A valid `Secret`.
    /// - warning: Do not call directly.
    public static func authenticating(_ request: Paginated, with secret: Secret) -> Paginated {
        return copy(request) { $0.expecting = Request.authenticating($0.expecting, with: secret) }
    }
}

// MARK: Unlockable
extension Paginated: Unlockable where Request: Unlockable, Request.Locked: Expecting {
    /// Authenticate with a `Secret`.
    /// - parameter secret: A valid `Secret`.
    /// - returns: An authenticated `Request`.
    public func authenticating(with secret: Secret) -> Paginated<Request.Locked, Response> {
        return .init(expecting: expecting.authenticating(with: secret),
                     key: key,
                     initial: initial,
                     next: next)
    }
}
