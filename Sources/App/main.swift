import Vapor
import Foundation
import VaporPostgreSQL

let drop = Droplet()
try drop.addProvider(VaporPostgreSQL.Provider.self)
// Connect to PostgreSQL DB
do {
	try drop.addProvider(VaporPostgreSQL.Provider.self)
} catch {
	print("Error adding provider: \(error)")
}

/// MARK: - Utility endpoinds

// Root request
drop.get() { _ in
	return try JSON(node : ["message": "More awesomeness coming soon..."])
}

// GET database version
drop.get("dbversion") { _ in
	if let db = drop.database?.driver as? PostgreSQLDriver {
		let version = try db.raw("SELECT version()")
		return try JSON(node: version)
	} else {
		return "No database connection"
	}
}

drop.get("model") { _ in
	let task = Task(title: "Greet me!", priority: .medium, dueDate: Date())
	return try task.makeJSON()
}

/// MARK: - Test endpoinds

// GET for resource at String
drop.get("resource", String.self) { request, name in
	return "So you want \(name)?!"
}

// GET for resource at Int
drop.get("drink", Int.self) { request, beers in
	return "Are you sure you want to drink \(beers) beers?"
}

// GET resource with params (hello?param=value)
drop.get("hello") { request in
	let name = request.data["name"]?.string ?? "stranger"
	return "Hello \(name), how you doing?"
}

// POST
drop.post("post") { request in
	guard let name = request.data["name"]?.string else {
		throw Abort.badRequest
	}
	
	return try JSON(node: ["message": "Hello, \(name)"])
}

drop.run()
