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
	
	/// Contains hash value of user password
	var password: String
}

extension User {
	
	// Used to create new a instance while registering, where hashed password can be set
	init(name: String, email: String, password: String) {
		self.name = name
		self.email = email
		self.password = password
	}
	
	// User registration struct
	struct Registration: Content {
		var name: String
		var email: String
		var password: String
	}
	
	// User public representation struct
	struct Outcoming: Content {
		var email: String
		var token: String
	}
}

/// Allows `User` to be used as a dynamic migration.
extension User: Migration { }

/// Allows `User` to be encoded to and decoded from HTTP messages.
extension User: Content { }

/// Allows `User` to be used as a dynamic parameter in route definitions.
extension User: Parameter { }

// MARK: - BasicAuthenticatable protocol for login https://docs.vapor.codes/3.0/auth/api/#basic
extension User: BasicAuthenticatable {
	
	/// Specifies which property to use for __username__
	static var usernameKey: UsernameKey { return \User.email }
	
	/// Specifies which property to use for __password__
	static var passwordKey: PasswordKey { return \User.password }
}

// MARK: - TokenAuthenticatable protocol for following API client requests https://docs.vapor.codes/3.0/auth/api/#bearer
extension User: TokenAuthenticatable {
	
	/// Specifies which token type to authenticate with
	typealias TokenType = Token
}


