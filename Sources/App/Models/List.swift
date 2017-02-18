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

/// Struct holding information about a list of tasks.
public struct List: Model {
	
	// MARK: - Properties
	
	/// List entity name
	fileprivate let entity = "lists"
	
	/// Contains the identifier when the model is fetched from the database. If it is `nil`, it **will be set when the model is saved**.
	public var id: Node?
	
	/// List title
	public var title: String
	
	// MARK: - Initializers
	
	public init(title: String) {
		self.id = nil
		self.title = title
	}
}

// MARK: - NodeInitializable protocol (how to initialize our model FROM the database)

extension List: NodeInitializable {
	
	/// Initializer creating model object from Node (Fluent pulls data from DB into intermediate representation `Node` THEN we need to convert back to type-safe model)
	public init(node: Node, in context: Context) throws {
		self.id = try node.extract(Identifiers.id)
		self.title = try node.extract(Identifiers.title)
	}
}

// MARK: - NodeRepresentable protocol (how to save our model TO the database)

extension List: NodeRepresentable {
	
	/// Converts type-safe model into an instance of `Node` object
	public func makeNode(context: Context) throws -> Node {
		let node = try Node(node: [
				Identifiers.id: self.id,
				Identifiers.title: self.title
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
			let tasks = try self.tasks()
			result = try JSON(node: [
				Identifiers.id: self.id,
				Identifiers.title: self.title,
				"task_count": tasks.all().count,
				"remaining_task_count": tasks.filter(Identifiers.isDone, .equals, false).count()
			])
		} catch {
			result = try JSON(node: [
				Identifiers.id: self.id,
				Identifiers.title: self.title
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
		}
	}
	
	/// The revert method should undo any actions caused by the prepare method.
	public static func revert(_ database: Database) throws {
		try database.delete(self.entity)	// only called when manually executed via CLI
	}
}

// MARK: - Convenience method to fetch associated tasks

extension List {
	
	func tasks() throws -> Children<Task> {
		return children(nil, Task.self)
	}
}
