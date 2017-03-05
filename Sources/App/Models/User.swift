//
//  User.swift
//  Reminders-Backend
//
//  Created by Pavel Procházka on 04/03/2017.
//
//

import Foundation
import Vapor
import Fluent
import Turnstile
import TurnstileCrypto
import Auth

/// Struct holding information about a user
public struct User: Model {
	
	// MARK: - Properties
	
	/// User entity name
	fileprivate let entity = "users"
	
	/// Contains the identifier when the model is fetched from the database. If it is `nil`, it **will be set when the model is saved**.
	public var id: Node?
	
	/// User name
	public var name: String
	
	/// User email
	public var email: String
	
	/// User password
	public var password: String
	
	// MARK: - Initializers
	
	public init(name: String, email: String, rawPassword: String) {
		self.id = nil
		self.name = name
		self.email = email
		self.password = BCrypt.hash(password: rawPassword)	// hash given password
	}
}

// MARK: - NodeInitializable protocol (how to initialize our model FROM the database)

extension User: NodeInitializable {
	
	/// Initializer creating model object from Node (Fluent pulls data from DB into intermediate representation `Node` THEN we need to convert back to type-safe model)
	public init(node: Node, in context: Context) throws {
		self.id = try node.extract(Identifiers.id)
		self.name = try node.extract(Identifiers.name)
		self.email = try node.extract(Identifiers.email)
		self.password = try node.extract(Identifiers.password)
	}
}

// MARK: - NodeRepresentable protocol (how to save our model TO the database)

extension User: NodeRepresentable {
	
	/// Converts type-safe model into an instance of `Node` object
	public func makeNode(context: Context) throws -> Node {
		let node = try Node(node: [
			Identifiers.id: self.id,
			Identifiers.name: self.name,
			Identifiers.email: self.email,
			Identifiers.password: self.password,
		])
		
		return node
	}
}


// MARK: - JSONRepresentable protocol

extension User: JSONRepresentable {
	
	/// Converts model into JSON
	public func makeJSON() throws -> JSON {
		return try JSON(node: [Identifiers.id: self.id, Identifiers.name: self.name, Identifiers.email: self.email])
	}
}

// MARK: - Preparation protocol

extension User: Preparation {
	
	/// The prepare method should call any methods it needs on the database to prepare.
	public static func prepare(_ database: Database) throws {
		try database.create(self.entity) { users in
			users.id()
			users.string(Identifiers.name)
			users.string(Identifiers.email)
			users.string(Identifiers.password)
		}
	}
	
	/// The revert method should undo any actions caused by the prepare method.
	public static func revert(_ database: Database) throws {
		try database.delete(self.entity)	// only called when manually executed via CLI
	}
}

// MARK: User protocol

// Note that the name of our class and the protocol are the same. This is why we use the `Auth.` prefix to differentiate the protocol from the Auth module from our `User` class.
extension User: Auth.User {
	
	// A user is authenticated when a set of credentials is passed to the static `authenticate` method and the *matching* user is returned.
	public static func authenticate(credentials: Credentials) throws -> Auth.User {
		var user: User?
		
		switch credentials {
		// First time login
		case let credentials as UsernamePassword:
			
			// Try to find user with matching email (username = email)
			let fetchedUser = try User.query().filter(Identifiers.email, credentials.username).first()
			
			// Verify that the stored password from DB *matches* the hashed password user is authenticating with
			if let password = fetchedUser?.password, !password.isEmpty, (try? BCrypt.verify(password: credentials.password, matchesHash: password)) == true {
				user = fetchedUser
			}
			
		// Subsequent API requests
		case let credentials as Identifier:
			user = try User.find(credentials.id)
			
		// TODO: add support for `AccessToken`
			
		default:
			throw UnsupportedCredentialsError()
		}
		
		if let unwrappedUser = user {
			return unwrappedUser
		} else {
			throw IncorrectCredentialsError()
		}
	}
	
	public static func register(credentials: Credentials) throws -> Auth.User {
		throw Abort.badRequest
	}
}

// MARK: - Convenience methods

extension Auth.User {
	
	/// Relationship convenience method to fetch children entities
	func lists() throws -> Children<List> {
		return children()
	}
	
	/// Relationship convenience method to fetch children entities for specific list ID
	func list(with listId: Int) throws -> List? {
		return try self.lists().filter(Identifiers.id, listId).first()
	}
}

