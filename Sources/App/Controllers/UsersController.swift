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

final class UsersController {
	
	func addRoutes(drop: Droplet) {
		let users = drop.grouped(User.entity)
		
		users.get("registration", handler: { _ in return try drop.view.make("registration") })	// Shortcut to retrieve a registration form
		users.post(handler: create)
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
		
		// Check if user with the given email already exists
		if try User.query().filter(Identifiers.email, user.email).first() == nil {
			try user.save()
		} else {
			throw Abort.custom(status: .badRequest, message: "User with email \(user.email) already exists")
		}		
	
		// Return JSON for newly created user or redirect to HTML page (GET /lists)
		if request.headers[HeaderKey.contentType] == Identifiers.json {
			return try user.makeJSON()
		} else {
			return Response(redirect: "/")
		}
	}
	
	func logout(for request: Request) throws -> ResponseRepresentable {
		try request.auth.logout()
		return Response(redirect: "/")
	}
}
