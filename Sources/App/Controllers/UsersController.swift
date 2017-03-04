//
//  UsersController.swift
//  Reminders-Backend
//
//  Created by Pavel Procházka on 04/03/2017.
//
//

import Vapor
import VaporPostgreSQL
import HTTP
import Foundation
import Turnstile

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
		
		// Validate name and email input
		let name: Valid<OnlyAlphanumeric> = try request.data[Identifiers.name].validated()
		let email: Valid<Email> = try request.data[Identifiers.email].validated()
		
		// Get password as a string
		guard let password = request.data[Identifiers.password]?.string else {
			throw Abort.custom(status: .badRequest, message: "Missing required \(Identifiers.password) value")
		}

		var user = User(name: name.value, email: email.value, rawPassword: password)
		
		// Check if user with the given email does not already exists
		if try User.query().filter(Identifiers.email, user.email).first() == nil {
			try user.save()
		} else {
			throw AccountTakenError()
		}
		
		// Login the newly created user
		let credentials = UsernamePassword(username: email.value, password: password)
		try request.auth.login(credentials)
	
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
			throw Abort.custom(status: .badRequest, message: "Missing required \(Identifiers.email) value")
		}
		
		guard let password = request.data[Identifiers.password]?.string else {
			throw Abort.custom(status: .badRequest, message: "Missing required \(Identifiers.password) value")
		}
		
		let credentials = UsernamePassword(username: email, password: password)
		
		do {
			try request.auth.login(credentials)	// calls the `authenticate` method of User type under the hood
		} catch let error as TurnstileError {
			return error.description
		}
		
		// Return JSON for newly created user or redirect to HTML page (GET /lists)
		if request.headers[HeaderKey.contentType] == Identifiers.json {
			return Response(status: .ok)	// TODO: request.user to return token?
		} else {
			return Response(redirect: "/lists")
		}
	}
	
	func logout(for request: Request) throws -> ResponseRepresentable {
		try request.auth.logout()
		return Response(redirect: "/")
	}
}
