//
//  BasicController.swift
//  Utility-Backend
//
//  Created by Pavel Procházka on 11/02/2017.
//
//

import Vapor
import PostgreSQLDriver

final class UtilityController {
	
	func addRoutes(drop: Droplet) {
		drop.get(handler: retrieveRoot)
		drop.get("dbversion", handler: databaseVersion)
		drop.get("os", handler: retrieveOperatingSystem)
	}
	
	/// Retrieve root
	func retrieveRoot(for request: Request) throws -> ResponseRepresentable {
		do {
			_ = try request.currentUser()
			return try drop.view.make("index", Node(node: ["isLoggedIn": true]))
		} catch {
			return try drop.view.make("index", Node(node: ["isLoggedIn": false]))
		}
	}
	
	/// Retrieve the database version
	func databaseVersion(for request: Request) throws -> ResponseRepresentable {
		if let db = drop.database?.driver as? PostgreSQLDriver.Driver {
			let version = try db.raw("SELECT version()")
			return JSON(node: version)
		} else {
			return "No database connection"
		}
	}
	
	/// Retrieve the OS application is running in
	func retrieveOperatingSystem(for request: Request) throws -> ResponseRepresentable {
		#if os(Linux)
			return try JSON(node: ["operating_system": "Linux"])
		#elseif os(OSX)
			return try JSON(node: ["operating_system": "OSX"])
		#else
			return try JSON(node: ["operating_system": "...other OS"])
		#endif
	}
}
