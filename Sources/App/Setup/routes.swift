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
	
	// "Who am I" (protected) route example
	let tokenAuthenticationMiddleware = User.tokenAuthMiddleware()
	let authedRoutes = router.grouped(tokenAuthenticationMiddleware)
	authedRoutes.get("whoamI") { request -> Future<User.Outcoming> in
		let user = try request.requireAuthenticated(User.self) // returns to us a User object (not a future)
		return try user.authTokens.query(on: request).first().map(to: User.Outcoming.self) { userTokenType in
			guard let tokenType = userTokenType?.token else {
				throw Abort.init(HTTPResponseStatus.notFound)
			}
			return User.Outcoming(email: user.email, token: tokenType)
		}
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
