import Vapor

/// Register your application's routes here.
public func routes(_ router: Router) throws {
    // Basic "It works" example
    router.get { req in
        return "It works!"
    }
    
    // Parametrised route example
    router.get("foo", Int.parameter) { req in
        return try "Hello \(req.parameters.next(Int.self))"
    }
    
    // Add (protected) Lists routes
    try router.register(collection: ListsController())
    
    // Add (protected) Tasks routes
    try router.register(collection: TasksController())
	
	// Add (protected) Users routes
	try router.register(collection: UsersController())
    
    // Add (unprotected) utility routes
    try router.register(collection: UtilityController())
}
