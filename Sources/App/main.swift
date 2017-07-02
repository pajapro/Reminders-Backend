import Vapor
import PostgreSQLProvider
import AuthProvider
import LeafProvider
import Sessions

let config = try Config()

// MARK: Providers

do {
	// Connect to PostgreSQL DB
	try config.addProvider(PostgreSQLProvider.Provider.self)
} catch {
	print("Error adding PostgreSQL provider: \(error)")
}

do {
	// Authentication provider
	try config.addProvider(AuthProvider.Provider.self)
} catch {
	print("Error adding Auth provider: \(error)")
}

do {
	// Templating provider
	try config.addProvider(LeafProvider.Provider.self)
} catch {
	print("Error adding Leaf provider: \(error)")
}

do {
} catch {
}

// MARK: Database setup

config.preparations.append(User.self)
config.preparations.append(List.self)
config.preparations.append(Task.self)

// MARK: Middleware (see Config/droplet.json)

// Create in-memory session middleware https://docs.vapor.codes/2.0/sessions/sessions/
let memory = MemorySessions()
let sessionsMiddleware = SessionsMiddleware(memory)
config.addConfigurable(middleware: sessionsMiddleware, name: "sessions")

// Create persist middleware for persisting user once authenticated https://docs.vapor.codes/2.0/auth/persist/#persist
config.addConfigurable(middleware: PersistMiddleware(User.self), name: "user-persist")

// Create version middleware
config.addConfigurable(middleware: VersionMiddleware(), name: "version")

// Create password authentication middleware to require authenticated user on certain endpoints
let passwordMiddleware = PasswordAuthenticationMiddleware(User.self) // It's not added to `config` as it's not required for all endpoints!

// MARK: Droplet

let drop = try Droplet(config)

// Disable caching in order to avoid recompling the app for HTML & CSS tweaks
(drop.view as? LeafRenderer)?.stem.cache = nil

// MARK: Routes

// Add (protected) lists routes
let listsController = ListsController()
listsController.addRoutes(to: drop, with: [passwordMiddleware])

// Add (protected) tasks routes
let tasksController = TasksController()
tasksController.addRoutes(drop: drop, with: [passwordMiddleware])

// Add (unprotected) utility routes
let utilityController = UtilityController()
utilityController.addRoutes(drop: drop)

// Add (unprotected) users routes
let usersController = UsersController()
usersController.addRoutes(drop: drop)

// Start Vapor service
try drop.run()
