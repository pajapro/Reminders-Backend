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

final class ListsController {
	
	func addRoutes(drop: Droplet) {
		let lists = drop.grouped(List.entity)
		
		lists.post(handler: create)
		lists.get(handler: retrieveAll)
		lists.get(Int.self, handler: retrieve)
		lists.get(Int.self, Task.entity, handler: retrieveTasks)
		lists.put(Int.self, handler: update)
		lists.delete(Int.self, handler: delete)
	}
	
	/// Create a new list
	func create(for request: Request) throws -> ResponseRepresentable {
		guard let listTitle = request.data[Identifiers.title]?.string else {
			throw Abort.custom(status: .badRequest, message: "Missing required \(Identifiers.title) value")
		}
		
		var list = List(title: listTitle)
		try list.save()
		
		// Return JSON for newly created list or HTML page with all lists
		if request.headers[HeaderKey.contentType] == Identifiers.json {
			return try list.makeJSON()
		} else {
			return try drop.view.make(List.entity, Node(node: [List.entity: List.all().makeJSON()]))
		}
	}
	
	/// Retrieve all lists or those matching the provided query
	func retrieveAll(for request: Request) throws -> ResponseRepresentable {
		let jsonResponse: JSON
		if let listTitle = request.data[Identifiers.title]?.string {
			let foundLists = try List.query().filter(Identifiers.title, contains: listTitle).all()
			jsonResponse = try foundLists.makeJSON()
		} else {
			jsonResponse = try List.all().makeJSON()
		}
		
		
		// Return JSON otherwise HTML page
		if request.headers[HeaderKey.contentType] == Identifiers.json {
			return jsonResponse
		} else {
			return try drop.view.make(List.entity, Node(node: [List.entity: jsonResponse]))
		}
	}
	
	/// Retrieve a list
	func retrieve(for request: Request, with listId: Int) throws -> ResponseRepresentable {
		guard let list = try List.find(listId) else {
			throw Abort.notFound
		}
		
		return try list.makeJSON()
	}
	
	/// Retrieve all task associated with list
	func retrieveTasks(for request: Request, with listId: Int) throws -> ResponseRepresentable {
		guard let list = try List.find(listId) else {
			throw Abort.notFound
		}
		
		let tasks = try list.tasks().all()
		
		return try tasks.makeJSON()
	}
	
	/// Update a list
	func update(for request: Request, with listId: Int) throws -> ResponseRepresentable {
		guard var list = try List.find(listId) else {
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
		guard let list = try List.find(listId) else {
			throw Abort.custom(status: .notFound, message: "List with \(Identifiers.id): \(listId) could not be found")
		}
		
		try list.delete()
		return Response(status: .ok)
	}
}
