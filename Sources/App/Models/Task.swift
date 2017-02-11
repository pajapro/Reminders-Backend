//
//  Task.swift
//  TODO-Foundation
//
//  Created by Pavel Procházka on 18/01/2017.
//
//

import Foundation
import Vapor
import Fluent

/// Enum defining priority.
public enum Priority: String {
	case low	= "low"
	case medium = "medium"
	case high	= "high"
	
	static func priority(from string: String?) -> Priority? {
		guard let unwrappedString = string else { return nil }
		
		return Priority(rawValue: unwrappedString)
	}
}

/// Struct holding information about a task.
public struct Task: Model {
	
	// MARK: - Properties
	
	/// Task entity name
	fileprivate let entity = "tasks"
	
	/// Contains the identifier when the model is fetched from the database. If it is `nil`, it **will be set when the model is saved**.
	public var id: Node?
	
	/// Task title
	public var title: String
	
	/// Task priority
	public var priority: Priority
	
	/// Reminder date
	public var dueDate: Date?
	
	/// Generated date of task creation
	public var creationDate: Date = Date()
	
	/// Task done state
	public var isDone: Bool = false
	
	// MARK: Computed properties
	
	/// Computes the remaining time from now until due date
	public var remainingTime: DateComponents? {
		guard let unwrappedDueDate = self.dueDate else { return nil }
		
		return Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: Date(), to: unwrappedDueDate)
	}
	
	// MARK: - Initializers
	
	public init(title: String, priority: Priority, dueDate: Date? = nil) {
		self.id = nil
		self.title = title
		self.priority = priority
		self.dueDate = dueDate
	}
}

// MARK: - NodeInitializable protocol (how to initialize our model FROM the database)

extension Task: NodeInitializable {
	
	/// Initializer creating model object from Node (Fluent pulls data from DB into intermediate representation `Node` THEN we need to convert back to type-safe model)
	public init(node: Node, in context: Context) throws {
		self.id = try node.extract(Identifiers.id)
		self.title = try node.extract(Identifiers.title)
		self.priority = try node.extract(Identifiers.priority, transform: Priority.priority) ?? .medium
		self.dueDate = try node.extract(Identifiers.dueDate, transform: Date.date)
		self.creationDate = try node.extract(Identifiers.creationDate, transform: Date.date)
		self.isDone = try node.extract(Identifiers.isDone)
	}
}

// MARK: - NodeRepresentable protocol (how to save our model TO the database)

extension Task: NodeRepresentable {
	
	/// Converts type-safe model into an instance of `Node` object
	public func makeNode(context: Context) throws -> Node {
		var node: Node
		if let unwrappedDueDate = self.dueDate {
			node = try Node(node: [
				Identifiers.id: self.id,
				Identifiers.title: self.title,
				Identifiers.priority: self.priority.rawValue,
				Identifiers.dueDate: unwrappedDueDate.timeIntervalSince1970,
				Identifiers.creationDate: self.creationDate.timeIntervalSince1970,
				Identifiers.isDone: self.isDone])
		} else {
			node = try Node(node: [
				Identifiers.id: self.id,
				Identifiers.title: self.title,
				Identifiers.priority: self.priority.rawValue,
				Identifiers.creationDate: self.creationDate.timeIntervalSince1970,
				Identifiers.isDone: self.isDone])
		}
		
		return node
	}
}

// MARK: - JSONRepresentable protocol

extension Task: JSONRepresentable {
	
	// No implementation needed as it uses `makeNode` function from `NodeRepresentable` protocol to convert a Node into JSON
}

// MARK: - Preparation protocol

extension Task: Preparation {

	/// The prepare method should call any methods it needs on the database to prepare.
	public static func prepare(_ database: Database) throws {
		try database.create(self.entity) { tasks in
			tasks.id()
			tasks.string(Identifiers.title)
			tasks.string(Identifiers.priority)
			tasks.double(Identifiers.dueDate)
			tasks.double(Identifiers.creationDate)
			tasks.bool(Identifiers.isDone)
		}
	}

	/// The revert method should undo any actions caused by the prepare method.
	public static func revert(_ database: Database) throws {
		try database.delete(self.entity)	// only called when manually executed via CLI
	}
}
