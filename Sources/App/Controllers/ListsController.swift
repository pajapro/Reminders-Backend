//
//  ListsController.swift
//  Reminders-Backend
//
//  Created by Pavel Procházka on 12/02/2017.
//
//

import Vapor
import HTTP
import PostgreSQLProvider
import AuthProvider

final class ListsController {
	
	func addRoutes(to drop: Droplet, with middleware: [Middleware]) {
		let lists = drop.grouped(middleware).grouped(List.entity)
		
		lists.post(handler: create)
		lists.get(handler: retrieveAll)
		lists.get(Int.parameter, handler: retrieve)
		lists.get(Int.parameter, Task.entity, handler: retrieveTasks)
		lists.put(Int.parameter, handler: update)
		lists.delete(Int.parameter, handler: delete)
		
		// HACK to perform DELETE operation on POST request in order to avoid extra JS in FE
		lists.post(Int.parameter, "delete", handler: delete)
	}
	
	/// Create a new list
	func create(for request: Request) throws -> ResponseRepresentable {
		guard let listTitle = request.data[Identifiers.title]?.string else {
			throw Abort(.badRequest, reason: "Missing required \(Identifiers.title) value")
		}
		
		let authenticatedUser = try request.currentUser()
		let list = List(title: listTitle, userId: authenticatedUser.id!)
		try list.save()
		
		// Return JSON for newly created list or redirect to HTML page (GET /lists)
		if request.headers[HeaderKey.contentType] == Identifiers.json {
			return try list.makeJSON()
		} else {
			return Response(redirect: "/\(List.entity)")
		}
	}
	
	/// Retrieve all lists or those matching the provided query
	func retrieveAll(for request: Request) throws -> ResponseRepresentable {
		let jsonResponse: JSON
		
		if let listTitle = request.data[Identifiers.title]?.string {
			jsonResponse = try request.currentUser().lists.filter(Identifiers.title, .contains, listTitle).all().makeJSON()
		} else {
			jsonResponse = try request.currentUser().lists.all().makeJSON()
		}
		
		// Return JSON otherwise HTML page with Lists
		if request.headers[HeaderKey.contentType] == Identifiers.json {
			return jsonResponse
		} else {
			return try drop.view.make(List.entity, Node(node: [List.entity: jsonResponse]))
		}
	}
	
	/// Retrieve a list
	func retrieve(for request: Request) throws -> ResponseRepresentable {
		let listId = try request.parameters.next(Int.self)
		
		let list = try request.currentUser().list(with: listId)
		
		return try list.makeJSON()	// No UI hence not returning a view
	}
	
	/// Retrieve all tasks associated with list
	func retrieveTasks(for request: Request) throws -> ResponseRepresentable {
		let listId = try request.parameters.next(Int.self)
		
		let list = try request.currentUser().list(with: listId)
		
		let jsonResponse = try list.tasks.all().makeJSON()
		
		// Return JSON otherwise HTML page with Tasks
		if request.headers[HeaderKey.contentType] == Identifiers.json {
			return jsonResponse
		} else {
			// For HTML response send Task JSONs as well as List JSON
			return try drop.view.make(Task.entity, Node(node: [List.entity: list.makeJSON(), Task.entity: jsonResponse]))
		}
	}
	
	/// Update a list
	func update(for request: Request) throws -> ResponseRepresentable {
		let listId = try request.parameters.next(Int.self)
		
		let list = try request.currentUser().list(with: listId)
		
		if let listTitle = request.data[Identifiers.title]?.string {
			list.title = listTitle
		}
		
		try list.save()
		return try list.makeJSON()	// No UI hence not returning a view
	}
	
	/// Delete a list
	func delete(for request: Request) throws -> ResponseRepresentable {
		let listId = try request.parameters.next(Int.self)
		
		let list = try request.currentUser().list(with: listId)
		
		// Delete associated tasks with this list
		let associatedTasks = try list.tasks.all()
		try associatedTasks.forEach { try $0.delete() }
		
		// Delete actual list
		try list.delete()
		
		// Return JSON for newly created list or redirect to HTML page (GET /lists)
		if request.headers[HeaderKey.contentType] == Identifiers.json {
			return Response(status: .ok)
		} else {
			return Response(redirect: "/\(List.entity)")
		}
	}
}
