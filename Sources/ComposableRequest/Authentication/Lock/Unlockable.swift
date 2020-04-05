//
//  Unlockable.swift
//  ComposableRequest
//
//  Created by Stefano Bertagno on 02/04/2020.
//

import Foundation

/// A `protocol` defining a `Locked` item in need of authentication.
public protocol Unlockable {
    /// The `Locked` type.
    associatedtype Locked: Lockable

    /// Authenticate with a `Secret`.
    /// - parameter secret: A valid `Secret`.
    /// - returns: An authenticated `Locked`.
    func authenticating(with secret: Secret) -> Locked
}

/// A `protocol` defining an `Unlockable` item allowing for direct initialization.
public protocol CustomUnlockable: Unlockable {
    /// Init.
    /// - parameter request: A valid instance of `Locked`.
    init(request: Locked)
}
