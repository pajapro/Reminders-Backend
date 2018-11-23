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
    
    // Add (unprotected) utility routes
    let utilityController = UtilityController()
    router.get("os", use: utilityController.os)
    router.get("dbversion", use: utilityController.databaseVersion)
}
