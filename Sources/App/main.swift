import Vapor
import Foundation
import VaporPostgreSQL
import HTTP

let drop = Droplet()
drop.preparations.append(Task.self)	// invoke `prepare` function to create corresponding table

// Connect to PostgreSQL DB
do {
	try drop.addProvider(VaporPostgreSQL.Provider.self)
} catch {
	print("Error adding provider: \(error)")
}

// Task routes
let taskController = TasksController()
taskController.addRoutes(drop: drop)

// Utility routes
let utilityController = UtilityController()
utilityController.addRoutes(drop: drop)

drop.run()
