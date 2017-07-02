//
//  User.swift
//  Reminders-Backend
//
//  Created by Pavel Procházka on 04/03/2017.
//
//

import Vapor
import FluentProvider
import AuthProvider
import BCrypt

private let hashCost: UInt = 10

/// Class holding information about a user
final class User: Model, Timestampable {
	
	// MARK: Properties
	
	/// Allows Fluent to store extra information on model (such as the model's database id)
	let storage = Storage()
	
	/// User name
	var name: String
	
	/// User email
	var email: String
	
	/// User password
	var password: String
	
	// MARK: Initializers
	
	public init?(name: String, email: String, rawPassword: String) {
		self.name = name
		self.email = email
		
		if let hashedPasswordBytes = try? BCryptHasher(cost: hashCost).make(rawPassword.makeBytes()) {
			self.password = hashedPasswordBytes.makeString()
		} else {
			return nil
		}
	}
	
	/// Initializer creating model object from Row (Fluent pulls data from DB into intermediate representation `Row` THEN we need to convert back to type-safe model). See `RowInitializable`
	init(row: Row) throws {
		self.name = try row.get(Identifiers.name)
		self.email = try row.get(Identifiers.email)
		self.password = try row.get(Identifiers.password)
	}
	
	/// Converts type-safe model into an instance of `Row` object. See `RowRepresentable`
	func makeRow() throws -> Row {
		var row = Row()
		try row.set(Identifiers.name, self.name)
		try row.set(Identifiers.email, self.email)
		try row.set(Identifiers.password, self.password)
		return row
	}
}

// MARK: - JSONRepresentable protocol

extension User: JSONRepresentable {
	
	/// Converts model into JSON
	public func makeJSON() throws -> JSON {
		var json = JSON()
		try json.set(Identifiers.id, self.id?.string)
		try json.set(Identifiers.name, self.name)
		try json.set(Identifiers.email, self.email)
		return json
	}
}

// MARK: - Preparation protocol

extension User: Preparation {
	
	/// The prepare method should call any methods it needs on the database to prepare.
	public static func prepare(_ database: Database) throws {
		try database.create(self) { users in
			users.id()
			users.string(Identifiers.name)
			users.string(Identifiers.email)
			users.string(Identifiers.password)
		}
	}
	
	/// The revert method should undo any actions caused by the prepare method.
	public static func revert(_ database: Database) throws {
		try database.delete(self)	// only called when manually executed via CLI
	}
}

// MARK: - PasswordAuthenticable protocol https://docs.vapor.codes/2.0/auth/password/

extension User: PasswordAuthenticatable {
	
	var hashedPassword: String? {
		return self.password
	}
	
	static var passwordVerifier: PasswordVerifier? {
		return BCryptHasher(cost: hashCost)
	}
}

// MARK: SessionPersistable protocol

extension User: SessionPersistable {}

// MARK: - Convenience methods

extension User {
	
	/// Relationship convenience method to fetch children entities
	var lists: Children<User, List> {
		return children()
	}
	
	/// Relationship convenience method to fetch children entities for specific list ID
	func list(with listId: Int) throws -> List {
		if let list = try self.lists.filter(Identifiers.id, listId).first() {
			return list
		} else {
			throw Abort(.notFound, reason: "List with \(Identifiers.id): \(listId) could not be found")
		}
	}
}
