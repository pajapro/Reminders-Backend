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
public struct Task {
	
	/// Generated unique identifier
	public let id: String = UUID().uuidString
	
	/// Generated date of task creation
	public let creationDate: Date = Date()
	
	/// Task done state
	public var isDone: Bool = false
	
	/// Task title
	public var title: String
	
	/// Task priority
	public var priority: Priority
	
	/// Reminder date
	public var dueDate: Date?
	
	/// Computes the remaining time from now until due date
	public var remainingTime: DateComponents? {
		guard let unwrappedDueDate = self.dueDate else { return nil }
		
		return Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: Date(), to: unwrappedDueDate)
	}
	
	public init(title: String, priority: Priority, dueDate: Date? = nil) {
		self.title = title
		self.priority = priority
		self.dueDate = dueDate
	}
}

// MARK: NodeRepresentable protocol

extension Task: NodeRepresentable {
	
	public func makeNode(context: Context) throws -> Node {
		var node: Node
		if let unwrappedDueDate = self.dueDate {
			node = try Node(node: [
				JSONKeys.title: self.title,
				JSONKeys.priority: self.priority.rawValue,
				JSONKeys.dueDate: DateFormatter.configuredDateFormatter().string(from: unwrappedDueDate)])
		} else {
			node = try Node(node: [
				JSONKeys.title: self.title,
				JSONKeys.priority: self.priority.rawValue])
		}
		
		return node
	}
}

// MARK: JSONRepresentable protocol

extension Task: JSONRepresentable {
	
	// No implementation needed as it uses `makeNode` function from `NodeRepresentable` protocol to convert a Node into JSON
 
}
