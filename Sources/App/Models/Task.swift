//
//  Task.swift
//  Reminders-Foundation
//
//  Created by Pavel Procházka on 18/01/2017.
//
//

import Vapor
import FluentProvider
import Foundation

/// Enum defining priority.
public enum Priority: String {
	case low	= "low"
	case medium = "medium"
	case high	= "high"
	case none	= "none"
	
	static func priority(from string: String?) -> Priority? {
		guard let unwrappedString = string else { return nil }
		
		return Priority(rawValue: unwrappedString)
	}
}

/// Class holding information about a task.
final class Task: Model, Timestampable {
	
	// MARK: - Properties

	/// Allows Fluent to store extra information on model (such as the model's database id)
	let storage = Storage()
	
	/// Task title
	var title: String
	
	/// Task priority
	var priority: Priority
	
	/// Reminder date
	var dueDate: Date?
	
	/// Task done state
	var isDone: Bool = false
	
	/// Identifier of a List (parent) it belongs to
	var listId: Identifier
	
	// MARK: Computed properties
	
	/// Computes the remaining time from now until due date
	public var remainingTime: DateComponents? {
		guard let unwrappedDueDate = self.dueDate else { return nil }
		
		return Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: Date(), to: unwrappedDueDate)
	}
	
	// MARK: - Initializers
	
	public init(title: String, priority: Priority, dueDate: Date? = nil, listId: Identifier) {
		self.title = title
		self.priority = priority
		self.dueDate = dueDate
		self.listId = listId
	}
	
	/// Initializer creating model object from Row (Fluent pulls data from DB into intermediate representation `Row` THEN we need to convert back to type-safe model). See `RowInitializable`
	init(row: Row) throws {
		self.title = try row.get(Identifiers.title)
		self.priority = try row.get(Identifiers.priority, transform: Priority.priority) ?? .none
		self.dueDate = try row.get(Identifiers.dueDate, transform: Date.date)
		self.isDone = try row.get(Identifiers.isDone)
		self.listId = try row.get(Identifiers.listId)
	}
	
	/// Converts type-safe model into an instance of `Row` object. See `RowRepresentable`
	func makeRow() throws -> Row {
		var row = Row()
		try row.set(Identifiers.title, self.title)
		try row.set(Identifiers.priority, self.priority.rawValue)
		try row.set(Identifiers.dueDate, self.dueDate?.timeIntervalSince1970)
		try row.set(Identifiers.isDone, self.isDone)
		try row.set(Identifiers.listId, self.listId)
		return row
	}
}

// MARK: - JSONRepresentable protocol

extension Task: JSONRepresentable {
	
	/// Converts model into JSON _and_ enriches it with additional values
	public func makeJSON() throws -> JSON {
		var json = JSON()
		if let unwrappedDueDate = self.dueDate {
			try json.set(Identifiers.id, self.id?.string)
			try json.set(Identifiers.title, self.title)
			try json.set(Identifiers.priority, self.priority.rawValue)
			try json.set(Identifiers.dueDate, DateFormatter.configuredDateFormatter().string(from: unwrappedDueDate))
			try json.set(Identifiers.createdAt, DateFormatter.configuredDateFormatter().string(from: self.createdAt!))
			try json.set(Identifiers.isDone, self.isDone)
			try json.set(Identifiers.listId, self.listId.string)
		} else {
			try json.set(Identifiers.id, self.id?.string)
			try json.set(Identifiers.title, self.title)
			try json.set(Identifiers.priority, self.priority.rawValue)
			try json.set(Identifiers.createdAt, DateFormatter.configuredDateFormatter().string(from: self.createdAt!))
			try json.set(Identifiers.isDone, self.isDone)
			try json.set(Identifiers.listId, self.listId.string)
		}
		
		return json
	}
}

// MARK: - Preparation protocol

extension Task: Preparation {

	/// The prepare method should call any methods it needs on the database to prepare.
	public static func prepare(_ database: Database) throws {
		try database.create(self) { tasks in
			tasks.id()
			tasks.string(Identifiers.title)
			tasks.string(Identifiers.priority)
			tasks.double(Identifiers.dueDate, optional: true)
			tasks.bool(Identifiers.isDone)
			tasks.foreignId(for: List.self)
		}
	}

	/// The revert method should undo any actions caused by the prepare method.
	public static func revert(_ database: Database) throws {
		try database.delete(self)	// only called when manually executed via CLI
	}
}

// MARK: - Convenience methods

extension Task {

	/// Relationship convenience method to fetch a parent entity
	var list: Parent<Task, List> {
		return parent(id: self.listId)
	}
}
