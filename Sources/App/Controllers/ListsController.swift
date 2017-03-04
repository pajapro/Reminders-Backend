//
//  ListsController.swift
//  Reminders-Backend
//
//  Created by Pavel Procházka on 12/02/2017.
//
//

import Vapor
import VaporPostgreSQL
import HTTP
import Foundation
import Auth

final class ListsController {
	
	func addRoutes(to drop: Droplet, with middleware: Middleware) {
		let lists = drop.grouped(middleware).grouped(List.entity)
		
		lists.post(handler: create)
		lists.get(handler: retrieveAll)
		lists.get(Int.self, handler: retrieve)
		lists.get(Int.self, Task.entity, handler: retrieveTasks)
		lists.put(Int.self, handler: update)
		lists.delete(Int.self, handler: delete)
		
		// not-really RESTful endpoint to perform DELETE operation without adding extra JS into FE
		lists.post(Int.self, "delete", handler: delete)
	}
	
	/// Create a new list
	func create(for request: Request) throws -> ResponseRepresentable {
		guard let listTitle = request.data[Identifiers.title]?.string else {
			throw Abort.custom(status: .badRequest, message: "Missing required \(Identifiers.title) value")
		}
		
		let authenticatedUser = try request.auth.user()
		var list = List(title: listTitle, userId: authenticatedUser.id)
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
		let authenticatedUser = try request.auth.user()
		let jsonResponse: JSON
		
		if let listTitle = request.data[Identifiers.title]?.string {
			jsonResponse = try List.lists(for: authenticatedUser).filter(Identifiers.title, contains: listTitle).all().makeJSON()
		} else {
			jsonResponse = try List.lists(for: authenticatedUser).all().makeJSON()
		}
		
		// Return JSON otherwise HTML page with Lists
		if request.headers[HeaderKey.contentType] == Identifiers.json {
			return jsonResponse
		} else {
			return try drop.view.make(List.entity, Node(node: [List.entity: jsonResponse]))
		}
	}
	
	/// Retrieve a list
	func retrieve(for request: Request, with listId: Int) throws -> ResponseRepresentable {
		let authenticatedUser = try request.auth.user()
		
		guard let list = try List.list(for: authenticatedUser, with: listId) else {
			throw Abort.notFound
		}
		
		return try list.makeJSON()
	}
	
	/// Retrieve all tasks associated with list
	func retrieveTasks(for request: Request, with listId: Int) throws -> ResponseRepresentable {
		let authenticatedUser = try request.auth.user()
		
		guard let list = try List.list(for: authenticatedUser, with: listId) else {
			throw Abort.notFound
		}
		
		let jsonResponse = try list.tasks().all().makeJSON()
		
		// Return JSON otherwise HTML page with Tasks
		if request.headers[HeaderKey.contentType] == Identifiers.json {
			return jsonResponse
		} else {
			// For HTML response send Task JSONs as well as List JSON
			return try drop.view.make(Task.entity, Node(node: [List.entity: list.makeJSON(), Task.entity: jsonResponse]))
		}
	}
	
	/// Update a list
	func update(for request: Request, with listId: Int) throws -> ResponseRepresentable {
		let authenticatedUser = try request.auth.user()
		
		guard var list = try List.list(for: authenticatedUser, with: listId) else {
			throw Abort.custom(status: .notFound, message: "List with \(Identifiers.id): \(listId) could not be found")
		}
		
		if let listTitle = request.data[Identifiers.title]?.string {
			list.title = listTitle
		}
		
		try list.save()
		return try list.makeJSON()
	}
	
	/// Delete a list
	func delete(for request: Request, with listId: Int) throws -> ResponseRepresentable {
		let authenticatedUser = try request.auth.user()
		
		guard let list = try List.list(for: authenticatedUser, with: listId) else {
			throw Abort.custom(status: .notFound, message: "List with \(Identifiers.id): \(listId) could not be found")
		}
		
		try list.delete()
		
		// Delete associated tasks with this list
		let associatedTasks = try Task.query().filter(Identifiers.listId, .equals, listId).all()
		try associatedTasks.forEach { try $0.delete() }
		
		// Return JSON for newly created list or redirect to HTML page (GET /lists)
		if request.headers[HeaderKey.contentType] == Identifiers.json {
			return Response(status: .ok)
		} else {
			return Response(redirect: "/\(List.entity)")
		}
	}
}
