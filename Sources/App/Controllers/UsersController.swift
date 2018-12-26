//
//  UsersController.swift
//  App
//
//  Created by Pavel Procházka on 25/12/2018.
//

import Vapor
import FluentPostgreSQL
import Crypto

/// Controls basic CRUD operations on `User`s.
final class UsersController: RouteCollection {
	
	func boot(router route: Router) throws {
		let route = route.grouped("users")
		route.post(use: create)
		route.get(User.parameter, use: index)
	}
	
	/// Saves a decoded `User` to the database.
	func create(_ req: Request) throws -> Future<User.AuthenticatedUser> {		
		return try req.content.decode(User.Incoming.self)
			.flatMap { incomingUser in
				let passwordHashed = try req.make(BCryptDigest.self).hash(incomingUser.password)
				let newUser = User(name: incomingUser.name, email: incomingUser.email, password: passwordHashed)
				return newUser.save(on: req).map(to: User.AuthenticatedUser.self) { authedUser in
					return try User.AuthenticatedUser(email: authedUser.email, id: authedUser.requireID())
				}
			}
	}
	
	/// Returns a specific `User`.
	func index(_ req: Request) throws -> Future<User> {
		return try req.parameters.next(User.self) // makeOutcoming ?
	}
}
