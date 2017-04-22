import Vapor
import Foundation
import VaporPostgreSQL
import HTTP
import Auth
import SwiftyBeaverVapor
import SwiftyBeaver

let drop = Droplet()

// Invoke `prepare` function to create corresponding tables
drop.preparations.append(List.self)
drop.preparations.append(Task.self)
drop.preparations.append(User.self)

// Add authentication middleware
drop.middleware.append(AuthMiddleware(user: User.self))

// Add version middleware
drop.middleware.append(VersionMiddleware())

// Create protect middleware to require authentication on certain endpoints
let protectMiddleware = ProtectMiddleware(error: Abort.custom(status: .forbidden, message: "Invalid credentials."))

// Connect to PostgreSQL DB
do {
	try drop.addProvider(VaporPostgreSQL.Provider.self)
} catch {
	print("Error adding provider: \(error)")
}

// Add SwiftyBeaver logging
let console = ConsoleDestination()  // log to Xcode Console in color
let file = FileDestination()		// log to file in color
file.logFileURL = URL(fileURLWithPath: "/tmp/VaporLogs.log")
let sbProvider = SwiftyBeaverProvider(destinations: [console, file])
drop.addProvider(sbProvider)

// Disable caching in order to avoid recompling the app for HTML & CSS tweaks
(drop.view as? LeafRenderer)?.stem.cache = nil

// Add (protected) lists routes
let listsController = ListsController()
listsController.addRoutes(to: drop, with: protectMiddleware)

// Add (protected) tasks routes
let tasksController = TasksController()
tasksController.addRoutes(drop: drop, with: protectMiddleware)

// Add (unprotected) utility routes
let utilityController = UtilityController()
utilityController.addRoutes(drop: drop)

// Add (unprotected) users routes
let usersController = UsersController()
usersController.addRoutes(drop: drop)

// Start Vapor service
drop.run()
