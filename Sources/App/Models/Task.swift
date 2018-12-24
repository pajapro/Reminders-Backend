//
//  Task.swift
//  App
//
//  Created by Prochazka, Pavel on 10/10/2018.
//

import Vapor
import FluentPostgreSQL

/// Enum defining priority.
enum Priority: String, PostgreSQLRawEnum {
    case low, medium, high, none
}

struct Task: PostgreSQLModel {
    
    // MARK: - Properties
    
    /// Model's unique identifier enforced by `PostgreSQLModel`
    var id: Int?
    
    /// Task title
    var title: String
    
    /// Task priority
    var priority: Priority
    
    /// Reminder date (optional)
    var dueDate: Date?
    
    /// Task done state
    var isDone: Bool
    
    /// Identifier of a List (parent) it belongs to
    var listId: Int
}

/// Allows `Task` to be used as a dynamic migration.
extension Task: Migration { }

/// Allows `Task` to be encoded to and decoded from HTTP messages.
extension Task: Content { }

/// Allows `Task` to be used as a dynamic parameter in route definitions.
extension Task: Parameter { }

extension Task {
    
    /// Patches `Task` with an instance of `Task.Incoming`
    func patched(with incoming: Incoming) -> Task {
        return Task(id: id, title: incoming.title, priority: incoming.priority ?? priority, dueDate: incoming.dueDate ?? dueDate, isDone: incoming.isDone ?? isDone, listId: incoming.listId ?? listId)
    }
    
    var list: Parent<Task, List> {
        return parent(\.listId)
    }
}

/// MARK: - Incoming struct
extension Task {
    
    // All are optional, as we can use PATCH request in the future
    struct Incoming: Content {
        var title: String
        var priority: Priority?
        var dueDate: Date?
        var isDone: Bool?
        var listId: Int
        
        // Factory to create empty incoming Task
        func makeTask() -> Task {
            return Task(id: nil, title: title, priority: priority ?? .none, dueDate: dueDate ?? nil, isDone: isDone ?? false, listId: listId)
        }
    }
}
