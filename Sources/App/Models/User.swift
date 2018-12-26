//
//  User.swift
//  App
//
//  Created by Pavel Procházka on 25/12/2018.
//

import Vapor
import FluentPostgreSQL
import Authentication

struct User: PostgreSQLModel {
	
	// MARK: - Properties
	
	/// Model's unique identifier enforced by `PostgreSQLModel`
	var id: Int?
	
	var name: String
	
	var email: String
	
	var password: String
}

extension User {
	init(name: String, email: String, password: String) {
		self.name = name
		self.email = email
		self.password = password
	}
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

extension User: BasicAuthenticatable {
	static var usernameKey: UsernameKey { return \User.email }
	static var passwordKey: PasswordKey { return \User.password }
}

extension User {
	struct AuthenticatedUser: Content {
		var email: String
		var id: Int
	}
	
	struct LoginRequest: Content {
		var email: String
		var password: String
	}
}

