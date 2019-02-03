import FluentPostgreSQL
import Vapor
import Authentication

/// Called before your application initializes.
public func configure(_ config: inout Config, _ env: inout Environment, _ services: inout Services) throws {
    /// Register ORM provider
    try services.register(FluentPostgreSQLProvider())
	
	/// Register authentication provider
	try services.register(AuthenticationProvider())

    /// Register routes to the router
    let router = EngineRouter.default()
    try routes(router)
    services.register(router, as: Router.self)

    /// Register middleware
    var middlewares = MiddlewareConfig() // Create _empty_ middleware config
    /// middlewares.use(FileMiddleware.self) // Serves files from `Public/` directory
    middlewares.use(ErrorMiddleware.self) // Catches errors and converts to HTTP response
    services.register(middlewares)
	
	print("Env: \(env)")
    
    // 🗄 Register PostgreSQL database from databases.swift
	var databasesConfig = DatabasesConfig()
	try databases(config: &databasesConfig)
	services.register(databasesConfig)

    /// Register model migrations
    var migrations = MigrationConfig()
    migrations.add(model: Task.self, database: .psql)
    migrations.add(model: List.self, database: .psql)
    migrations.add(model: User.self, database: .psql)
	migrations.add(model: Token.self, database: .psql)
    services.register(migrations)
}
