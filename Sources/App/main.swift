import Vapor
import Foundation
import VaporPostgreSQL
import HTTP

let drop = Droplet()
drop.preparations.append(Task.self)	// invoke `prepare` function to create corresponding table

// Connect to PostgreSQL DB
do {
	try drop.addProvider(VaporPostgreSQL.Provider.self)
} catch {
	print("Error adding provider: \(error)")
}

/// MARK: - Utility endpoinds

// Root request
drop.get() { _ in
	return try JSON(node : ["message": "More awesomeness coming soon..."])
}

// GET database version
drop.get("dbversion") { _ in
	if let db = drop.database?.driver as? PostgreSQLDriver {
		let version = try db.raw("SELECT version()")
		return try JSON(node: version)
	} else {
		return "No database connection"
	}
}

drop.get("model") { _ in
	let task = Task(title: "Greet me!", priority: .medium, dueDate: Date())
	return try task.makeJSON()
}

/// MARK: - Test endpoinds

// GET for resource at String
drop.get("resource", String.self) { request, name in
	return "So you want \(name)?!"
}

// GET for resource at Int
drop.get("drink", Int.self) { request, beers in
	return "Are you sure you want to drink \(beers) beers?"
}

// GET resource with params (hello?param=value)
drop.get("hello") { request in
	let name = request.data["name"]?.string ?? "stranger"
	return "Hello \(name), how you doing?"
}

// POST
drop.post("post") { request in
	guard let name = request.data["name"]?.string else {
		throw Abort.badRequest
	}
	
	return try JSON(node: ["message": "Hello, \(name)"])
}



/// MARK: - Task endpoints

/// Create a new task
drop.post("tasks") { request in
	guard let taskTitle = request.data[Identifiers.title]?.string else {
		throw Abort.custom(status: .badRequest, message: "Missing required \(Identifiers.title) value")
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
	
	task = Task(title: taskTitle, priority: taskPriority, dueDate: taskDueDate)
	try task.save()
	return try task.makeJSON()
}

/// Retrieve all tasks
drop.get("tasks") { _ in
	return try Task.all().makeJSON()
}

/// Retrieve a task
drop.get("tasks", Int.self) { request, taskID in
	guard let task = try Task.find(taskID) else {
		throw Abort.notFound
	}
	
	return try task.makeJSON()
}

/// Update a task
drop.put("tasks", Int.self) { request, taskID in
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
drop.delete("tasks", Int.self) { request, taskID in
	guard let task = try Task.find(taskID) else {
		throw Abort.custom(status: .notFound, message: "Task with \(Identifiers.id): \(taskID) could not be found")
	}
	
	try task.delete()
	return Response(status: .ok)
}

/// Search for a task
drop.get("tasks") { request in
	guard let taskTitle = request.data[Identifiers.title]?.string else {
		throw Abort.notFound
	}
	
	let foundTasks = try Task.query().filter(Identifiers.title, contains: taskTitle).all()
	return try foundTasks.makeJSON()
}


drop.run()
