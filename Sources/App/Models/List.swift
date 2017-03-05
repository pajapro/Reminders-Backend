//
//  Task.swift
//  Reminders-Foundation
//
//  Created by Pavel Procházka on 18/01/2017.
//
//

import Foundation
import Vapor
import Fluent
import Auth

/// Struct holding information about a list of tasks.
public struct List: Model {
	
	// MARK: - Properties
	
	/// List entity name
	fileprivate let entity = "lists"
	
	/// Contains the identifier when the model is fetched from the database. If it is `nil`, it **will be set when the model is saved**.
	public var id: Node?
	
	/// List title
	public var title: String
	
	/// Identifier of a User (parent) it belongs to
	public var userId: Node?
	
	// MARK: - Initializers
	
	public init(title: String, userId: Node? = nil) {
		self.id = nil
		self.title = title
		self.userId = userId
	}
}

// MARK: - NodeInitializable protocol (how to initialize our model FROM the database)

extension List: NodeInitializable {
	
	/// Initializer creating model object from Node (Fluent pulls data from DB into intermediate representation `Node` THEN we need to convert back to type-safe model)
	public init(node: Node, in context: Context) throws {
		self.id = try node.extract(Identifiers.id)
		self.title = try node.extract(Identifiers.title)
		self.userId = try node.extract(Identifiers.userId)
	}
}

// MARK: - NodeRepresentable protocol (how to save our model TO the database)

extension List: NodeRepresentable {
	
	/// Converts type-safe model into an instance of `Node` object
	public func makeNode(context: Context) throws -> Node {
		let node = try Node(node: [
				Identifiers.id: self.id,
				Identifiers.title: self.title,
				Identifiers.userId: self.userId
			])
		
		return node
	}
}

// MARK: - JSONRepresentable protocol

extension List: JSONRepresentable {
	
	/// Converts model into JSON _and_ enriches it with additional values
	public func makeJSON() throws -> JSON {
		var result: JSON
		do {
			let allTasksCount = try self.tasks().count()
			let completedTasksCount = try self.tasks().filter(Identifiers.isDone, .equals, true).count()
			
			result = try JSON(node: [
				Identifiers.id: self.id,
				Identifiers.title: self.title,
				"task_count": allTasksCount,
				"completed_task_count": completedTasksCount,
				Identifiers.userId: self.userId
			])
		} catch {
			result = try JSON(node: [
				Identifiers.id: self.id,
				Identifiers.title: self.title,
				Identifiers.userId: self.userId
			])
		}
		
		return result
	}
}

// MARK: - Preparation protocol

extension List: Preparation {
	
	/// The prepare method should call any methods it needs on the database to prepare.
	public static func prepare(_ database: Database) throws {
		try database.create(self.entity) { tasks in
			tasks.id()
			tasks.string(Identifiers.title)
			tasks.parent(User.self, optional: false)
		}
	}
	
	/// The revert method should undo any actions caused by the prepare method.
	public static func revert(_ database: Database) throws {
		try database.delete(self.entity)	// only called when manually executed via CLI
	}
}

// MARK: - Equatable protocol

extension List: Equatable {
	
	public static func ==(lhs: List, rhs: List) -> Bool {
		return lhs.id == rhs.id
	}
}

// MARK: - Convenience methods

extension List {
	
	static func lists(for user: Auth.User) throws -> Fluent.Query<List> {
		return try List.query().filter(Identifiers.userId, user.uniqueID)
	}
	
	static func list(for user: Auth.User, with listId: Int) throws -> List? {
		return try List.lists(for: user).filter(Identifiers.id, listId).first()
	}
	
	/// Relationship convenience method to fetch children entities
	func tasks() throws -> Children<Task> {
		return children()
	}
}
