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

// Add lists routes
let listsController = ListsController()
listsController.addRoutes(drop: drop)

// Add tasks routes
let tasksController = TasksController()
tasksController.addRoutes(drop: drop)

// Add utility routes
let utilityController = UtilityController()
utilityController.addRoutes(drop: drop)

drop.run()
