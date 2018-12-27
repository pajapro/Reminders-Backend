//
//  Token.swift
//  App
//
//  Created by Pavel Procházka on 26/12/2018.
//

import Vapor
import FluentPostgreSQL
import Authentication

struct Token: PostgreSQLModel {
	
	/// Model's unique identifier enforced by `PostgreSQLModel`
	var id: Int?
	
	var token: String
	
	var userId: User.ID
	
	// TODO: Add token expiration
	// var isExpired: Bool
	
	init(token: String, userId: User.ID) {
		self.token = token
		self.userId = userId
	}
}

extension Token {
	
	/// Convenience property to retrieve a User for a given Token
	var user: Parent<Token, User> {
		return parent(\.userId)
	}
	
	static func createToken(forUser user: User) throws -> Token {
		let tokenString = Helpers.randomToken(withLength: 60)
		let newToken = try Token(token: tokenString, userId: user.requireID())
		return newToken
	}
	
	func updated(with token: String) -> Token {
		return Token(token: token, userId: userId)
	}
}

/// Allows `Token` to be used as a dynamic migration.
extension Token: Migration { }

// MARK: - BearerAuthenticatable protocol
extension Token: BearerAuthenticatable {
	
	/// Specifies which property to use for __unique token__
	static var tokenKey: WritableKeyPath<Token, String> { return \Token.token }
}

// MARK: - Authentication.Token protocol
extension Token: Authentication.Token {
	
	/// Specifies which property to use for __user ID__
	static var userIDKey: WritableKeyPath<Token, User.ID> { return \Token.userId }
	
	/// Specifies which user type owns this token
	typealias UserType = User
	
	/// Specifies which property on our `User` class it needs in order to identify a user, given a specific token
	typealias UserIDType = User.ID
}
