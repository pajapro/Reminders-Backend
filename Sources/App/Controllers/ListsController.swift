//
//  ListsController.swift
//  App
//
//  Created by Prochazka, Pavel on 23/11/2018.
//

import Vapor
import FluentPostgreSQL

/// Controls basic CRUD operations on `List`s.
final class ListsController: RouteCollection {
    
    func boot(router route: Router) throws {
        let route = route.grouped("lists")
        route.post(use: create)
        route.get(use: retrieveAll)
        route.get(List.parameter, use: index)
        route.get(List.parameter, "tasks", use: retrieveTasks)
        route.patch(List.parameter, use: update)
        route.delete(List.parameter, use: delete)
    }
    
    /// Saves a decoded `List` to the database.
    func create(_ req: Request) throws -> Future<List> {
        return try req.content.decode(List.Incoming.self)
            .flatMap { list in
                return list.makeList().save(on: req)
        }
        // makeOutcoming ?
    }
    
    /// Returns a list of all `List`s.
    func retrieveAll(_ req: Request) throws -> Future<[List]> {
        do {
            let searchTerm = try req.query.get(String.self, at: "title")
            return List.query(on: req).filter(\.title, .ilike, "%\(searchTerm)%").all()
        } catch {
            return List.query(on: req).all()
        }
    }
    
    /// Returns a specific `List`.
    func index(_ req: Request) throws -> Future<List> {
        return try req.parameters.next(List.self)
    }
    
    /// Returns an array of `Task`s accociated with given `List`
    func retrieveTasks(_ req: Request) throws -> Future<[Task]> {
        return try req.parameters.next(List.self).flatMap { list in
            return try list.tasks.query(on: req).all()
        }
    }
    
    /// Updates a specific `List`.
    func update(_ req: Request) throws -> Future<List> {
        let existingList = try req.parameters.next(List.self)
        let incomingList = try req.content.decode(List.Incoming.self)
        
        // ❗️ combine 2 async requests into one
        return flatMap(to: List.self, existingList, incomingList) { (existing, upcoming) in
            return existing.patched(with: upcoming).update(on: req)
        }
    }
    
    /// Deletes a specific `List`.
    func delete(_ req: Request) throws -> Future<HTTPStatus> {
        return try req.parameters.next(List.self).flatMap { list in
            return list.delete(on: req)
            }.transform(to: .ok)
    }
}
