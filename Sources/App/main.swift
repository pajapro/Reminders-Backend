import Vapor
import Foundation
import VaporPostgreSQL
import HTTP
import Auth

let drop = Droplet()

// Invoke `prepare` function to create corresponding tables
drop.preparations.append(List.self)
drop.preparations.append(Task.self)
drop.preparations.append(User.self)

// Add authentication middleware
drop.middleware.append(AuthMiddleware(user: User.self))

// FIXME: add back `AbortMiddleware` 
print("Middlewares: \(drop.middleware)")
// Add version middleware
drop.middleware.append(VersionMiddleware())

drop.middleware.remove(at: 1)
print("New middlewares: \(drop.middleware)")

// Create protect middleware to require authentication on certain endpoints
let protectMiddleware = ProtectMiddleware(error: Abort.custom(status: .forbidden, message: "Invalid credentials."))

// Connect to PostgreSQL DB
do {
	try drop.addProvider(VaporPostgreSQL.Provider.self)
} catch {
	print("Error adding provider: \(error)")
}

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
