//
//  List.swift
//  App
//
//  Created by Prochazka, Pavel on 23/11/2018.
//

import Vapor
import FluentPostgreSQL

struct List: PostgreSQLModel {
    
    // MARK: - Properties
    
    /// Model's unique identifier enforced by `PostgreSQLModel`
    var id: Int?
    
    /// Task title
    var title: String
}

/// Allows `List` to be used as a dynamic migration.
extension List: Migration { }

/// Allows `List` to be encoded to and decoded from HTTP messages.
extension List: Content { }

/// Allows `List` to be used as a dynamic parameter in route definitions.
extension List: Parameter { }

extension List {
    
    /// Patches `List` with an instance of `List.Incoming`
    func patched(with incoming: Incoming) -> List {
        return List(id: id, title: incoming.title)
    }
    
    var tasks: Children<List, Task> {
        return children(\.listId)
    }
}

/// MARK: - Incoming struct
extension List {
    
    // All are optional, as we can use PATCH request in the future
    struct Incoming: Content {
        var title: String
        
        // Factory to create empty incoming List
        func makeList() -> List {
            return List(id: nil, title: title)
        }
    }
}
