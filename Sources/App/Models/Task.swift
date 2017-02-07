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

// MARK: - NodeInitializable protocol

extension Task: NodeInitializable {
	
	/// Initializer creating model object from Node (Fluent pulls data from DB into intermediate representation `Node` THEN we need to convert back to type-safe model)
	public init(node: Node, in context: Context) throws {
		self.id = try node.extract(JSONKeys.id)
		self.title = try node.extract(JSONKeys.title)
		
		// TODO: how to transform Date and enum? 
		self.priority = .high //try node.extract(JSONKeys.priority, transform: Priority.init)
		self.dueDate = Date() //try node.extract(JSONKeys.dueDate, transform: DateFormatter.configuredDateFormatter().date(from: <#T##String#>))
	}
}

// MARK: - NodeRepresentable protocol

extension Task: NodeRepresentable {
	
	/// Converts type-safe model into an instance of `Node` object
	public func makeNode(context: Context) throws -> Node {
		var node: Node
		if let unwrappedDueDate = self.dueDate {
			node = try Node(node: [
				JSONKeys.id: self.id,
				JSONKeys.title: self.title,
				JSONKeys.priority: self.priority.rawValue,
				JSONKeys.dueDate: DateFormatter.configuredDateFormatter().string(from: unwrappedDueDate)])
		} else {
			node = try Node(node: [
				JSONKeys.id: self.id,
				JSONKeys.title: self.title,
				JSONKeys.priority: self.priority.rawValue])
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
			tasks.string(Identifiers.dueDate)
			tasks.string(Identifiers.creationDate)
			tasks.bool(Identifiers.isDone)
		}
	}

	/// The revert method should undo any actions caused by the prepare method.
	public static func revert(_ database: Database) throws {
		try database.delete(self.entity)	// only called when manually executed via CLI
	}
}
