//
//  BasicController.swift
//  Utility-Backend
//
//  Created by Pavel Procházka on 11/02/2017.
//
//

import Vapor
import VaporPostgreSQL
import HTTP
import Foundation

final class UtilityController {
	
	func addRoutes(drop: Droplet) {
		drop.get(handler: retrieveRoot)
		drop.get("dbversion", handler: databaseVersion)
		drop.get("os", handler: retrieveOperatingSystem)
	}
	
	/// Retrieve root
	func retrieveRoot(for request: Request) throws -> ResponseRepresentable {
		return try JSON(node : ["message": "More awesomeness coming soon..."])
	}
	
	/// Retrieve the database version
	func databaseVersion(for request: Request) throws -> ResponseRepresentable {
		if let db = drop.database?.driver as? PostgreSQLDriver {
			let version = try db.raw("SELECT version()")
			return try JSON(node: version)
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
