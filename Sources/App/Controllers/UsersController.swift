//
//  UsersController.swift
//  Reminders-Backend
//
//  Created by Pavel Procházka on 04/03/2017.
//
//

import Vapor
import HTTP
import PostgreSQLProvider
import VaporValidation	// temporary bug, should be renamed to `ValidationProvider` when fixed https://github.com/vapor/validation-provider/issues/8
import AuthProvider

final class UsersController {
	
	func addRoutes(drop: Droplet) {
		let users = drop.grouped(User.entity)
		
		users.get("registration", handler: { _ in return try drop.view.make("registration") })	// Shortcut to retrieve a registration form
		users.post(handler: create)
		users.post("login", handler: login)
		users.get("logout", handler: logout)
	}
	
	/// Create a new user
	func create(for request: Request) throws -> ResponseRepresentable {
		
		// Validate name input
		guard let name = request.data[Identifiers.name]?.string, name.passes(OnlyAlphanumeric()) else {
			throw Abort(.badRequest, reason: "\(Identifiers.name) must be an alphanumeric value")
		}
		
		// Validate email input
		guard let email = request.data[Identifiers.email]?.string, email.passes(EmailValidator()) else {
			throw Abort(.badRequest, reason: "\(Identifiers.email) must be a valid email address")
		}
		
		// Obtain password input
		guard let rawPassword = request.data[Identifiers.password]?.string else {
			throw Abort(.badRequest, reason: "Missing required \(Identifiers.password) value")
		}

		guard let user = User(name: name, email: email, rawPassword: rawPassword) else {
			throw Abort(.internalServerError)
		}
		
		// Ensure user with the given email does not already exists
		if try User.makeQuery().filter(Identifiers.email, user.email).first() == nil {
			try user.save()
		} else {
			throw Abort(.badRequest, reason: "Account already taken, please choose another email to register")
		}
		
		let credentials = Password(username: email, password: rawPassword)
		let authenticatedUser = try User.authenticate(credentials) // `PersistMiddleware` will take care of persisting our user once they've been authenticated.
		request.auth.authenticate(authenticatedUser)
	
		// Return JSON for newly created user or redirect to HTML page (GET /lists)
		if request.headers[HeaderKey.contentType] == Identifiers.json {
			return try user.makeJSON()
		} else {
			return Response(redirect: "/lists")
		}
	}
	
	/// Login a user
	func login(for request: Request) throws -> ResponseRepresentable {
		guard let email = request.data[Identifiers.email]?.string else {
			throw Abort(.badRequest, reason: "Missing required \(Identifiers.email) value")
		}
		
		guard let rawPassword = request.data[Identifiers.password]?.string else {
			throw Abort(.badRequest, reason: "Missing required \(Identifiers.password) value")
		}
		
		let credentials = Password(username: email, password: rawPassword)
		let authenticatedUser = try User.authenticate(credentials)
		request.auth.authenticate(authenticatedUser)
		
		drop.log.self.verbose("User logged in to the app")
		
		// Return JSON for newly created user or redirect to HTML page (GET /lists)
		if request.headers[HeaderKey.contentType] == Identifiers.json {
			return Response(status: .ok)	// TODO: request.user to return token https://docs.vapor.codes/2.0/auth/getting-started/#example
		} else {
			return Response(redirect: "/lists")
		}
	}
	
	/// Removes authenticated user from request storage
	func logout(for request: Request) throws -> ResponseRepresentable {
		try request.auth.unauthenticate()
		
		drop.log.self.verbose("User logged out from the app")
		
		return Response(redirect: "/")
	}
}
