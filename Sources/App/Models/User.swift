//
//  User.swift
//  App
//
//  Created by Pavel Procházka on 25/12/2018.
//

import Vapor
import FluentPostgreSQL

struct User: PostgreSQLModel {
	
	// MARK: - Properties
	
	/// Model's unique identifier enforced by `PostgreSQLModel`
	var id: Int?
	
	var name: String
	
	var email: String
	
	var password: String
}

/// Allows `User` to be used as a dynamic migration.
extension User: Migration { }

/// Allows `User` to be encoded to and decoded from HTTP messages.
extension User: Content { }

/// Allows `User` to be used as a dynamic parameter in route definitions.
extension User: Parameter { }

/// MARK: - Incoming struct
extension User {
	
	struct Incoming: Content {
		var name: String
		var email: String
		var password: String
		
		// Factory to create empty incoming User
		func makeUser() -> User {
			return User(id: nil, name: name, email: email, password: password)
		}
	}
}
