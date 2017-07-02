//
//  Task.swift
//  Reminders-Foundation
//
//  Created by Pavel Procházka on 18/01/2017.
//
//

import Vapor
import FluentProvider
import AuthProvider

/// Class holding information about a list of tasks.
final class List: Model, Timestampable {
	
	// MARK: - Properties
	
	/// Allows Fluent to store extra information on model (such as the model's database id)
	let storage = Storage()
	
	/// List title
	var title: String
	
	/// Identifier of a User (parent) it belongs to
	var userId: Identifier
	
	// MARK: - Initializers
	
	init(title: String, userId: Identifier) {
		self.title = title
		self.userId = userId
	}
	
	/// Initializer creating model object from Row (Fluent pulls data from DB into intermediate representation `Row` THEN we need to convert back to type-safe model). See `RowInitializable`
	init(row: Row) throws {
		self.title = try row.get(Identifiers.title)
		self.userId = try row.get(Identifiers.userId)
	}
	
	/// Converts type-safe model into an instance of `Row` object. See `RowRepresentable`
	func makeRow() throws -> Row {
		var row = Row()
		try row.set(Identifiers.title, self.title)
		try row.set(Identifiers.userId, self.userId)
		return row
	}
}

// MARK: - JSONRepresentable protocol

extension List: JSONRepresentable {
	
	/// Converts model into JSON _and_ enriches it with additional values
	public func makeJSON() throws -> JSON {
		var result = JSON()
		do {
			let allTasksCount = try self.tasks.count()
			let completedTasksCount = try self.tasks.filter(Identifiers.isDone, .equals, true).count()
			
			try result.set(Identifiers.id, self.id?.string)
			try result.set(Identifiers.title, self.title)
			try result.set("task_count", allTasksCount)
			try result.set("completed_task_count", completedTasksCount)
			try result.set(Identifiers.userId, self.userId.string)
		} catch {
			try result.set(Identifiers.id, self.id?.string)
			try result.set(Identifiers.title, self.title)
			try result.set(Identifiers.userId, self.userId.string)
		}
		
		return result
	}
}

// MARK: - Preparation protocol

extension List: Preparation {
	
	/// The prepare method should call any methods it needs on the database to prepare.
	public static func prepare(_ database: Database) throws {
		try database.create(self) { tasks in
			tasks.id()
			tasks.string(Identifiers.title)
			tasks.foreignId(for: User.self)
		}
	}
	
	/// The revert method should undo any actions caused by the prepare method.
	public static func revert(_ database: Database) throws {
		try database.delete(self)	// only called when manually executed via CLI
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
	
	/// Relationship convenience method to fetch children entities
	var tasks: Children<List, Task> {
		return children()
	}
}
