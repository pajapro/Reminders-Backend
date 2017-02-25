//
//  TasksController.swift
//  Reminders-Backend
//
//  Created by Pavel Procházka on 11/02/2017.
//
//

import Vapor
import VaporPostgreSQL
import HTTP
import Foundation

final class TasksController {
	
	func addRoutes(drop: Droplet) {
		let tasks = drop.grouped(Task.entity)
		
		tasks.post(handler: create)
		tasks.get(handler: retrieveAll)
		tasks.get(Int.self, handler: retrieve)
		tasks.put(Int.self, handler: update)
		tasks.delete(Int.self, handler: delete)
	}
	
	/// Create a new task
	func create(for request: Request) throws -> ResponseRepresentable {
		guard let taskTitle = request.data[Identifiers.title]?.string else {
			throw Abort.custom(status: .badRequest, message: "Missing required \(Identifiers.title) value")
		}
		
		guard let listId = request.data[Identifiers.listId]?.int else {
			throw Abort.custom(status: .badRequest, message: "Missing required \(Identifiers.listId) value")
		}
		
		var task: Task
		var taskPriority: Priority = .none
		var taskDueDate: Date? = nil
		
		if let taskPriorityRaw = request.data[Identifiers.priority]?.string, let priority = Priority(rawValue: taskPriorityRaw) {
			taskPriority = priority
		}
		
		if let taskDueDateRaw = request.data[Identifiers.dueDate]?.double {
			taskDueDate = Date(timeIntervalSince1970: taskDueDateRaw)
		}
		
		task = Task(title: taskTitle, priority: taskPriority, dueDate: taskDueDate, listId: Node(listId))
		try task.save()
		return try task.makeJSON()
	}
	
	/// Retrieve all tasks or those matching the provided query
	func retrieveAll(for request: Request) throws -> ResponseRepresentable {
		let jsonResponse: JSON
		if let taskTitle = request.data[Identifiers.title]?.string {
			let foundTasks = try Task.query().filter(Identifiers.title, contains: taskTitle).all()
			jsonResponse = try foundTasks.makeJSON()
		} else {
			jsonResponse = try Task.all().makeJSON()
		}
		
		// Return JSON otherwise HTML page
		if request.headers[HeaderKey.contentType] == Identifiers.json {
			return jsonResponse
		} else {
			return try drop.view.make(Task.entity, Node(node: [Task.entity: jsonResponse]))
		}
	}
	
	/// Retrieve a task
	func retrieve(for request: Request, with taskID: Int) throws -> ResponseRepresentable {
		guard let task = try Task.find(taskID) else {
			throw Abort.notFound
		}
		
		return try task.makeJSON()
	}
	
	/// Update a task
	func update(for request: Request, with taskID: Int) throws -> ResponseRepresentable {
		guard var task = try Task.find(taskID) else {
			throw Abort.custom(status: .notFound, message: "Task with \(Identifiers.id): \(taskID) could not be found")
		}
		
		if let taskTitle = request.data[Identifiers.title]?.string {
			task.title = taskTitle
		}
		
		if let taskPriorityRaw = request.data[Identifiers.priority]?.string {
			if let taskPriority = Priority(rawValue: taskPriorityRaw) {
				task.priority = taskPriority
			} else {
				throw Abort.custom(status: .badRequest, message: "Invalid value \(taskPriorityRaw) of \(Identifiers.priority) parameter")
			}
		}
		
		if let taskDueDateRaw = request.data[Identifiers.dueDate]?.double {
			task.dueDate = Date(timeIntervalSince1970: taskDueDateRaw)
		}
		
		if let taskIsDone = request.data[Identifiers.isDone]?.bool {
			task.isDone = taskIsDone
		}
		
		try task.save()
		return try task.makeJSON()
	}
	
	/// Delete a task
	func delete(for request: Request, with taskID: Int) throws -> ResponseRepresentable {
		guard let task = try Task.find(taskID) else {
			throw Abort.custom(status: .notFound, message: "Task with \(Identifiers.id): \(taskID) could not be found")
		}
		
		try task.delete()
		return Response(status: .ok)
	}
}
