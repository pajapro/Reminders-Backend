//
//  TasksController.swift
//  App
//
//  Created by Prochazka, Pavel on 10/10/2018.
//

import Vapor
import FluentPostgreSQL

/// Controls basic CRUD operations on `Task`s.
final class TasksController: RouteCollection {
    
    func boot(router route: Router) throws {
        let tasksRoutes = route.grouped("tasks")
		
		// Using `guardAuthMiddleware` to protect routes that might not otherwise attempt to access the authenticated user (which always requires prior authentication)
		let tokenProtected = tasksRoutes.grouped(User.tokenAuthMiddleware(), User.guardAuthMiddleware())
		
        tokenProtected.post(use: create)
        tokenProtected.get(use: retrieveAll)
        tokenProtected.get(Task.parameter, use: index)
        tokenProtected.patch(Task.parameter, use: update)
        tokenProtected.delete(Task.parameter, use: delete)
    }
    
    /// Saves a decoded `Task` to the database.
    func create(_ req: Request) throws -> Future<Task> {
        return try req.content.decode(Task.Incoming.self)
			.flatMap { incomingTask in
				List.find(incomingTask.listId, on: req)
					.unwrap(or: Abort.init(.internalServerError))
					.transform(to: incomingTask)
			}
            .flatMap { incomingTask in
                return incomingTask.makeTask().save(on: req)
            }
        // makeOutcoming ?
    }
    
    /// Returns a list of all `Task`s or found by title.
    func retrieveAll(_ req: Request) throws -> Future<[Task]> {
        do {
            let searchTerm = try req.query.get(String.self, at: "title")
            return Task.query(on: req).filter(\.title, .ilike, "%\(searchTerm)%").all()
        } catch {
            return Task.query(on: req).all()
        }
    }
    
    /// Returns a specific `Task`.
    func index(_ req: Request) throws -> Future<Task> {
        return try req.parameters.next(Task.self) // makeOutcoming ?
    }
    
    /// Updates a specific `Task`.
    func update(_ req: Request) throws -> Future<Task> {
        let existingTask = try req.parameters.next(Task.self)
        let incomingTask = try req.content.decode(Task.Incoming.self)
    
        // ❗️ combine 2 async requests into one
        return flatMap(to: Task.self, existingTask, incomingTask) { (existing, upcoming) in
            return existing.patched(with: upcoming).update(on: req)
        }
    }
    
    /// Deletes a specific `Task`.
    func delete(_ req: Request) throws -> Future<HTTPStatus> {
        return try req.parameters.next(Task.self).flatMap { task in
            return task.delete(on: req)
        }.transform(to: .ok)
    }
}
